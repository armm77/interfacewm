
/*
 * $Id: IWMClient.m,v 1.37 2004/06/17 05:35:10 copal Exp $
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
#include "IWMClient.h"
#include "IWMWindow.h"
#include "IWMScreen.h"
#include "IWMTitlebar.h"
#include "IWMResizebar.h"
#include "IWMIcon.h"
#include "IWMTheme.h"
#include "IWMWindowManager.h"
#include "IWMCoreUtilities.h"

#include <IWMExtensions/NSDictionaryExt.h>
#include <IWMGraphics/IWMImage.h>

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>

#include <time.h>

#include "IWMDebug.h"

@implementation IWMClient

/*==========================================================================*
   INITIALIZATION METHODS
 *==========================================================================*/

- initWithWindow:(Window)aWindow onScreen:(int)aScreenNumber
{
    if ((self = [super init]))
    {
        window = [[IWMWindow alloc] initAsClientWindow:aWindow sender:self];
        parent = nil;
        titlebar = nil;
        resizebar = nil;
        iconImage = nil;
        icon = nil;
        transient = -1;
        ignoreUnmap = 0;
        
        minimumSize.width = IWM_MINIMUM_SIZE;
        minimumSize.height = IWM_MINIMUM_SIZE;
        maximumSize.width = 0;
        maximumSize.height = 0;
        resizeIncrements.width = 1;
        resizeIncrements.height = 1;
        _gravity = NorthWestGravity;
        
        _clientID = XUniqueContext();
        _screenNumber = aScreenNumber;
        _frame = [window frame];

        // descriptor
        state.focused = NO;
        state.modal = NO;
        state.sticky = NO;
        state.hidden = YES;
        state.shaded = NO;
        state.maximized_horz = NO;
        state.maximized_vert = NO;
        state.fullscreen = NO;
        state.skip_taskbar = NO;
        state.skip_pager = NO;
        state.shaped = NO;

        decor.border = NO;
        decor.resizebar = NO;
        decor.titlebar = NO;
        decor.close_button = NO;
        decor.minimize_button = NO;
        decor.icon = NO;

        if (IsViewable == [window mapState])
        {
            ignoreUnmap++;
        }
        else
        {
            XWMHints *hints = [window wmHints];
            
            [self initializeFrame];

            if (hints)
            {
                if (hints->flags & StateHint)
                {
                    [self setWMState:hints->initial_state];
                }

                XFree(hints);
            }
        }

        [self initializeDecorations];
        [self initializeParentWindow];
        [self focus];

        return self;
    }

    return nil;
}

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

- (void)drawOutline
{
    IWMScreen   *screen = [self screen];
    NSString    *coords = nil;
    
    // draw outline of client in current state
    [screen drawRectangleWithWidth:_outline.size.width
        height:_outline.size.height x:_outline.origin.x y:_outline.origin.y];

    // create string describing the client outline
    coords = [[NSString alloc] initWithFormat:@"Width:%d Height:%d X:%d Y:%d",
                (int)_outline.size.width, (int)_outline.size.height,
                (int)_outline.origin.x, (int)_outline.origin.y];
                
	// draw the coordinates in the center of screen
    [screen drawCenteredText:coords];
	
    [coords release];
}

// XXX - fix this to be better
- (IWMWindow *)windowForXWindow:(Window)aWindow
{
    IWMWindow *tmp = nil;
    
    if (decor.titlebar && titlebar)
    {
        if (aWindow == titlebar->xWindow)
            return titlebar;

        tmp = [titlebar closeButton];
        if (aWindow == tmp->xWindow)
            return tmp;

        tmp = [titlebar minimizeButton];
        if (aWindow == tmp->xWindow)
            return tmp;
    }

    if (decor.resizebar && resizebar)
    {
        if (aWindow == resizebar->xWindow)
            return resizebar;

        tmp = [resizebar leftGrip];
        if (aWindow == tmp->xWindow)
            return tmp;

        tmp = [resizebar rightGrip];
        if (aWindow == tmp->xWindow)
            return tmp;
    }

    if (aWindow == window->xWindow)
        return window;

    if (aWindow == parent->xWindow)
        return parent;

    if (aWindow == icon->xWindow)
        return icon;
    
    return nil;
}

- (void)sendProtocol:(Atom)atom
{
    XEvent event;
    
    IWMDebug(@"WM_PROTOCOL -> %s", XGetAtomName(GlobalDisplay, atom));
    
    event.xclient.type          = ClientMessage;
    event.xclient.message_type  = GlobalIWM->atoms.wm_protocols;
    event.xclient.format        = 32;
    event.xclient.display       = GlobalDisplay;
    event.xclient.window        = [parent xWindow];
    event.xclient.data.l[0]     = atom;
    event.xclient.data.l[1]     = CurrentTime;    // timestamp
    event.xclient.data.l[2]     = 0;
    event.xclient.data.l[3]     = 0;

    XSendEvent(GlobalDisplay, [parent xWindow], False, NoEventMask, &event);
    XSync(GlobalDisplay, False);
}

/*==========================================================================*
   CORE MANIPULATION METHODS
 *==========================================================================*/
- (void)hide
{
    IWMTRACE;
    
    if (!state.hidden)
    {
        state.hidden = YES;
        ignoreUnmap++;
        
        [parent hide];
        [window hide];
        
        if (decor.titlebar)
            [titlebar hide];
        
        if (decor.resizebar)
            [resizebar hide];
        
        [self setWMState:IconicState];

        // XXX - set _NET_WM_STATE_HIDDEN property
        [self update];
    }
}

- (void)unhide
{
    state.hidden = NO;
    
    [parent unhide];
    [window unhide];
    
    if (decor.titlebar && titlebar)
        [titlebar unhide];
        
    if (decor.resizebar && resizebar)
        [resizebar unhide];

    [self setWMState:NormalState];      // XXX boo
    
    // XXX - unset _NET_WM_STATE_HIDDEN property
    [self update];
}

- (void)shade
{
    IWMTRACE;
    
    if (decor.titlebar && !state.shaded)
    {
        Atom data[1];
        NSSize size;
        
        IWMDebug(@"shading client...", nil);

        data[0] = GlobalIWM->atoms.net_wm_state_shaded;
        size.width = [self width];
        size.height = [self titlebarHeight];
        
        [parent setSize:size];
        state.shaded = YES;
        [self setWMState:IconicState];
        
        // XXX - set _NET_WM_STATE_SHADED property
        [self update];
    }
}

- (void)unshade
{
    if (decor.titlebar && state.shaded)
    {
        NSSize size;
        
        IWMDebug(@"unshading client...", nil);   
        
        size.width = [self width];
        size.height = [self height];
        
        [parent setSize:size];
        state.shaded = NO;
        [self setWMState:NormalState];
        
        // XXX - unset _NET_WM_STATE_SHADED property
        [self update];
    }
}

- (void)focus
{
    IWMTRACE;
    
    // only perform if we're currently unfocused
    if (!state.focused)
    {
        IWMImage *image = nil;
        
        image = [[[self screen] theme] focusedTitlebarImage];
        [titlebar setImage:image];
        [[resizebar leftGrip] setImage:image];
        [[resizebar rightGrip] setImage:image];
        
        [self setWMState:NormalState]; // XXX - change this for EWMH
        state.focused = YES;
        [self update];
        
        [window raise];
        [window takeInputFocus];

        [self redraw];
    }
}

- (void)unfocus
{
    IWMTRACE;
    
    // only perform if we're currently focused
    if (state.focused)
    {
        IWMImage *image = nil;
        
        image = [[[self screen] theme] unfocusedTitlebarImage];
        [titlebar setImage:image];
        [[resizebar leftGrip] setImage:image];
        [[resizebar rightGrip] setImage:image];

        state.focused = NO;
        [self update];
        
        [self redraw];
    }
}

- (void)configureRequest:(XConfigureRequestEvent *)event
{
    NSRect frame;
    
    IWMTRACE;
    
    frame = [self frame];

    [self ungravitate];
    
#if SHAPE
    int junk;
    unsigned int ujunk;
    
    XShapeSelectInput(GlobalDisplay, window->xWindow, ShapeNotifyMask);
    XShapeQueryExtents(GlobalDisplay, window->xWindow, &_shape, &junk,
            &junk, &ujunk, &ujunk, &junk, &junk, &junk, &ujunk, &ujunk);
#endif

    fprintf(stderr, "event->x = %i\n", event->x);
    fprintf(stderr, "event->y = %i\n", event->y);
    fprintf(stderr, "event->width = %i\n", event->width);
    fprintf(stderr, "event->height = %i\n", event->height);
    
    if (event->value_mask & CWX)
        frame.origin.x = event->x;
    
    if (event->value_mask & CWY)
        frame.origin.y = event->y - [self titlebarHeight];

    if (event->value_mask & CWWidth)
        frame.size.width = event->width;

    if (event->value_mask & CWHeight)
        frame.size.height = event->height;
    
    [self setFrame:frame];
    [self gravitate];
    [self redraw];
    [self configureNotify];
}

- (void)configureNotify
{
    XEvent event;
    NSRect frame = [self frame];
    
    event.xconfigure.type = ConfigureNotify;
    event.xconfigure.event = window->xWindow;
    event.xconfigure.window = window->xWindow;
    event.xconfigure.x = frame.origin.x;
    event.xconfigure.y = frame.origin.y;
    event.xconfigure.width = frame.size.width;
    event.xconfigure.height = frame.size.height;
    event.xconfigure.border_width = [self borderWidth];
    event.xconfigure.above = None;
    event.xconfigure.override_redirect = 0;

    XSendEvent(GlobalDisplay, window->xWindow, False, StructureNotifyMask,
            &event);
}

- (void)propertyNotify:(XPropertyEvent *)event
{
    switch (event->atom) {
        // window title changed
        case XA_WM_NAME:
            [self redraw];
            break;

        // icon title changed
        case XA_WM_ICON_NAME:
            if (icon) {
            }
            break;

        // command used to start client
        case XA_WM_COMMAND:
            break;

        // 
        case XA_WM_HINTS:
            break;

        // normal geometry hints
        case XA_WM_NORMAL_HINTS:
            /*
             * 1. get WM_NORMAL_HINTS
             * 2. verify
             * 3. reset (possibly via ConfigureRequest?)
             */
            break;

        // 
        case XA_WM_TRANSIENT_FOR:
            break;

            
    }
}
        
- (void)raise
{
    IWMTRACE;

    [parent raise];
    [window takeInputFocus];
    [self redraw];
}

- (void)redraw
{
    // redraw titlebar
    if (decor.titlebar && titlebar)
        [titlebar redraw];

    // redraw resizebar
    if (decor.resizebar && resizebar)
        [resizebar redraw];
}

- (void)changeGravity:(int)aMultiplier
{
    int gravity, tmp = 0;
    XSizeHints *sizeHints = [window wmNormalHints];
    
    IWMTRACE;
    
    if (sizeHints->flags & PWinGravity)
        gravity = sizeHints->win_gravity;
    else
        gravity = NorthWestGravity;
    
    switch (gravity)
    {
        case NorthWestGravity:
        case NorthEastGravity:
        case NorthGravity:
            tmp = [self titlebarHeight];
            break;
        case CenterGravity:
            tmp = ([self titlebarHeight] / 2);
            break;
    }

    _frame.origin.y += aMultiplier * tmp;
}

- (void)gravitate
{
    [self changeGravity:1];
}

- (void)ungravitate
{
    [self changeGravity:-1];
}

- (NSPoint)gravityOffsets
{
    NSPoint offset;
    
    switch (_gravity) {	
        case ForgetGravity:
        case CenterGravity:
        case StaticGravity:
            offset.x = 0;
            offset.y = 0;
            break;
        case NorthWestGravity:
            offset.x = -1;
            offset.y = -1;
            break;
        case NorthGravity:
            offset.x = 0;
            offset.y = -1;
            break;
        case NorthEastGravity:
            offset.x = 1;
            offset.y = -1;
            break;
        case WestGravity:
            offset.x = -1;
            offset.y = 0;
            break;
        case EastGravity:
            offset.x = 1;
            offset.y = 0;
            break;
        case SouthWestGravity:
            offset.x = -1;
            offset.y = 1;
            break;
        case SouthGravity:
            offset.x = 0;
            offset.y = 1;
            break;
        case SouthEastGravity:
            offset.x = 1;
            offset.y = 1;
            break;
    }

    return offset;
}

- update
{
    [window updateWindowState];
    
    return self;
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (IWMScreen *)screen
{
    return [GlobalIWM screenNumber:_screenNumber];
}

- (IWMWindow *)window
{
    return window;
}

- (Window)transient
{
    return transient;
}

- (void)setTransient:(Window)aTransient
{
    transient = aTransient;
}

- (IWMWindow *)parent
{
    return parent;
}

- (void)setParent:(IWMWindow *)aParent
{
    IWMTRACE;
    
    [parent autorelease];
    parent = [aParent retain];
}

- (IWMTitlebar *)titlebar
{
    if (decor.titlebar && titlebar)
        return titlebar;

    return nil;
}

- (void)setTitlebar:(IWMTitlebar *)aTitlebar
{
    IWMTRACE;
    
    if (decor.titlebar)
    {
        NSPoint point;
        
        [titlebar autorelease];
        titlebar = [aTitlebar retain];
        
        point.x = 0;
        point.y = 0;
        [titlebar setInto:parent point:point];
    }
}

- (int)titlebarHeight
{
    if (decor.titlebar)
        return [[self screen] titlebarHeight];

    return 0;
}

- (IWMResizebar *)resizebar
{
    if (decor.resizebar && resizebar)
        return resizebar;

    return nil;
}

- (void)setResizebar:(IWMResizebar *)aResizebar
{
    IWMTRACE;
    
    if (decor.resizebar)
    {
        NSPoint point;
        
        [resizebar autorelease];
        resizebar = [aResizebar retain];

        point.x = GRIP_WIDTH;
        point.y = [self height] - [self resizebarHeight];
        [resizebar setInto:parent point:point];
    }
}

- (IWMIcon *)icon
{
    return icon;
}

- (void)setIcon:(IWMIcon *)anIcon
{
    [icon autorelease];
    icon = [anIcon retain];
}

- (BOOL)containsXWindow:(Window)aWindow isParent:(BOOL)isParent
{
    // if isParent is true, and the window isn't the parent
    // xWindow, then return NO immediately
    if (isParent && !(aWindow == parent->xWindow))
        return NO;
    
    // check basic windows
    if ((aWindow == window->xWindow) ||
        (aWindow == parent->xWindow) ||
        (aWindow == transient))
    {
        return YES;
    }

    // only check if titlebar exists
    if (decor.titlebar && titlebar)
    {
        if (aWindow == titlebar->xWindow)
            return YES;

        if (decor.minimize_button)
        {
            if (aWindow == ([titlebar minimizeButton])->xWindow)
                return YES;
        }

        if (decor.close_button)
        {
            if (aWindow == ([titlebar closeButton])->xWindow)
                return YES;
        }
    }

    // only check if resizebar exists
    if (decor.resizebar && resizebar)
    {
        if ((aWindow == resizebar->xWindow) ||
                (aWindow == ([resizebar leftGrip])->xWindow) ||
                (aWindow == ([resizebar rightGrip])->xWindow))
        {
            return YES;
        }
    }
    
    // only check if icon exists
    if (icon && aWindow == icon->xWindow)
        return YES;
    
    return NO;
}

- (int)resizebarHeight
{
    if (decor.resizebar)
    {
        NSString *tmp = iwm_default_value(RESIZEBAR_HEIGHT_DEFAULT);
        int       resizebarHeight = IWM_RESIZEBAR_HEIGHT;

        if (tmp && [tmp cStringLength])
        {
            resizebarHeight = atoi([tmp cString]);
        }
        
        return resizebarHeight;
    }

    return 0;
}

- (NSString *)xClass
{
    return [window xClass];
}

- (NSString *)xClassInstance
{
    return [window xClassInstance];
}

- (int)wmState
{
    return [window windowState];
}

- (void)setWMState:(int)aState
{
    IWMTRACE;

    [window setWindowState:aState];
}

- (Colormap)colormap
{
    return [window colormap];
}

- (void)setColormap:(Colormap)aColormap
{
    [window setColormap:aColormap];
}

- (int)ignoreUnmap
{
    return ignoreUnmap;
}

- (void)incrementIgnoreUnmap
{
    ignoreUnmap++;
}

- (void)decrementIgnoreUnmap
{
    ignoreUnmap--;
}

- (int)borderWidth
{
    return (decor.border ? BORDER_WIDTH : 0);
}

- (void)setBorderWidth:(int)aValue
{
    [parent setBorderWidth:aValue];
}

- (NSRect)frame
{
    return _frame;
}

- (void)setFrame:(NSRect)aRect
{
    int adjustment, windowHeight;
    NSSize windowSize;
    
    IWMTRACE;

    [self verifyFrame:aRect];
    
    XGrabServer(GlobalDisplay);
    
    adjustment = [self borderWidth] * 2;
    windowHeight = (int)aRect.size.height - [self titlebarHeight] -
        [self resizebarHeight] - adjustment;
    
    windowSize.width = (int)aRect.size.width - adjustment;
    windowSize.height = windowHeight;
    
    [parent setSize:aRect.size];
    [window setSize:windowSize];
    [parent setTopLeftPoint:aRect.origin];
    
    [self redraw];

    [self configureNotify];
    
    XUngrabServer(GlobalDisplay);
}

- (void)verifyFrame:(NSRect)aFrame
{
    int xMax = DisplayWidth(GlobalDisplay, _screenNumber);
    int yMax = DisplayHeight(GlobalDisplay, _screenNumber);

    if (minimumSize.width && (minimumSize.width > aFrame.size.width)) {
        IWMDebug(@"Correcting frame width...", nil);
        aFrame.size.width = minimumSize.width;
    }

    if (minimumSize.height && (minimumSize.height > aFrame.size.height)) {
        IWMDebug(@"Correcting frame height...", nil);
        aFrame.size.height = minimumSize.height;
    }

    if (aFrame.origin.y < 0) {
        IWMDebug(@"Correcting Y coordinate...", nil);
        aFrame.origin.y = 0;
    }

    if (aFrame.origin.y >= yMax) {
        IWMDebug(@"Correcting Y coordinate...", nil);
        aFrame.origin.y = yMax-10; //XXX 10 pixel leeway on bottom...?
    }
    
    if (aFrame.origin.x < 0) {
        IWMDebug(@"Correcting X coordinate...", nil);
        aFrame.origin.x = 0;
    }

    if (aFrame.origin.x >= xMax) {
        IWMDebug(@"Correcting X coordinate...", nil);
        aFrame.origin.x = xMax-10; //XXX 10 pixel leeway (change to mod screen)
    }
}

- (int)width
{
    return [parent width];
}

- (int)height
{
    // get the total height of the client with decor (if present)
    return ([self titlebarHeight] + [window height] + [self resizebarHeight]);
}

- (NSSize)size
{
    NSSize size;

    size.width = [parent width];
    size.height = [self titlebarHeight] + [window height] + 
        [self resizebarHeight];

    return size;
}

- (NSPoint)origin
{
    return [parent origin];
}

#ifdef SHAPE

- (int) shape
{
  return _shape;
}

- (void) setShape: (int) shape
{
  IWMTRACE;
  
  {
    XRectangle	rect;
    
    _shape = shape;
    state.shaped = YES;
    
    XShapeCombineShape(GlobalDisplay, [window xWindow] , ShapeBounding,
                       [self width], [self height] + [self width],
                       [window xWindow], ShapeBounding, ShapeSet);
    
    if( titlebar )
    {
      rect.x = [window width];
      rect.y = ([window origin]).y;
      rect.width = [window width] - 2 * [self width] + [self borderWidth];
      rect.height = [titlebar titlebarHeight];
      
      XShapeCombineRectangles(GlobalDisplay, [window xWindow] , ShapeBounding,
                              0, 0, &rect, 1, ShapeUnion, Unsorted);
    }
  }
  
  return;
}

#endif /* SHAPE */

- (BOOL)obscured
{
    return state.obscured;
}

- (void)setObscured:(BOOL)aValue
{
    state.obscured = aValue;
}

- (BOOL)hasBorder
{
    return decor.border;
}

- (BOOL)hasTitlebar
{
    return decor.titlebar;
}

- (BOOL)hasCloseButton
{
    return decor.close_button;
}

- (BOOL)hasMinimizeButton
{
    return decor.minimize_button;
}

- (BOOL)hasMaximizeButton
{
#if 0
    return decor.maximize_button;
#endif
    return NO; // keep compiler happy for now
}
 
- (BOOL)hasResizebar
{
    return decor.resizebar;
}

- (BOOL)minimized
{
    return state.minimized;
}

- (BOOL)maximized
{
    // XXX - right now we're not distinguishing...
    if (state.maximized_horz || state.maximized_vert)
        return YES;

    return NO;
}

- (BOOL)shaped
{
    return state.shaped;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<IWMClient: %@ (%i)>", [self name], 
                window->xWindow];
}

- (void)dealloc
{
    [titlebar release];
    [resizebar release];
    [window release];
    [parent release];
    [icon release];

    [super dealloc];
}

- (int)clientID
{
    return _clientID;
}

- (NSString *)name
{
    return [window name];
}

- (void)setName:(NSString *)aName;
{
    [window setName:aName];
}

- (IWMImage *)iconImage
{
    return iconImage;
}

- (void)setIconImage:(IWMImage *)anImage
{
    [iconImage autorelease];
    iconImage = [anImage retain];
}

- (int)screenNumber
{
    return _screenNumber;
}

- (void)setScreenNumber:(int)aScreen
{
    CARD32 data[1];
    BOOL make_sticky = NO;

    if (0 == aScreen)
    {
        data[0] = 0xFFFFFFFF;   // all desktops
        _screenNumber = -1;     // XXX we don't have virtual desktops yet...
        make_sticky = YES;
    }
    else
    {
        data[0] = aScreen;
        _screenNumber = aScreen;
    }

    // update _NET_WM_DESKTOP property
    [window setProperty:GlobalIWM->atoms.net_wm_desktop type:XA_CARDINAL
        format:32 data:(unsigned char *)data elements:1];

    // update _NET_WM_STATE to include _NET_WM_STATE_STICKY
    if (make_sticky)
    {
        state.sticky = YES;
        [[self window] updateWindowState];
    }
    
    IWMDebug(@"Moved client to screen %i", (aScreen) ? aScreen : -1);
}

- (void)close
{
    Atom *protocols;
    int   number, i, found = 0;
    
    IWMTRACE;
    
    [self hide];
    [icon hide];
    
    if ((protocols = [window wmProtocols:&number]))
    {
        for (i = 0; i < number; i++)
        {
            if (protocols[i] == GlobalIWM->atoms.wm_delete_window)
            {
                found++;
            }
        }
    }

    if (found)
    {
        IWMDebug(@"Sending WM_DELETE_WINDOW...", nil);
        [self sendProtocol:GlobalIWM->atoms.wm_delete_window];
    }
    else
    {
        IWMDebug(@"Killing client...", nil);
        [self kill];
    }
}

- (void)kill
{
    [self hide];
    
    XKillClient(GlobalDisplay, window->xWindow);
    XFlush(GlobalDisplay);
    
    [self dealloc];
}

- (void)display
{

    IWMTRACE;

    if (state.shaded)
        [self unshade];
    
    if (state.maximized_horz || state.maximized_vert)
        [self unmaximize];
    
    if (!state.focused)
        [self focus];

    if (state.hidden)
        [self unhide];
    
    [self redraw];
}

- (BOOL)focused
{
    return state.focused;
}

- (BOOL)modal
{
    return state.modal;
}

- (BOOL)sticky
{
    return state.sticky;
}

- (BOOL)hidden
{
    return state.hidden;
}

- (BOOL)shaded
{
    return state.shaded;
}

- (BOOL)maximizedHorizontally
{
    return state.maximized_horz;
}

- (BOOL)maximizedVertically
{
    return state.maximized_vert;
}

- (BOOL)fullscreen
{
    return state.fullscreen;
}

- (BOOL)skipTaskbar
{
    return state.skip_taskbar;
}

- (BOOL)skipPager
{
    return state.skip_pager;
}

@end


