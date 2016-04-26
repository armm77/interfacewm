
/*
 * $Id: IWMWindow.m,v 1.24 2004/06/15 05:22:21 copal Exp $
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

#include "InterfaceWM.h"
#include "IWMWindow.h"
#include "IWMClient.h"
#include "IWMScreen.h"
#include "IWMImage.h"
#include "IWMWindowManager.h"
#include "IWMCoreUtilities.h"

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>

#include "IWMDebug.h"

@implementation IWMWindow

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

- initWithWindow:(Window)aWindow client:(IWMClient *)aClient
    pixmap:(Pixmap)aPixmap type:(Atom)aType
{
    if ((self = [super init]))
    {
        int screenNumber = GlobalIWM->currentScreenNumber;
        
        xWindow = aWindow;
        pixmap  = (aPixmap) ? aPixmap : 0;

        if (!(aWindow == RootWindow(GlobalDisplay, screenNumber)))
        {
            if (!(xftdraw = XftDrawCreate(GlobalDisplay, (Drawable)xWindow,
                DefaultVisual(GlobalDisplay, screenNumber),
                DefaultColormap(GlobalDisplay, screenNumber))))
            {
                NSLog(@"initialized XftDraw for window");
            }
        }

        client = [aClient retain];
        [self setWindowType:aType];
        
        return self;
    }

    return nil;
}

- initWithParent:(IWMWindow *)aParent frame:(NSRect)aFrame;
{
    XSetWindowAttributes     attr;
    Visual                  *visual;
    long                     mask;
    IWMScreen               *screen = [GlobalIWM currentScreen];
    Window                   window;
    
    visual = DefaultVisual(GlobalDisplay, [screen screenNumber]);
    mask   = IWM_WINDOW_MASK;
    
    attr.background_pixmap      = None;
    attr.background_pixel       = ([screen backgroundColor]).pixel;
    attr.border_pixel           = ([screen borderColor]).pixel;
    attr.cursor                 = [screen normalCursor];
    attr.override_redirect      = False;
    attr.event_mask             = IWM_EVENT_MASK_WINDOW;
    
    // create a window as a child of aParent
    window = XCreateWindow(GlobalDisplay, [aParent xWindow],
            (int)aFrame.origin.x, (int)aFrame.origin.y, (int)aFrame.size.width,
            (int)aFrame.size.height, BORDER_WIDTH, [screen depth],
            CopyFromParent, visual, mask, &attr);

    return [self initWithWindow:window client:[aParent client] pixmap:0
        type:GlobalIWM->atoms.iwm_window_type_unknown];
}

- initAsClientWindow:(Window)window sender:(IWMClient *)sender
{
    XSetWindowAttributes attr;
    unsigned long        valuemask;

    valuemask                   = CWEventMask|CWDontPropagate|CWSaveUnder;
    attr.event_mask             = IWM_EVENT_MASK_CLIENT;
    attr.do_not_propagate_mask  = ButtonPressMask|ButtonReleaseMask;
    attr.save_under             = False;

    // all we're doing is setting some attributes for the client window
    XChangeWindowAttributes(GlobalDisplay, window, valuemask, &attr);
    XSetWindowBorderWidth(GlobalDisplay, window, 0);
    
    return [self initWithWindow:window client:sender pixmap:0
        type:GlobalIWM->atoms.iwm_window_type_client_window];
}

- initAsParentForClient:(IWMClient *)aClient
{
    XSetWindowAttributes  attr;
    Visual               *visual;
    Window                window;
    IWMScreen            *screen = [GlobalIWM currentScreen];
    NSRect                frame = [aClient frame];
    int                   xValue = (int)frame.origin.x;
    int                   yValue = (int)frame.origin.y;
    int                   aWidth = (int)frame.size.width;
    int                   aHeight = [aClient height];
    
    visual = DefaultVisual(GlobalDisplay, [screen screenNumber]);
    
    attr.background_pixmap      = None;
    attr.background_pixel       = ([screen backgroundColor]).pixel;
    attr.border_pixel           = ([screen borderColor]).pixel;
    attr.cursor                 = [screen normalCursor];
    attr.override_redirect      = True;
    attr.event_mask             = IWM_EVENT_MASK_PARENT;
    
    // create parent window for all of a client's components
    window = XCreateWindow(GlobalDisplay, [screen rootXWindow], xValue, 
            yValue, aWidth, aHeight, BORDER_WIDTH, [screen depth], 
            CopyFromParent, visual, IWM_WINDOW_MASK_PARENT, &attr);
    
    return [self initWithWindow:window client:aClient pixmap:0
        type:GlobalIWM->atoms.iwm_window_type_parent_window];
}

- initAsTopLevelWithFrame:(NSRect)aFrame
{
    XSetWindowAttributes  attr;
    IWMScreen            *screen = [GlobalIWM currentScreen];
    Visual               *visual;
    Window                aWindow;
    int                   vmask;
    
    visual = DefaultVisual(GlobalDisplay, [screen screenNumber]);
    vmask  = CWBorderPixel|CWCursor|CWEventMask|CWOverrideRedirect|
        CWColormap;
    
    attr.override_redirect  = True;
    attr.background_pixmap  = None;
    attr.background_pixel   = ([screen backgroundColor]).pixel;
    attr.border_pixel       = ([screen borderColor]).pixel;
    attr.event_mask         = IWM_EVENT_MASK_TOP_LEVEL;
    attr.colormap           = [screen colormap];
    attr.cursor             = [screen normalCursor];
    
    // create a window suitable for menus, docks, etc.
    aWindow = XCreateWindow(GlobalDisplay, [screen rootXWindow],
            (int)aFrame.origin.x, (int)aFrame.origin.y,
            (int)aFrame.size.width, (int)aFrame.size.height,
            BORDER_WIDTH, [screen depth], CopyFromParent, visual,
            vmask, &attr);

    return [self initWithWindow:aWindow client:nil pixmap:0
                type:GlobalIWM->atoms.iwm_window_type_icon];
}

- initAsRootWindowForScreen:(int)screen
{
    Window root = RootWindow(GlobalDisplay, screen);
    
    // root window
    return [self initWithWindow:root client:nil pixmap:0
                type:GlobalIWM->atoms.iwm_window_type_root_window];
}

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

/*
 * resize window/image, set image into window
 */

- (void)setSize:(NSSize)aSize
{
    XResizeWindow(GlobalDisplay, xWindow, (int)aSize.width, (int)aSize.height);
}

- (void)setTopLeftPoint:(NSPoint)aPoint
{
    XMoveWindow(GlobalDisplay, xWindow, (int)aPoint.x, (int)aPoint.y);
}

- (void)setInto:(IWMWindow *)aParent point:(NSPoint)aPoint
{
    XReparentWindow(GlobalDisplay, xWindow, [aParent xWindow],
            (int)aPoint.x, (int)aPoint.y);
}

- (void)hide
{
    XUnmapWindow(GlobalDisplay, xWindow);
}

- (void)unhide
{
    XMapWindow(GlobalDisplay, xWindow);
}

- (void)raise
{
    XRaiseWindow(GlobalDisplay, xWindow);
}

- (void)takeInputFocus
{
    XSetInputFocus(GlobalDisplay, xWindow, RevertToPointerRoot,
            CurrentTime);
}

- (NSString *)name
{
    NSString            *nameString = nil;
    char                *name;
    int                  tmp;
  
    /* 
     * XXX - _NET_WM_VISIBLE_NAME & _NET_WM_NAME need to be changed to UTF-8
     */
    
    // _NET_WM_VISIBLE_NAME
    if ((name = (char *)[self property:GlobalIWM->atoms.net_wm_visible_name
                type:XA_STRING count:&tmp]) && tmp)
    {
        nameString = [NSString stringWithCString:name];
        IWMDebug(@"_NET_WM_VISIBLE_NAME: %s", name);
    }
    
    // _NET_WM_NAME
    else if ((name = (char *)[self property:GlobalIWM->atoms.net_wm_name
                type:XA_STRING count:&tmp]) && tmp)
    {
        nameString = [NSString stringWithCString:name];
        IWMDebug(@"_NET_WM_NAME: %s", name);
    }

    // WM_NAME
    else if (0 != (XFetchName(GlobalDisplay, xWindow, &name)))
    {
        nameString = [NSString stringWithCString:name];
        IWMDebug(@"WM_NAME: %s", name);
        XFree(name);
    }

    return nameString; 
}

- (void)setName:(NSString *)name
{
    if (name && [name cStringLength])
    {
        const char *data = [name cString];
        
        // XXX - needs to be changed to UTF-8
        [self setStringProperty:GlobalIWM->atoms.net_wm_visible_name
            format:32 data:(unsigned char *)data elements:1];
    }
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setClient:(IWMClient *)aClient
{
    if (aClient)
    {
        [client autorelease];
        client = [aClient retain];
    }
}

/*
 * XXX - this really sucks - we need to associate the IWMImage with the
 * window in a better way.  for now we're just scaling the image, converting
 * it to a pixmap & stuffing it into the window.  boo.
 */
- (void)setImage:(IWMImage *)anImage
{
    if (anImage)
    {
        // clear out any previous pixmap
        if (pixmap)
        {
            XFreePixmap(GlobalDisplay, pixmap);
            pixmap = 0;
        }

        pixmap = [anImage setAsPixmapBackgroundInWindow:self];

        
    }
}

- (void)setPixmap:(Pixmap)aPixmap
{
    XSetWindowBackgroundPixmap(GlobalDisplay, xWindow, aPixmap);
    [self clear];
    XSync(GlobalDisplay, False);
}

- (void)scaleImageInWindow
{
}

- (void)tileImageInWindow
{
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (IWMClient *)client
{
    return client;
}

- (XContext)clientID
{
    return [client clientID];
}

- (IWMScreen *)screen
{
    if (!client)
        return [GlobalIWM currentScreen];

    return [[self client] screen];
}

- (Pixmap)pixmap
{
    return pixmap;
}

- (Window)xWindow
{
    return xWindow;
}

- (XWindowAttributes)attributes
{
    XWindowAttributes attr;

    XGetWindowAttributes(GlobalDisplay, xWindow, &attr);

    return attr;
}

- (NSRect)frame
{
    XWindowAttributes   attr;
    NSRect              rect;

    XGetWindowAttributes(GlobalDisplay, xWindow, &attr);

    rect.origin.x = attr.x;
    rect.origin.y = attr.y;
    rect.size.width = attr.width;
    rect.size.height = attr.height;

    return rect;
}

- (void)setFrame:(NSRect)aRect
{
    XMoveResizeWindow(GlobalDisplay, xWindow, (int)aRect.origin.x, 
            (int)aRect.origin.y, (int)aRect.size.width, (int)aRect.size.height);
}

- (int)width
{
    return (int)([self frame]).size.width;
}

- (int)height
{
    return (int)([self frame]).size.height;
}

- (NSSize)size
{
    return ([self frame]).size;
}

- (NSPoint)origin
{
    return ([self frame]).origin;
}

- (void)configureNotify
{
    XEvent event;
    NSRect frame;
    
    frame = [self frame];

    event.type = ConfigureNotify;
    event.xconfigure.display = GlobalDisplay;
    event.xconfigure.event = xWindow;
    event.xconfigure.window = xWindow;
    event.xconfigure.x = frame.origin.x;
    event.xconfigure.y = frame.origin.y;
    event.xconfigure.width = frame.size.width;
    event.xconfigure.height = frame.size.height;
    event.xconfigure.border_width = 0;
    event.xconfigure.above = None;
    event.xconfigure.override_redirect = False;

    XSendEvent(GlobalDisplay, xWindow, False, StructureNotifyMask, &event);
    XFlush(GlobalDisplay);
}

- (int)mapState
{
    XWindowAttributes attr;

    XGetWindowAttributes(GlobalDisplay, xWindow, &attr);
    
    return (attr.map_state);
}

- (Window)transient
{
    Window transient;

    XGetTransientForHint(GlobalDisplay, xWindow, &transient);

    return transient;
}

/* XXX - boo.  change this to utilize _NET_WM_STATE */
- (int)windowState
{
    //Atom           realType;
    //int            realFormat;
    int state;
    //unsigned long  n;
    //unsigned long extra;
    unsigned char *data;
    int count;

    if ((data = [self property:GlobalIWM->atoms.wm_state type:AnyPropertyType
                count:&count]))
#if 0
    if ((XGetWindowProperty(GlobalDisplay, xWindow, 
                    GlobalIWM->atoms.wm_state, 0L, 2L, 
                    False, AnyPropertyType, &realType, &realFormat, &n, &extra,
                    &data) == Success) && n)
#endif
    {
        state = *(int *)data;
        XFree(data);

        return state;
    }

    return WithdrawnState;
}

/*
 * XXX - this needs to go bye-bye in favor of the _NET_WM_STATE schtuff
 */
- (void)setWindowState:(int)aState
{
    unsigned long data[2];

    data[0] = (unsigned long)aState;
    data[1] = None;                     // XXX - ICON WINDOW
    
    [self setProperty:GlobalIWM->atoms.wm_state type:GlobalIWM->atoms.wm_state
        format:32 data:(unsigned char *)data elements:2];

    return (void)0x0;
}

- (void)updateWindowState
{
    Atom list[10];
    int  i = 0;

    // rebuild _NET_WM_STATE value array
    if ([client modal])
        list[i++] = GlobalIWM->atoms.net_wm_state_modal;

    if ([client sticky])
        list[i++] = GlobalIWM->atoms.net_wm_state_sticky;

    if ([client maximizedVertically])
        list[i++] = GlobalIWM->atoms.net_wm_state_maximized_vert;
    
    if ([client maximizedHorizontally])
        list[i++] = GlobalIWM->atoms.net_wm_state_maximized_horz;
    
    if ([client shaded])
        list[i++] = GlobalIWM->atoms.net_wm_state_shaded;
    
    if ([client skipTaskbar])
        list[i++] = GlobalIWM->atoms.net_wm_state_skip_taskbar;

    if ([client skipPager])
        list[i++] = GlobalIWM->atoms.net_wm_state_skip_pager;
    
    if ([client hidden])
        list[i++] = GlobalIWM->atoms.net_wm_state_hidden;

    if ([client fullscreen])
        list[i++] = GlobalIWM->atoms.net_wm_state_fullscreen;

    if ([client focused])
        list[i++] = GlobalIWM->atoms.net_wm_state_above;
    else
        list[i++] = GlobalIWM->atoms.net_wm_state_below;

    // set _NET_WM_STATE with updated array
    [self setAtomProperty:GlobalIWM->atoms.net_wm_state
        data:(unsigned char *)list elements:i];
}

- (XWMHints *)wmHints
{
    return XGetWMHints(GlobalDisplay, xWindow);
}

- (XSizeHints *)wmNormalHints
{
    XSizeHints *hints; 
    long        dummy;
    
    hints = XAllocSizeHints();

    XGetWMNormalHints(GlobalDisplay, xWindow, hints, &dummy);

    if (!hints)
    {
        XFree(hints);
        return NULL;
    }

    return hints;
}

- (Atom *)wmProtocols:(int *)number
{
    Atom *protocols;

    if (XGetWMProtocols(GlobalDisplay, xWindow, &protocols, number))
        return protocols;

    return NULL;
}

- (NSString *)xClass
{
    XClassHint  *hint = XAllocClassHint();
    NSString    *result = nil;
    
    if (XGetClassHint(GlobalDisplay, xWindow, hint))
        result = [NSString stringWithCString:hint->res_class];
    
    if (hint)
        XFree(hint);

    return result;
}

- (NSString *)xClassInstance
{
    XClassHint  *hint = XAllocClassHint();
    NSString    *result = nil;
    
    if (XGetClassHint(GlobalDisplay, xWindow, hint))
        result = [NSString stringWithCString:hint->res_name];
    
    if (hint)
        XFree(hint);

    return result;
}

/*
 * obtaining a window property - from WindowMaker
 */
- (unsigned char *)property:(Atom)property type:(Atom)aType count:(int *)count
{
    return iwm_window_property(xWindow, property, aType, count);
}

- (unsigned char *)atomProperty:(Atom)property count:(int *)count
{
    return [self property:property type:XA_ATOM count:count];
}

- (unsigned char *)intProperty:(Atom)property count:(int *)count
{
    return [self property:property type:XA_CARDINAL count:count];
}

- (unsigned char *)windowProperty:(Atom)property count:(int *)count
{
    return [self property:property type:XA_WINDOW count:count];
}

- (unsigned char *)stringProperty:(Atom)property count:(int *)count
{
    return [self property:property type:XA_STRING count:count];
}

- (void)setProperty:(Atom)property type:(Atom)aType format:(int)format
        data:(unsigned char *)data elements:(int)elements
{
    if (!elements)
    {
        XDeleteProperty(GlobalDisplay, xWindow, property);
        return (void)0x0;
    }

    //IWMDebug(@"Property modification { %s : %s }",
      //       XGetAtomName(GlobalDisplay, property),
        //     XGetAtomName(GlobalDisplay, aType));
    
    if (format >= 16)
    {
        XChangeProperty(GlobalDisplay, xWindow, property, aType,
                format, PropModeReplace, (char *)data, elements);
    }
    else
    {
        XChangeProperty(GlobalDisplay, xWindow, property, aType,
                format, PropModeReplace, data, elements);
    }
}

- (void)setWindowProperty:(Atom)property
		     data:(unsigned char *)data elements:(int)elements
{
    [self setProperty:property type:XA_WINDOW format:32 data:data
	     elements:elements];
}

- (void)setCardinalProperty:(Atom)property format:(int)format
		       data:(unsigned char *)data elements:(int)elements
{
    [self setProperty:property type:XA_CARDINAL format:format data:data
	     elements:elements];
}

- (void)setStringProperty:(Atom)property format:(int)format
		       data:(unsigned char *)data elements:(int)elements
{
    [self setProperty:property type:XA_STRING format:format data:data
	     elements:elements];
}

- (void)setAtomProperty:(Atom)property
		       data:(unsigned char *)data elements:(int)elements
{
    [self setProperty:property type:XA_ATOM format:32 data:data
	     elements:elements];
}

- (Atom)windowType
{
    return iwm_window_type(xWindow);
}

- (void)setWindowType:(Atom)aType
{
    Atom data[1];
    
    if (!aType)
        data[0] = GlobalIWM->atoms.iwm_window_type_unknown;
    else
        data[0] = aType;

    [self setAtomProperty:GlobalIWM->atoms.iwm_window_type
		data:(unsigned char *)data elements:1];
}

- (void)setRolloverCursor:(Cursor)aCursor
{
    if (aCursor)
        XDefineCursor(GlobalDisplay, xWindow, aCursor);
    else
        XDefineCursor(GlobalDisplay, xWindow, None);
}

- (void)setBorderWidth:(int)width
{
    XSetWindowBorderWidth(GlobalDisplay, xWindow, width);
}

- (Colormap)colormap
{
    XWindowAttributes attr;

    XGetWindowAttributes(GlobalDisplay, xWindow, &attr);

    return attr.colormap;
}

- (void)setColormap:(Colormap)aColormap
{
    XSetWindowAttributes attr;

    attr.colormap = aColormap;
    
    XChangeWindowAttributes(GlobalDisplay, xWindow, CWColormap,
            &attr);
}

- (void)clear
{
    XClearWindow(GlobalDisplay, xWindow);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<IWMWindow: %i (%ix%i)>",
                (int)xWindow, [self width], [self height]];
}

- (void)dealloc
{
    XDeleteContext(GlobalDisplay, xWindow, [GlobalIWM windowContext]);
    
    XUnmapWindow(GlobalDisplay, xWindow);
    XDestroyWindow(GlobalDisplay, xWindow);
    XFreePixmap(GlobalDisplay, pixmap);
    
    [super dealloc];
}

@end

