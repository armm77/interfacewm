
/*
 * $Id: IWMCoreUtilities.m,v 1.16 2003/11/21 04:16:12 copal Exp $
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
#include "IWMWindow.h"
#include "IWMScreen.h"

#include <Foundation/NSString.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSAutoreleasePool.h>

#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>

#include "IWMDebug.h"
#include "IWMCoreUtilities.h"

void *_iwm_malloc(long nbytes, const char *filename, int line)
{
    void *pointer;

    pointer = malloc(nbytes);
    if (NULL == (pointer = malloc(nbytes)))
    {
        NSLog(@"_iwm_malloc failed: %s (line %i)", filename, line);
        return NULL;
    }

    return pointer;
}

void _iwm_free(void *pointer, const char *filename, int line)
{
    if (!pointer)
    {
        NSLog(@"_iwm_free unnecessary: %s (line %i)", filename, line);
    }
    else
    {
        free(pointer);
    }
}

XPoint iwm_mouse_position(IWMWindow *target)
{
    Window               root_return;
    Window               child_return;
    XPoint               point;
    int                  root_x;
    int                  root_y;
    int                  target_x;
    int                  target_y;
    unsigned int         tmp;
    Window               _window;

    // if the targetWindow was not specified, set the root window to target
    if ((nil == target))
    {
        _window  = [[GlobalIWM currentScreen] rootXWindow];
    }
    else
    {
        _window  = [target xWindow];
    }

    // query X for current mouse position
    XQueryPointer(GlobalDisplay, _window, &root_return, &child_return, &root_x,
            &root_y, &target_x, &target_y, &tmp);

    // populate point with coordinates relative to the target window
    point.x = target_x;
    point.y = target_y;

    return point;
}

void iwm_populate_env_display(Display *display)
{
    int len = strlen(XDisplayString(display));
    char *d = malloc(len);
    
    sprintf(d, "DISPLAY=%s", XDisplayString(display));
    putenv(d);

    return (void)0x0;
}

Display *iwm_display_open(NSString *displayName)
{
#if 1
  {
    Display	*dpy;
    char	*dpyName = IWM_MALLOC(BUFSIZ);
    
    dpyName = (char *) [displayName cString];
    
    if( NULL == (dpy = XOpenDisplay(dpyName)) )
    {
      NSLog(@"Cannot open display \"%s\"", dpyName);
      return NULL;
    }
    else if( 11 > ProtocolVersion(dpy) )
    {
      NSLog(@"This X server (v%d) is too old, at least v11 is required",
            ProtocolVersion(dpy));
      iwm_display_close(dpy);
      
      return NULL;
    }
    else if( -1 == fcntl(ConnectionNumber(dpy), F_SETFD, FD_CLOEXEC) )
    {
      NSLog(@"Cannot disinherit TCP file descriptor");
      iwm_display_close(dpy);
      
      return NULL;
    }
    
    iwm_populate_env_display(dpy);
    
    return dpy;
  }
#else
    Display     *display;
    
    // Zap children
    while ((waitpid(-1, NULL, WNOHANG)) > 0);
    
    if ((display = XOpenDisplay([displayName cString])))
    {
        iwm_populate_env_display(display);

        return display;
    }
#endif

    return NULL;
}

void iwm_display_close(Display *display)
{
    //
    // CBV: Only close the display, if we opened it. Otherwise we'll get a
    //      core dump.
    //
    
    if( display )
    {
      // FIXME: free cursors
      
      XSetInputFocus(display, PointerRoot, RevertToPointerRoot, CurrentTime);
      XSync(display, False);
      
      XCloseDisplay(display);
    }
}

/*
 * grab pointer and server
 */
BOOL iwm_grab_pointer_and_server(void)
{
    IWMScreen *screen = [GlobalIWM currentScreen];
    
    if (XGrabPointer(GlobalDisplay, [screen rootXWindow], False,
                IWM_EVENT_MASK_MOUSE, GrabModeAsync, GrabModeAsync, None,
                [screen normalCursor], CurrentTime) == GrabSuccess)
    {
        XGrabServer(GlobalDisplay);
        
        return YES;
    }

    return NO;
}

void iwm_ungrab_pointer_and_server(void)
{
    XUngrabServer(GlobalDisplay);
    XUngrabPointer(GlobalDisplay, CurrentTime);
}

BOOL iwm_verify_screen(int screenNumber)
{
    if (None == XRootWindowOfScreen(
                    XScreenOfDisplay(GlobalDisplay, screenNumber)))
    {
        return NO;
    }

    return YES;
}

void iwm_send_message_to_window(IWMWindow *window, Atom atom, long data)
{
    XEvent event;

    event.type                  = ClientMessage;
    event.xclient.window        = [window xWindow];
    event.xclient.message_type  = atom;
    event.xclient.format        = 32;
    event.xclient.data.l[0]     = data;
    event.xclient.data.l[1]     = CurrentTime;
    
    XSendEvent(GlobalDisplay, [window xWindow], False, NoEventMask, &event);
    XSync(GlobalDisplay, False);
}

int iwm_mapped_not_override(IWMWindowManager *windowManager, Window window)
{
    XWindowAttributes    attr;
    Atom                 type;
    int                  format;
    unsigned long        numItems, bytes_remain;
    unsigned char       *properties;
    BOOL                 isIconicState = DontCareState;
    
    if (!(XGetWindowAttributes(GlobalDisplay, window, &attr)))
    {
        return False;
    }

    if (XGetWindowProperty(GlobalDisplay, window, windowManager->atoms.wm_state,
                0L, 3L, False, windowManager->atoms.wm_state, &type, &format,
                &numItems, &bytes_remain, &properties) == Success)
    {
        if (NULL != properties)
        {
            isIconicState = *(long *)properties;
            XFree((caddr_t)properties);
        }
    }

    return (((isIconicState == IconicState) || (attr.map_state != IsUnmapped))
            && (attr.override_redirect != True));
}

/*
 * display dimentions
 */
int iwm_display_width(IWMScreen *screen)
{
    return (DisplayWidth(GlobalDisplay, [screen screenNumber]));
}

int iwm_display_height(IWMScreen *screen)
{
    return (DisplayHeight(GlobalDisplay, [screen screenNumber]));
}

void iwm_free_gc(Display *display, GC gc)
{
    if (gc)
    {
        XFreeGC(display, gc);
        gc = NULL;
    }
}

void iwm_draw_circle(IWMWindow *window, int x, int y, int diameter)
{
    XDrawArc(GlobalDisplay, [window xWindow], [[window screen] invertGC],
            x, y, diameter, diameter, 0, (360 * 64));
}

id iwm_default_value(NSString *key)
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults      *defaults = nil;
    id                   result = nil;

    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    result = [[defaults persistentDomainForName:INTERFACE_DEFAULTS]
                    objectForKey:key];

    [pool release];
    
    return result;
}

Atom iwm_atom(const char *name)
{
    return XInternAtom(GlobalDisplay, name, False);
}

unsigned char *iwm_window_property(Window window, Atom property, Atom type,
        int *count)
{
    Atom                 type_ret;
    unsigned long        nitems_ret, bytes_after;
    unsigned char       *data = NULL;
    int                  format_ret;

#if 0
    IWMDebug(@"Property search: 0x%x {%s, %s}",
             (int)window, XGetAtomName(GlobalDisplay, property),
             XGetAtomName(GlobalDisplay, type));
#endif

    if ((XGetWindowProperty(GlobalDisplay, window, property, 0,
            0x7fffffff, False, type, &type_ret, &format_ret, &nitems_ret,
            &bytes_after, &data)) == Success && data)
    {
        if ((data) && (nitems_ret > 0) && (format_ret > 0))
        {
            if (count)
                *count = nitems_ret;

            return data;
        }
    }

    XFree(data);

    return NULL;
}

void iwm_change_window_property(Window window, Atom property, Atom type,
        int format, unsigned char *data, int nelements, int mode)
{
    if (format >= 16)
    {
        XChangeProperty(GlobalDisplay, window, property, type, format, mode,
                (char *)data, nelements);
    }
    else
    {
        XChangeProperty(GlobalDisplay, window, property, type, format, mode,
                data, nelements);
    }
}

Atom iwm_window_type(Window window)
{
    Atom *atom;
    int   tmp;
    
    if ((atom = (Atom *)iwm_window_property(window,
                    GlobalIWM->atoms.iwm_window_type, XA_ATOM, &tmp)))
    {
        return atom[0];
    }

    fprintf(stderr, "---> Window has no IWM_WINDOW_TYPE...\n");
    
    return (Atom) NULL;
}

