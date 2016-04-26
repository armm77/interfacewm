
/*
 * $Id: IWMScreen.m,v 1.21 2004/06/15 05:22:21 copal Exp $
 *
 * This file is part of Interface WM.
 *
 * Copyright (C) 2002, Ian Mondragon
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include "IWMScreen.h"
#include "IWMWindowManager.h"
#include "IWMWindow.h"
#include "IWMTheme.h"
#include "IWMImage.h"
#include <IWMGraphics/IWMCoreImage.h>
#include "IWMCoreUtilities.h"
#include "IWMDebug.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSUserDefaults.h>

#include <sys/types.h>
#include <unistd.h>

@implementation IWMScreen

static NSString  *themeName = nil;

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

- initWithScreenNumber:(int)aScreenNumber;
{
    if ((self = [super init]))
    {
        NSLog(@"Initializing screen number %i", aScreenNumber);
        screenNumber    = aScreenNumber;
        rootWindow      = [[IWMWindow alloc]
                                initAsRootWindowForScreen:screenNumber];
        rootXWindow     = [rootWindow xWindow];
        
        // CBV: Make sure this is a valid screen
        if (!iwm_verify_screen(screenNumber))
        {
            NSLog(@"Invalid screen (%d)", screenNumber);
            
            return nil;
        }
        
        /*
         * RContext for libwraster
         */

        if (![self initializeRContext])
        {
            NSLog(@"Failed to initialize RContext");
            
            return nil;
        }
        
        // CBV: First, check whether another WM might be running,
        //      THEN try to load Themes
        [IWMWindowManager setSensitiveHandling: YES];
        
        // define events the root window is interrested in
        XSelectInput(GlobalDisplay, [rootWindow xWindow], IWMSCREEN_EVENT_MASK);
        
        //
        // CBV: Flush the buffer and wait until all requests have
        //      been received and processed by the X Server.
        //
        //      Problem here is, that the error handler will
        //      terminate IWM, instead of returning sth like FALSE
        //      so we can continue to check other possible screens
        //
        
        XSync(GlobalDisplay, False);
        
        [IWMWindowManager setSensitiveHandling: NO];

        /*
         * if this is the initial screen, resort to the default theme.
         * otherwise, take the theme from the previous screen
         *
         * CBV: rather than checking whether screenNumber is 0, we check
         *      whether themeName has already been set, since we might might
         *      be started with eg. -display :0.1
         */

        if (!themeName)
        {
            IWMTheme *tmp = nil;

            themeName = iwm_default_value(THEME_NAME_DEFAULT);
            
            // Fall-back to Default
            if (!themeName)
                themeName = @"Default";
            
            tmp = [[IWMTheme alloc] initWithThemeNamed:themeName screen:self];
            
            if (![self initializeTheme:tmp])
            {
                NSLog(@"Failed to initialize theme");
                
                [tmp release];
                
                return nil;
            }
            
            [tmp release];
        }
        else
        {
            IWMScreen *preceedingScreen = nil;
            
            // FIXME: this is dangerous, as we might have screen 0, 1, and 3
            //        in our list, but not screen 2...
            preceedingScreen = [[GlobalIWM screenArray] 
                                    objectAtIndex:(screenNumber - 1)];
            
            if (![self initializeTheme:[preceedingScreen theme]])
            {
                NSLog(@"Failed to initialize theme");
                
                return nil;
            }
        }

        [self initializeEWMHSupport];
        
        return self;
    }

    return nil;
}

- (void)initializeEWMHSupport
{
    CARD32 data_one[1];
    CARD32 data_two[2];
    CARD32 data_four[4];
    Window tmp;
    pid_t  iwm_pid = getpid();
    
    IWMDebug(@"Initializing EWMH properties", nil);

    // _ewmh_window is never mapped
    tmp = XCreateSimpleWindow(GlobalDisplay, [rootWindow xWindow], 0, 
            0, 1, 1, 0, 0, 0);
    _ewmh_window = [[IWMWindow alloc] initWithWindow:tmp client:nil
        pixmap:0 type:0];
    
    /*
     * _NET_SUPPORTING_WM_CHECK
     */
    
    // set property on root window to id of child window
    [rootWindow setWindowProperty:GlobalIWM->atoms.net_supporting_wm_check
        data:(unsigned char *)&tmp elements:1];
    
    // set property on child window to it's own id
    [_ewmh_window setWindowProperty:GlobalIWM->atoms.net_supporting_wm_check
        data:(unsigned char *)&tmp elements:1];
    
    /*
     * _NET_WM_PID
     */
    [_ewmh_window setCardinalProperty:GlobalIWM->atoms.net_wm_pid
        format:(sizeof(pid_t) * 8) data:(unsigned char *)&iwm_pid elements:1];
    
    /*
     * _NET_DESKTOP_GEOMETRY
     */
    data_two[0] = [self width];
    data_two[1] = [self height];
    [rootWindow setCardinalProperty:GlobalIWM->atoms.net_desktop_geometry
        format:32 data:(unsigned char *)data_two elements:2];
    
    /*
     * _NET_DESKTOP_VIEWPORT - no desktops larger than screen: 0/0
     */
    data_two[0] = 0;
    data_two[1] = 0;
    [rootWindow setCardinalProperty:GlobalIWM->atoms.net_desktop_viewport
        format:32 data:(unsigned char *)data_two elements:2];
    
    /*
     * _NET_CURRENT_DESKTOP
     */
    data_one[0] = screenNumber;
    [rootWindow setCardinalProperty:GlobalIWM->atoms.net_current_desktop
        format:32 data:(unsigned char *)data_one elements:1];
    
    /*
     * _NET_WORKAREA
     */
    data_four[0] = 0;
    data_four[1] = 0;
    data_four[2] = [self width];
    data_four[3] = [self height];
    [rootWindow setCardinalProperty:GlobalIWM->atoms.net_workarea
        format:32 data:(unsigned char *)data_four elements:4];
    
    /*
     * XXX - _NET_VIRTUAL_ROOTS is unused due to how IWM implements virtual
     * desktops (well...*will* implement them)
     */
    
    /*
     * _NET_SHOWING_DESKTOP
     */
    data_one[0] = 0;
    [rootWindow setCardinalProperty:GlobalIWM->atoms.net_showing_desktop
        format:32 data:(unsigned char *)data_one elements:1];

    /*
     * XXX - ADD _NET_SUPPORTED STUFF HERE!!!
     */

    return (void)0x0;
}

- (void)initializeFonts
{
    const char *tmp;
    
    tmp = [[theme primaryFontName] cString];
    if (!(fonts.primary = XLoadQueryFont(GlobalDisplay, tmp)))
    {
        NSLog(@"WARNING: unable to load font %s", tmp);
    }

    // XXX - xft test
    xftfonts.primary = XftFontOpen(GlobalDisplay, screenNumber, XFT_FAMILY,
            XftTypeString, "times-12", XFT_SIZE, XftTypeInteger, 12, 0);
    xftfonts.secondary = XftFontOpen(GlobalDisplay, screenNumber, XFT_FAMILY,
            XftTypeString, "times-10", XFT_SIZE, XftTypeInteger, 10, 0);
    xftfonts.tertiary = XftFontOpen(GlobalDisplay, screenNumber, XFT_FAMILY,
            XftTypeString, "times-8", XFT_SIZE, XftTypeInteger, 8, 0);


    tmp = [[theme secondaryFontName] cString];
    if (!(fonts.secondary = XLoadQueryFont(GlobalDisplay, tmp)))
    {
        NSLog(@"WARNING: unable to load font %s", tmp);
    }

    tmp = [[theme tertiaryFontName] cString];
    if (!(fonts.tertiary = XLoadQueryFont(GlobalDisplay, tmp)))
    {
        NSLog(@"WARNING: unable to load font %s", tmp);
    }
    
    return (void)0x0;
}

- (void)initializeColors
{
    Colormap     colormap;
    XColor       dummy;
    const char  *tmp;

    colormap = [self colormap];
    
    // focused color
    tmp = [[theme focusedTitleColorName] cString];
    if ((XAllocNamedColor(GlobalDisplay, colormap, tmp, &colors.focused, 
                    &dummy))) 
    {
        xftcolors.focused.color.red = dummy.red;
        xftcolors.focused.color.green = dummy.green;
        xftcolors.focused.color.blue = dummy.blue;
        xftcolors.focused.color.alpha = 0x00ff00;
        xftcolors.focused.pixel = colors.focused.pixel;
    }
    else
    {
        NSLog(@"WARNING: unable to allocate focused color %s", tmp);
    }
  
    // unfocused color
    tmp = [[theme unfocusedTitleColorName] cString];
    if ((XAllocNamedColor(GlobalDisplay, colormap, tmp, &colors.unfocused, 
                    &dummy)))
    {
        xftcolors.unfocused.color.red = dummy.red;
        xftcolors.unfocused.color.green = dummy.green;
        xftcolors.unfocused.color.blue = dummy.blue;
        xftcolors.unfocused.color.alpha = 0x00ff00;
        xftcolors.unfocused.pixel = colors.unfocused.pixel;
    }
    else
    {
        NSLog(@"WARNING: unable to allocate unfocused color %s", tmp);
    }
    
    // background color
    tmp = [[theme emptyBackgroundColorName] cString];
    if ((XAllocNamedColor(GlobalDisplay, colormap, tmp, &colors.background, 
                    &dummy)))
    {
        xftcolors.background.color.red = dummy.red;
        xftcolors.background.color.green = dummy.green;
        xftcolors.background.color.blue = dummy.blue;
        xftcolors.background.color.alpha = 0x00ff00;
        xftcolors.background.pixel = colors.background.pixel;
    }
    else 
    {    
        NSLog(@"WARNING: unable to allocate background color %s", tmp);
    }
    
    // border color
    tmp = [[theme borderColorName] cString];
    if ((XAllocNamedColor(GlobalDisplay, colormap, tmp, &colors.border, 
                    &dummy)))
    {
        xftcolors.border.color.red = dummy.red;
        xftcolors.border.color.green = dummy.green;
        xftcolors.border.color.blue = dummy.blue;
        xftcolors.border.color.alpha = 0x00ff00;
        xftcolors.border.pixel = colors.border.pixel;
    }
    else
    {
        NSLog(@"WARNING: unable to allocate border color %s", tmp);
    }
    
    return (void)0x0;
}

- (void)initializeGraphicsContexts
{
    XGCValues   gv;
    Window      root = [rootWindow xWindow];
    
    // focused GC
    iwm_free_gc(GlobalDisplay, gcs.focused);
    
    gv.function         = GXcopy;
    gv.foreground       = colors.focused.pixel;
    gv.font             = fonts.primary->fid;
    gcs.focused         = XCreateGC(GlobalDisplay, root, 
                                GCFunction|GCForeground|GCFont, &gv);

    // unfocused GC
    iwm_free_gc(GlobalDisplay, gcs.unfocused);
    
    gv.function         = GXcopy;
    gv.foreground       = colors.unfocused.pixel;
    gv.font             = fonts.primary->fid;
    gcs.unfocused       = XCreateGC(GlobalDisplay, root, 
                                GCFunction|GCForeground|GCFont, &gv);
    
    // border GC
    iwm_free_gc(GlobalDisplay, gcs.border);
    
    gv.foreground       = colors.border.pixel;
    gv.line_width       = BORDER_WIDTH;
    gcs.border          = XCreateGC(GlobalDisplay, root, 
                                GCFunction|GCForeground|GCLineWidth, &gv);
    
    // invert GC
    iwm_free_gc(GlobalDisplay, gcs.invert);
    
    gv.function         = GXinvert;
    gv.subwindow_mode   = IncludeInferiors;
    gcs.invert          = XCreateGC(GlobalDisplay, root, 
                            GCFunction|GCSubwindowMode|GCLineWidth|GCFont, &gv);

    // background GC
    iwm_free_gc(GlobalDisplay, gcs.background);

    gv.function         = GXcopy;
    gv.foreground       = colors.background.pixel;
    gcs.background      = XCreateGC(GlobalDisplay, root, 
                            GCFunction|GCForeground|GCLineWidth, &gv);
    
    return (void)0x0;
}

- (void)initializeCursors
{
    // populate the cursors structure
    cursors.normal      = XCreateFontCursor(GlobalDisplay, XC_left_ptr);
    cursors.move        = XCreateFontCursor(GlobalDisplay, XC_right_ptr);
    cursors.resize      = XCreateFontCursor(GlobalDisplay, XC_exchange);
    cursors.leftResize  = XCreateFontCursor(GlobalDisplay, XC_ll_angle);
    cursors.rightResize = XCreateFontCursor(GlobalDisplay, XC_lr_angle);
    cursors.downResize  = XCreateFontCursor(GlobalDisplay, XC_bottom_tee);
    
    // define the default cursor
    XDefineCursor(GlobalDisplay, [rootWindow xWindow], cursors.normal);

    return (void)0x0;
}

/*
 * RContext used by libwraster
 */
- (BOOL)initializeRContext
{
    RContextAttributes rattr;
    
    rattr.flags = RC_RenderMode | RC_ColorsPerChannel | RC_StandardColormap;
    rattr.render_mode = RBestMatchRendering;
    rattr.colors_per_channel = 4;
    rattr.standard_colormap_mode = RUseStdColormap;
    
    if ((rcontext = RCreateContext(GlobalDisplay, screenNumber, &rattr)))
    {
        return YES;
    }

    return NO;
}

- (BOOL)initializeTheme:(IWMTheme *)aTheme
{
    if (aTheme)
    {
        [self setTheme:aTheme];
        
        [self initializeColors];
        [self initializeFonts];
        [self initializeCursors];
        [self initializeGraphicsContexts];
        
        //[self setScreenBackgroundImage:[theme backgroundImage]];
        
        return YES;
    }

    return NO;
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setTheme:(IWMTheme *)aTheme
{
    [theme autorelease];
    theme = [aTheme retain];
}

- (void)setScreenBackgroundImage:(IWMImage *)anImage
{
    if (anImage)
    {
        [rootWindow setImage:anImage];
        //iwm_image_set_into_window([anImage image], rootWindow, self);
    }
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (int)titlebarHeight
{
    return fonts.primary->ascent + fonts.primary->descent + 4 + BORDER_WIDTH;
}

- (int)textWidthForString:(NSString *)aString
{
    return XTextWidth(fonts.primary, [aString cString],
            [aString cStringLength]);
}

- (void)drawCenteredText:(NSString *)aString
{
    int x, y;

    x = ((iwm_display_width(self)/2) - ([self textWidthForString:aString]/2));
    y = (iwm_display_height(self)/2);

    XDrawString(GlobalDisplay, [self rootXWindow], [self invertGC], x, y,
            [aString cString], [aString cStringLength]);
}

- (void)drawRectangleWithWidth:(int)width height:(int)height x:(int)xValue
    y:(int)yValue
{
    XDrawRectangle(GlobalDisplay, [self rootXWindow], [self invertGC], xValue,
            yValue, width, height);
}

- (Window)rootXWindow
{
    return [rootWindow xWindow];
}

- (IWMWindow *)rootWindow
{
    return rootWindow;
}

- (IWMTheme *)theme
{
    return theme;
}

- (int)screenNumber
{
    return screenNumber;
}

- (int)depth
{
    return (DefaultDepth(GlobalDisplay, screenNumber));
}

- (int)width
{
    return (WidthOfScreen(ScreenOfDisplay(GlobalDisplay, screenNumber)));
}

- (int)height
{
    return (HeightOfScreen(ScreenOfDisplay(GlobalDisplay, screenNumber)));
}

- (Colormap)colormap
{
    return (DefaultColormap(GlobalDisplay, screenNumber));
}

- (RContext *)rcontext
{
    return rcontext;
}

- (NSMutableArray *)clientArray
{
#if 0
    if (!clientArray)
    {
        clientArray = [[NSMutableArray alloc] init];
    }

    return clientArray;
#endif

    return nil;
}

- (Cursor)normalCursor
{
    return cursors.normal;
}

- (Cursor)moveCursor
{
    return cursors.move;
}

- (Cursor)resizeCursor
{
    return cursors.resize;
}

- (Cursor)leftResizeCursor
{
    return cursors.leftResize;
}

- (Cursor)rightResizeCursor
{
    return cursors.rightResize;
}

- (Cursor)downResizeCursor
{
    return cursors.downResize;
}

- (XFontStruct *)primaryFont
{
    return fonts.primary;
}

- (XFontStruct *)secondaryFont
{
    return fonts.secondary;
}

- (XColor)focusedColor
{
    return colors.focused;
}

- (XColor)unfocusedColor
{
    return colors.unfocused;
}

- (XColor)backgroundColor
{
    return colors.background;
}

- (XColor)borderColor
{
    return colors.border;
}

- (GC)invertGC
{
    return gcs.invert;
}

- (GC)focusedGC
{
    return gcs.focused;
}

- (GC)unfocusedGC
{
    return gcs.unfocused;
}

- (GC)borderGC
{
    return gcs.border;
}

- (GC)backgroundGC
{
    return gcs.background;
}

- (void)dealloc
{
    XDestroyWindow(GlobalDisplay, [self rootXWindow]);

    XFreeCursor(GlobalDisplay, cursors.normal);
    XFreeCursor(GlobalDisplay, cursors.move);
    XFreeCursor(GlobalDisplay, cursors.resize);
    XFreeCursor(GlobalDisplay, cursors.leftResize);
    XFreeCursor(GlobalDisplay, cursors.rightResize);

    XFreeFont(GlobalDisplay, fonts.primary);
    XFreeFont(GlobalDisplay, fonts.secondary);

    XFreeGC(GlobalDisplay, gcs.invert);
    XFreeGC(GlobalDisplay, gcs.focused);
    XFreeGC(GlobalDisplay, gcs.unfocused);
    XFreeGC(GlobalDisplay, gcs.border);
    XFreeGC(GlobalDisplay, gcs.background);
    
    [super dealloc];
}

@end

