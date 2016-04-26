
/*
 * $Id: IWMWindowManager+Event.m,v 1.19 2004/06/02 01:29:59 copal Exp $
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

#include "IWMWindowManager.h"
#include "InterfaceWM.h"
#include "IWMWindow.h"
#include "IWMClient.h"
#include "IWMScreen.h"
#include "IWMDebug.h"
#include "IWMCoreUtilities.h"

#include <sys/wait.h>

#ifdef DEBUG
static char *event_names[] =
	{
	"",			/*  0 */
	"",
	"KeyPress",
	"KeyRelease",
	"ButtonPress",
	"ButtonRelease",	/*  5 */
	"MotionNotify",
	"EnterNotify",
	"LeaveNotify",
	"FocusIn",
	"FocusOut",		/* 10 */
	"KeymapNotify",
	"Expose",
	"GraphicsExpose",
	"NoExpose",
	"VisibilityNotify",	/* 15 */
	"CreateNotify",
	"DestroyNotify",
	"UnmapNotify",
	"MapNotify",
	"MapRequest",		/* 20 */
	"ReparentNotify",
	"ConfigureNotify",
	"ConfigureRequest",
	"GravityNotify",
	"ResizeRequest",	/* 25 */
	"CirculateNotify",
	"CirculateRequest",
	"PropertyNotify",
	"SelectionClear",
	"SelectionRequest",	/* 30 */
	"SelectionNotify",
	"ColormapNotify",
	"ClientMessage",
	"MappingNotify"
	};
#endif

#ifdef NEW_HANDLER
static IWMClient *client = nil;
static int lastEventButton = 0,
static int lastEventTime = 0;
static BOOL nextDoubleClick = NO;
static Window lastEventWindow = 0;
#endif

@implementation IWMWindowManager (EventMethods)

#ifdef NEW_HANDLER
static BOOL isDoubleClick(XEvent *event)
{
  // FIXME: use double-click default from UserDefaults
  if( (lastEventTime > 0 ) &&
      (event->xbutton.time - lastEventTime <= DEFAULT_DOUBLE_CLICK ) &&
      (event->xbutton.button == lastEventButton) &&
      (event->xbutton.window == lastEventWindow) )
  {
    lastEventTime = 0;
    lastEventWindow = event->xbutton.window;
    
    nextDoubleClick = YES;
    
    return YES;
  }
  
  return NO;
}
#endif

/*
 * pointer/server grabbing
 */

- (BOOL)grabPointerAndServer
{
    IWMScreen *screen = [self currentScreen];
    
    if (XGrabPointer(GlobalDisplay, [screen rootXWindow], False,
                IWM_EVENT_MASK_MOUSE, GrabModeAsync, GrabModeAsync, None,
                [screen normalCursor], CurrentTime) == GrabSuccess)
    {
        XGrabServer(GlobalDisplay);
        
        return YES;
    }

    return NO;
}

- (void)ungrabPointerAndServer
{
    XUngrabServer(GlobalDisplay);
    XUngrabPointer(GlobalDisplay, CurrentTime);
}

/*
 * time caching
 */

- (void)cacheEventTime:(XEvent *)event
{
    Time NewTimestamp = CurrentTime;
    
    switch (event->type) {
        case KeyPress:
        case KeyRelease:
            NewTimestamp = event->xkey.time;
            break;
            
        case ButtonPress:
            GlobalLastButtonClick = event->xbutton.time; // cache button clicks
            GlobalLastButtonClickWindow = event->xbutton.window; // cache clicked window
            NewTimestamp = event->xbutton.time;
            break;
            
        case ButtonRelease:
            NewTimestamp = event->xbutton.time;
            break;
            
        case MotionNotify:
            NewTimestamp = event->xmotion.time;
            break;
            
        case EnterNotify:
        case LeaveNotify:
            NewTimestamp = event->xcrossing.time;
            break;
            
        case PropertyNotify:
            NewTimestamp = event->xproperty.time;
            break;
            
        case SelectionClear:
            NewTimestamp = event->xselectionclear.time;
            break;

        case SelectionRequest:
            NewTimestamp = event->xselectionrequest.time;
            break;
            
        case SelectionNotify:
            NewTimestamp = event->xselection.time;
            break;
            
        case FocusIn:
        case FocusOut:
        case KeymapNotify:
        case Expose:
        case GraphicsExpose:
        case NoExpose:
        case VisibilityNotify:
        case CreateNotify:
        case DestroyNotify:
        case UnmapNotify:
        case MapNotify:
        case MapRequest:
        case ReparentNotify:
        case ConfigureNotify:
        case ConfigureRequest:
        case GravityNotify:
        case ResizeRequest:
        case CirculateNotify:
        case CirculateRequest:
        case ColormapNotify:
        case ClientMessage:
        case MappingNotify:
        default:
            return (void)0x0;
    }
    
    if ((NewTimestamp > GlobalTimestamp) || 
            ((GlobalTimestamp - NewTimestamp) > 30000))
    {
        GlobalTimestamp = NewTimestamp;
    }
}

/*
 * event handling
 */

- (void)handleEvent:(XEvent *)event
{  
    GlobalLastEventWindow = event->xany.window;

    switch (event->type)
    {
        case KeyPress:
            [self handleKeyPressEvent:event];
            break;
            
	case KeyRelease:
            //[self handleKeyReleaseEvent:event];
	    break;

        case ButtonPress:
            [self handleButtonPressEvent:event];
            break;
            
        case ButtonRelease:
            [self handleButtonReleaseEvent:event];
            break;
            
        case MotionNotify:
            //[self handleMotionNotifyEvent:event];
            break;
            
        case EnterNotify:
            [self handleEnterEvent:event]; 
            break;
            
        case LeaveNotify:
            //[self handleLeaveNotifyEvent:event];
            break;
            
        case FocusIn:
        case FocusOut:
            break;
            
        case KeymapNotify:
            //[self handleKeymapNotify:event];
            break;
            
        case Expose:
            [self handleExposeEvent:event]; 
            break;

        case GraphicsExpose:
            //[self handleGraphicsExposeEvent:event];
            break;

        case NoExpose:
            //[self handleNoExposeEvent:event];
            break;

        case VisibilityNotify:
            [self handleVisibilityNotifyEvent:event];
            break;

        case CreateNotify:
            //[self handleCreateNotifyEvent:event];
            break;

        case DestroyNotify:
            [self handleDestroyNotifyEvent:event]; 
            break;
            
        case UnmapNotify:
            [self handleUnmapNotifyEvent:event]; 
            break;
            
        case MapNotify:
            [self handleMapNotifyEvent:event];
            break;
            
        case MapRequest:
            [self handleMapRequestEvent:event]; 
            break;
        
        case ReparentNotify:
            // [self handleReparentNotifyEvent:event];
            break;

        case ConfigureNotify:
            [self handleConfigureNotifyEvent:event];
            break;

        case ConfigureRequest:
            [self handleConfigureRequestEvent:event];
            break;
            
        case GravityNotify:
            //[self handleGravityNotifyEvent:event];
            break;

        case ResizeRequest:
            //[self handleResizeRequestEvent:event];
            break;

        case CirculateNotify:
        case CirculateRequest:
            break;

        case PropertyNotify:
            [self handlePropertyNotifyEvent:event]; 
            break;

        case SelectionClear:
        case SelectionRequest:
        case SelectionNotify:
            break;
            
        case ColormapNotify:
        [self handleColormapChangeEvent:event]; 
            break;
            
        case ClientMessage:
            [self cacheEventTime:event];
            [self handleClientMessageEvent:event]; 
            break;
            
        case MappingNotify:
            //[self handleMappingNotifyEvent:event];
            break;
            
        default:
#ifdef SHAPE 
            if (_flags.shape && event->type == shapeEvent)
            {
                [self handleShapeChange:event];
            }
            else
#else
            {
                if (event->type < LASTEvent)
                    IWMWarn(@"Unexpected event %s", event_names[event->type]);
                else
                    IWMError(@"Unknown event %d", event->type);
            }
#endif
    }

    return (void)0x0;
}

- (void)handleKeyPressEvent:(XEvent *)anEvent
{
}

- (void)handleKeyReleaseEvent:(XEvent *)anEvent
{
}

- (void)handleButtonPressEvent:(XEvent *)anEvent
{
    XButtonEvent *event = &anEvent->xbutton;
    Atom         type;
    IWMClient   *client = nil;
    int          double_click = NO;
    
    IWMTRACE;

    type = [self typeForWindow:event->window];
    client = [self clientWithWindow:event->window isParent:NO];
    
    // set double_click flag if time between clicks doesn't exceed limit & both
    // clicks took place in the same window
    if (((event->time - GlobalLastButtonClick) < 250) &&
            (event->window == GlobalLastButtonClickWindow))
    {
        double_click = YES;
    }
    
    // now we can update GlobalLastButtonClick & GlobalLastButtonClickWindow
    // with the current event data
    
    {
      XEvent ev;
      
      // Fake an XEvent, we need the event's type, the window and the time
      
      ev.type = event->type;
      ev.xbutton.window = event->window;
      ev.xbutton.time = event->time;
      
      [self cacheEventTime: &ev];
    }

    GlobalLastButtonClickWindow = event->window;
    
    if (client)
    {
        [self setHeadClient:client];
    }
    
    // root window
    if (type == atoms.iwm_window_type_root_window)
    {
        switch (event->button)
        {
            case Button1:
                [self runCommand:mouseButtons.one];
                break;
            case Button2:
                //[self runCommand:mouseButtons.two];
                [self cycleClients];
                break;
            case Button3:
                [self runCommand:mouseButtons.three];
                break;
        }

        return (void)0x0;
    }
    
    // client window
    else if (type == atoms.iwm_window_type_client_window)
    {
        switch (event->button)
        {
            case Button1:
                [client raise];
                [self setHeadClient:client];
                break;
            case Button2:
                break;
            case Button3:
                break;
        }
        
        return (void)0x0; 
    }
    
    // client titlebar
    else if (type == atoms.iwm_window_type_titlebar)
    {
        // shade client if titlebar was double-clicked
        if (double_click)
        {
            [client shade];
        }
        else
        {
            [client raise];        
            [client move];
            [self setHeadClient:client];
        }
    }
    
    // client resizebar
    else if (type == atoms.iwm_window_type_resizebar)
    {
        [client resize:NO];
    }
    
    // client resizebar grip
    else if ((type == atoms.iwm_window_type_left_grip) ||
            (type == atoms.iwm_window_type_right_grip))
    {
        fprintf(stderr, "-> resizing client window...\n");
        [client resize:YES];
    }
    
    // close button
    else if (type == atoms.iwm_window_type_close_button)
    {
        IWMDebug(@"close button pushed...", nil);
        [self removeClient:client];
    }
    
    // minimize button
    else if (type == atoms.iwm_window_type_minimize_button)
    {
        [client minimize];
    }
    
    // maximize button
    else if (type == atoms.iwm_window_type_maximize_button)
    {
        [client maximize];
    }
    
    // client icon
    else if (type == atoms.iwm_window_type_icon)
    {
        // unhide/unminimize/unshade client if icon is double-clicked
        if (double_click)
        {
            if ([client hidden])
                [client unhide];
                
            if ([client minimized])
                [client unminimize];
                
            if ([client shaded])
                [client unshade];
        }
        
        [client raise];
        [client move];
        [self setHeadClient:client];
    }
    
    // unknown window type
    else if (type == atoms.iwm_window_type_unknown)
    {
        // XXX - should never get here
        NSLog(@"-> IWM_WINDOW_TYPE_UNKNKOWN");
    }
    
    //lastEventTime = event->xbutton.time;
    //lastEventButton = event->xbutton.button;
    //GlobalLastEventWindow = event->xbutton.window;

    return (void)0x0;
}

- (void)handleButtonReleaseEvent:(XEvent *)anEvent
{
}

- (void)handleClientMessageEvent:(XEvent *)anEvent
{
    XClientMessageEvent *event = &anEvent->xclient;
    IWMClient   *client = nil;
    Atom         action = event->data.l[0];
    //
    // CBV: those two are unused
    // Atom         property_1 = event->data.l[1];
    // Atom         property_2 = event->data.l[2];
    
    IWMTRACE;
    
    client = [self clientWithWindow:event->window isParent:NO];

    if (client)
    {
        IWMDebug(@"ClientMessage: %s",
                XGetAtomName(GlobalDisplay, event->message_type));

        // WM_PROTOCOLS
        if (event->message_type == atoms.wm_protocols)
        {
            // WM_DELETE_WINDOW: close window
            if (action == atoms.wm_delete_window)
            {
                NSLog(@"*** WM_DELETE_WINDOW message...");
                [self removeClient:client];
            }

            // WM_TAKE_FOCUS: re-assign keyboard focus (Xlib Vol. 1, pg. 421)
            else if (action == atoms.wm_take_focus)
            {
                [[client window] takeInputFocus];
            }

            // WM_SAVE_YOURSELF
            else if (action == atoms.wm_save_yourself)
            {
                // XXX currently unimplemented
            }
        }
        
        // WM_CHANGE_STATE
        else if (event->message_type == atoms.wm_change_state)
        {
            if (IconicState == action)
            {
                [client minimize];
            }
            if (NormalState == action)
            {
                [client display];
            }
        }

        // _NET_CLOSE_WINDOW: close a client
        else if (event->message_type == atoms.net_close_window)
        {
            [self removeClient:client];
        }
        
        // _NET_MOVERESIZE_WINDOW: prefered over ConfigureRequest
        else if (event->message_type == atoms.net_moveresize_window)
        {
            int gravity;
            NSRect frame;

            gravity = event->data.l[0];     // XXX not used right now
            frame.origin.x = event->data.l[1];
            frame.origin.y = event->data.l[2];
            frame.size.width = event->data.l[3];
            frame.size.height = event->data.l[4];

            [client setFrame:frame];
        }

        // _NET_WM_MOVERESIZE: client initiated movement
        else if (event->message_type == atoms.net_wm_moveresize)
        {
        }

        // _NET_WM_DESKTOP: change desktop client is on
        else if (event->message_type == atoms.net_wm_desktop)
        {
            [client setScreenNumber:event->data.l[0]];
        }

        // _NET_CURRENT_DESKTOP: change the virtual desktop being shown
        else if (event->message_type == atoms.net_current_desktop)
        {
            int screen;
            
            screen = event->data.l[0];

            // XXX currently unimplemented
        }

        // _NET_SHOWING_DESKTOP: toggle view of desktop without clients
        else if (event->message_type == atoms.net_showing_desktop)
        {
            // XXX currently unimplemented
        }

        // _NET_DESKTOP_VIEWPORT: large desktops are not part of IWM
        else if (event->message_type == atoms.net_desktop_viewport)
        {
            // XXX ignored in IWM XXX //
        }

        // _NET_DESKTOP_GEOMETRY: desktop geometry changes are not part of IWM
        else if (event->message_type == atoms.net_desktop_geometry)
        {
            // XXX ignored in IWM XXX //
        }

        // _NET_NUMBER_OF_DESKTOPS: change number of desktops
        else if (event->message_type == atoms.net_number_of_desktops)
        {
            int newNumber;
            
            newNumber = event->data.l[0];

            // XXX currently unimplemented
        }

        // _NET_ACTIVE_WINDOW: set a client to active (focused)
        else if (event->message_type == atoms.net_active_window)
        {
            [client focus];
        }

        // _NET_WM_STATE: change state of a client (1 or 2 states at a time)
        //
        // according to the EWMH spec, the first element in the event->data.l
        // is one of the following:
        //
        // _NET_WM_STATE_REMOVE, _NET_WM_STATE_ADD, or _NET_WM_STATE_TOGGLE
        //
        // these are supposed to be (respectively) 0, 1 and 2.  the other two
        // allowable elements are the _NET_WM_STATE properties to be modified.
        else if (event->message_type == atoms.net_wm_state)
        {
            int  i;
            // CBV: modification is unused
            // Atom modification = event->data.l[0];
            Atom property;
            
            for (i = 0; i < 2; i++)
            {
                property = event->data.l[++i];
                
                if (property)
                //if (NULL != property)
                {
#if 0
                    if (property == atoms.net_wm_state_modal)
                    {
                        _WM_STATE_MOD(desc->state.modal, modification);
                    }
                    else if (property == atoms.net_wm_state_sticky)
                    {
                        _WM_STATE_MOD(desc->state.sticky, modification);
                    }
                    else if (property == atoms.net_wm_state_maximized_vert)
                    {
                        _WM_STATE_MOD(desc->state.maximized_vert, modification);
                    }
                    else if (property == atoms.net_wm_state_maximized_horz)
                    {
                        _WM_STATE_MOD(desc->state.maximized_horz, modification);
                    }
                    else if (property == atoms.net_wm_state_shaded)
                    {
                        _WM_STATE_MOD(desc->state.shaded, modification);
                    }
                    else if (property == atoms.net_wm_state_skip_taskbar)
                    {
                        _WM_STATE_MOD(desc->state.skip_taskbar, modification);
                    }
                    else if (property == atoms.net_wm_state_skip_pager)
                    {
                        _WM_STATE_MOD(desc->state.skip_pager, modification);
                    }
                    else if (property == atoms.net_wm_state_hidden)
                    {
                        _WM_STATE_MOD(desc->state.hidden, modification);
                    }
                    else if (property == atoms.net_wm_state_fullscreen)
                    {
                        _WM_STATE_MOD(desc->state.fullscreen, modification);
                    }
                    else if (property == atoms.net_wm_state_above)
                    {
                        _WM_STATE_MOD(desc->state.above, modification);
                    }
                    else if (property == atoms.net_wm_state_below)
                    {
                        _WM_STATE_MOD(desc->state.below, modification);
                    }
#endif /* 0 */
                }
            }

            // rebuild the window state hints array
            [[client window] updateWindowState];
        }
    }
}

- (void)handleColormapChangeEvent:(XEvent *)anEvent
{
    XColormapEvent *event = &anEvent->xcolormap;
    IWMClient *client = nil;
    
    IWMTRACE;
    
    client = [self clientWithWindow:event->window isParent:NO];

    if (client && event->new)
    {
        [client setColormap:event->colormap];
        XInstallColormap(GlobalDisplay, event->colormap);
    }
}

- (void)handleConfigureNotifyEvent:(XEvent *)anEvent
{
}

- (void)handleConfigureRequestEvent:(XEvent *)anEvent
{
    XConfigureRequestEvent *event = &anEvent->xconfigurerequest;
    IWMClient           *client = nil;
    XWindowChanges       changes;
    
    IWMTRACE;
    
    if (!(client = [self clientWithWindow:event->window isParent:NO]))
    {
        //client = [self headClient];
    }

    if (client)
    {
        [client configureRequest:event];
    }
    else
    {
        changes.x           = event->x;
        changes.y           = event->y;
        changes.width       = event->width;
        changes.height      = event->height;
        changes.sibling     = event->above;
        changes.stack_mode  = event->detail;
        
        XConfigureWindow(GlobalDisplay, event->window, event->value_mask,
                &changes);
    }
}

- (void)handleEnterEvent:(XEvent *)anEvent
{
    XCrossingEvent *event = &anEvent->xcrossing;
    IWMClient *client = nil;
    
    if ((client = [self clientWithWindow:event->window isParent:NO]))
    {
        XGrabButton(GlobalDisplay, AnyButton, Mod1Mask, 
                ([client parent])->xWindow,
                False, IWM_EVENT_MASK_BUTTON, GrabModeAsync, GrabModeAsync, 
                None, None);

        // normal focus
        if (focusType == IWM_FOCUS_MOUSE || !(focusType == IWM_FOCUS_CLICK))
            [client focus];
        
        // sloppy focus: keep stacking order, but allow input into window
        else if (focusType == IWM_FOCUS_SLOPPY)
            [[client window] takeInputFocus];
    }
}

- (void)handleExposeEvent:(XEvent *)anEvent
{
    XExposeEvent *event = &anEvent->xexpose;
    IWMClient *client = [self clientWithWindow:event->window isParent:YES];
    
    if (client && (0 == event->count))
    {
        [client redraw];
    }
}

- (void)handleMapRequestEvent:(XEvent *)anEvent
{
    XMapRequestEvent *event = &anEvent->xmaprequest;
    IWMClient *client = nil;
    
    IWMTRACE;
    
    XFlush(GlobalDisplay);
    
    if ((client = [self clientWithWindow:event->window isParent:NO]))
    {
        [self setHeadClient:client];
    }
    else
    {
        char *name;
        
        XFetchName(GlobalDisplay, event->window, &name);
        
        NSLog(@"New client: %s", name);

        // initialize client with window
        client = [[IWMClient alloc] initWithWindow:event->window
            onScreen:_currentScreen];
        
        // add to client array, making new head client
        [self addClient:client];
    }
    
    XSync(GlobalDisplay, False);
}

- (void)handleMapNotifyEvent:(XEvent *)anEvent
{
    XMapEvent *event = &anEvent->xmap;
    IWMClient *client = nil;
    
    if ((client = [self clientWithWindow:event->window isParent:NO]))
    {
        if (client && [client window] && (([client window])->xWindow == event->event))
        {
            IWMDebug(@"handleMapNotify for client: %@", client);
            XGrabServer(GlobalDisplay);
            [client display];
            [client setWMState:NormalState];
            XUngrabServer(GlobalDisplay);
        }
    }
    
    return (void)0x0;
}

- (void)handlePropertyNotifyEvent:(XEvent *)anEvent
{
    XPropertyEvent *event = &anEvent->xproperty;
    IWMClient *client = nil;
    
    if ((client = [self clientWithWindow:event->window isParent:NO]))
    {
        switch (event->atom){
            //case atoms.net_wm_name:
            case XA_WM_NAME:
                //[[client parent] clear];
                [client redraw];
                break;

            case XA_WM_TRANSIENT_FOR:
                [client setTransient:[[client window] transient]];
                break;

            case XA_WM_NORMAL_HINTS:
                //[client setSizeHints:[[client window] wmNormalHints]];
                break;

            case XA_WM_HINTS:
                //new_hints = XGetWMHints([screen display],
                  //      [[client window]xWindow]);
                break;

            default:
                break;
        }

        if (XA_WM_NAME == event->atom)
            IWMWarn(@"WM_NAME has changed!!!!", nil);
        else if (event->atom == atoms.wm_state)
            IWMWarn(@"WM_STATE changed", nil);
        else if( event->atom == atoms.iwm_window_type )
            IWMWarn(@"IWM_WINDOW_TYPE changed",nil);
        else if( event->atom == atoms.net_wm_state )
            IWMWarn(@"NET_WM_STATE changed",nil);
        else if( event->atom == atoms.wm_protocols )
            IWMWarn(@"WM_PROTOCOLS changed",nil);
        else if( event->atom == atoms.wm_colormap_windows )
            IWMWarn(@"WM_COLORMAP_WINDOWS changed",nil);
        else if( event->atom == atoms.gnustep_wm_attr )
            IWMWarn(@"GNUSTEP_WM_ATTR changed",nil);
        else
            IWMWarn(@"%s changed", XGetAtomName(GlobalDisplay, event->atom));
    }
}

- (void)handleReparentNotifyEvent:(XEvent *)anEvent;
{
}

- (void)handleDestroyNotifyEvent:(XEvent *)anEvent
{
}

- (void)handleUnmapNotifyEvent:(XEvent *)anEvent
{
#if 0
    //
    // Quick-hack fix to unmap windows, note that this hack doesn't adhere
    // to the ICCCM (yet ;-)
    //
    
    XUnmapEvent *event = &anEvent->xunmap;
    
    IWMTRACE;
    
    XGrabServer(GlobalDisplay);
    {
        XEvent	dummy;
        Window	dumwin;
        int		dstx, dsty;
        IWMScreen	*screen;
        
        if (XCheckTypedWindowEvent(GlobalDisplay, event->window, DestroyNotify,
                    &dummy))
        {
            dummy.type = event->type;
            dummy.xdestroywindow.window = event->window;
            
            [self handleDestroyNotifyEvent:&dummy];
            XUngrabServer(GlobalDisplay);
            
            return;
        }
        
        screen = [self currentScreen];
        
        if (XTranslateCoordinates(GlobalDisplay, event->window, screen->rootXWindow,
                    0, 0, &dstx, &dsty, &dumwin))
        {
            XEvent	dummy;
            Bool	reparented;
            IWMClient	*client = [self clientWithWindow: event->window isParent: NO];
            
            reparented = XCheckTypedWindowEvent(GlobalDisplay, event->window,
                    ReparentNotify, &dummy);
            
            [client setWMState: WithdrawnState];
            
            if( reparented )
            {
                if( [client borderWidth] )
                    XSetWindowBorderWidth(GlobalDisplay, event->window,
                            [client borderWidth]);
            }
            else
            {
                Window		junk;
                XWindowChanges	xwc;
                unsigned int	bw, mask;
                int		x, y, w, h, d;
                
                if( XGetGeometry(GlobalDisplay, event->window, &junk,
                            &xwc.x, &xwc.y, &w, &h, &bw, &d) )
                {
                    XTranslateCoordinates(GlobalDisplay, event->window,
                            screen->rootXWindow, xwc.x, xwc.y, &x, &y, &junk);
                    xwc.x = x;
                    xwc.y = y;
                    xwc.border_width = [client borderWidth];
                    mask = (CWX | CWY | CWBorderWidth);
                    
                    XReparentWindow(GlobalDisplay, event->window, screen->rootXWindow,
                            xwc.x, xwc.y);
                    
                    XConfigureWindow(GlobalDisplay, event->window, mask, &xwc);
                    XSync(GlobalDisplay, 0);
                }
            }
            
            //XRemoveFromSaveSet(GlobalDisplay, event->window);
            XSelectInput(GlobalDisplay, event->window, NoEventMask);
            
            dummy.type = event->type;
            dummy.xdestroywindow.window = event->window;
            
            [self handleDestroyNotifyEvent:&dummy];
        }
    }
    XUngrabServer(GlobalDisplay);
    
    XFlush(GlobalDisplay);
#endif
#if 1
    // XXX - from WindowMaker
    XUnmapEvent *event = &anEvent->xunmap;
    IWMClient *client = [self clientWithWindow:event->window isParent:NO];
    IWMWindow *clientWindow = nil;
    BOOL withdraw = NO;

    if (!client)
        return (void)0x0;
    else
        clientWindow = [client window];
    
    if ((event->event == ([self rootWindow])->xWindow) && event->send_event)
        withdraw = YES;

    if ((event->event != clientWindow->xWindow) && !withdraw)
        return (void)0x0;

    if ((![client focused] && !withdraw) &&
            ([client screenNumber] == [[GlobalIWM currentScreen] screenNumber]) &&
            (![client minimized] && ![client hidden]))
    {
        return (void)0x0;
    }

    XGrabServer(GlobalDisplay);
    
    [client hide];
    
    XSync(GlobalDisplay, 0);
    
    // check if window was destroyed
    if (XCheckTypedWindowEvent(GlobalDisplay, clientWindow->xWindow, 
                DestroyNotify, anEvent))
    {
        //DispatchEvent(anEvent);
        [self handleEvent:anEvent];
    }
    else
    {
        BOOL reparented = NO;

        if (XCheckTypedWindowEvent(GlobalDisplay, clientWindow->xWindow, 
                    ReparentNotify, anEvent))
        {
            reparented = YES;
        }
        
        if (!reparented)
            [client setWMState:WithdrawnState];

        [client close];
    }

    XUngrabServer(GlobalDisplay);
#endif
}

- (void)handleVisibilityNotifyEvent:(XEvent *)anEvent
{
    XVisibilityEvent *event = &anEvent->xvisibility;
    IWMClient *client = nil;

    IWMTRACE;

    if ((client = [self clientWithWindow:event->window isParent:NO]))
        [client setObscured:(event->state == VisibilityFullyObscured)];
    
    return (void)0x0;
}

#ifdef SHAPE
- (void)handleShapeChangeEvent:(XEvent *)anEvent
{
}
#endif /* SHAPE */

@end

