
/*
 * $Id: IWMWindowManager.m,v 1.30 2004/06/13 06:58:31 copal Exp $
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
#include "IWMWindowManager.h"
#include "IWMClient.h"
#include "IWMWindow.h"
#include "IWMTitlebar.h"
#include "IWMScreen.h"
#include "IWMTheme.h"
#include "IWMCoreUtilities.h"
#include "IWMComponentManager.h"

#include <IWMExtensions/NSArrayExt.h>
#include <IWMExtensions/NSDictionaryExt.h>

#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSNotification.h>
#include <Foundation/NSAutoreleasePool.h>

#include <sys/types.h>
#include <unistd.h>
#include <string.h>

#include "IWMDebug.h"

@implementation IWMWindowManager

static BOOL _sensitiveHandling = NO;

//
// CBV: needed for error handling
//

#if 0
static int  _shapeRequestBase; // major opcode for error handling
static int  _shapeEventBase;   // first custom event type
static int  _shapeErrorBase;   // first custom error defined
#endif

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

- initWithDisplayName:(NSString *)aName
{
    IWMTRACE;
    
    if ((self = [super init]))
    {
        screenArray             = [[NSMutableArray alloc] init];
        clientArray             = [[NSMutableArray alloc] init];
        themePaths              = [[NSMutableArray alloc] init];
        imagePaths              = [[NSMutableArray alloc] init];
        mouseButtons.one        = DEFAULT_BUTTON_1;
        mouseButtons.two        = nil;
        mouseButtons.three      = nil;
        focusType               = IWM_FOCUS_CLICK;

        _headClientIndex        = 0;
        _windowContext          = XUniqueContext();
        
        _debug                  = NO;
        currentScreenNumber          = 0;
        _flags.opaqueMovement   = NO;
#ifdef SHAPE
        _flags.shape            = NO;
        shapeEvent              = 0; // CBV: is this shapeEventBase below?
        
        //
        // CBV: SHAPE X11 extension info
        //
        
        _shapeRequestBase	= 0;	// major opcode for error handling
        _shapeEventBase		= 0;	// first custom event type
        _shapeErrorBase		= 0;	// first custom error defined
#endif

        [self initializePaths];

        GlobalIWM = self;
        
        IWMNote(@"Trying to open display %@", aName);
        
        // CBV: only if init was successful
        if ([self initializeDisplay:aName])
        {
            [self applyOverridesToWindowManager];
            [self applyOverridesToTheme:nil];
            [self registerObservedNotifications];

            // CBV: check whether there are already mapped windows
            [self scanWindows];

            return self;
        }

        return nil;
    }
    
    return nil;
}

/*==========================================================================*
   INITIALIZATION STAGES
 *==========================================================================*/

- (BOOL)initializePaths
{
    NSString    *home;
    id           tmp;
    
    IWMTRACE;

    home = NSHomeDirectory();
    
    /*
     * initialize theme paths
     */

    // default: ~/GNUstep/Libary/InterfaceWM/Themes
    tmp = [home stringByAppendingPathComponent:INTERFACE_THEME_DIR];
    [[self themePaths] addObject:tmp];
    
    // additional theme paths
    if ((tmp = [self valueForDefaultsKey:THEME_DIRECTORIES]))
    {
        [[self themePaths] addObjectsFromArray:tmp];
    }

    /*
     * initialize image paths
     */

    // default:  ~/GNUstep/Library/InterfaceWM/Images
    tmp = [home stringByAppendingPathComponent:INTERFACE_IMAGE_DIR];
    [[self imagePaths] addObject:tmp];

    // additional image paths
    if ((tmp = [self valueForDefaultsKey:IMAGE_DIRECTORIES]))
    {
        [[self imagePaths] addObjectsFromArray:tmp];
    }

    return YES;
}

- (BOOL)initializeSignalHandlers
{
    IWMTRACE;
    
    // CBV: Keep a copy of the old handlers to be re-set when IWM terminates
    _oldX11ErrorHandler = XSetErrorHandler(handle_xerror);
    _oldXIOErrorHandler = XSetIOErrorHandler(XIO_Handler);
    
    signal(SIGINT, signal_handler);
    signal(SIGHUP, signal_handler);
    
    return YES;
}

- (void)resetSignalHandlers
{
    IWMTRACE;
    
    XSetErrorHandler(_oldX11ErrorHandler);
    XSetIOErrorHandler(_oldXIOErrorHandler);
  
    signal(SIGTERM, SIG_DFL);
    signal(SIGINT, SIG_DFL);
    signal(SIGHUP, SIG_DFL);
}

- (void)initializeAtoms
{
    IWMTRACE;
    
    /* standard */
    
    atoms.wm_state = iwm_atom("WM_STATE");
    atoms.wm_change_state = iwm_atom("WM_CHANGE_STATE");
    atoms.wm_protocols = iwm_atom("WM_PROTOCOLS");
    atoms.wm_delete_window = iwm_atom("WM_DELETE_WINDOW");
    atoms.wm_colormap_windows = iwm_atom("WM_COLORMAP_WINDOWS");
        
    /* EWMH root window */
    
    atoms.net_supported = iwm_atom("_NET_SUPPORTED");
    atoms.net_client_list = iwm_atom("_NET_CLIENT_LIST");
    atoms.net_client_list_stacking = iwm_atom("_NET_CLIENT_LIST_STACKING");
    atoms.net_number_of_desktops= iwm_atom("_NET_NUMBER_OF_DESKTOPS");
    atoms.net_desktop_geometry = iwm_atom("_NET_DESKTOP_GEOMETRY");
    atoms.net_desktop_viewport = iwm_atom("_NET_DESKTOP_VIEWPORT");
    atoms.net_current_desktop = iwm_atom("_NET_CURRENT_DESKTOP");
    atoms.net_desktop_names = iwm_atom("_NET_DESKTOP_NAMES");
    atoms.net_active_window = iwm_atom("_NET_ACTIVE_WINDOW");
    atoms.net_workarea = iwm_atom("_NET_WORKAREA");
    atoms.net_supporting_wm_check = iwm_atom("_NET_SUPPORTING_WM_CHECK");
    atoms.net_virtual_roots = iwm_atom("_NET_VIRTUAL_ROOTS");
    atoms.net_desktop_layout = iwm_atom("_NET_DESKTOP_LAYOUT");
    atoms.net_showing_desktop = iwm_atom("_NET_SHOWING_DESKTOP");
    
    /* supplemental EWMH root window */
    
    atoms.net_close_window = iwm_atom("_NET_CLOSE_WINDOW");
    atoms.net_moveresize_window = iwm_atom("_NET_MOVERESIZE_WINDOW");
    atoms.net_wm_moveresize = iwm_atom("_NET_WM_MOVERESIZE");

    /* EWMH application window */
    
    atoms.net_wm_name = iwm_atom("_NET_WM_NAME");
    atoms.net_wm_visible_name = iwm_atom("_NET_WM_VISIBLE_NAME");
    atoms.net_wm_icon_name = iwm_atom("_NET_WM_ICON_NAME");
    atoms.net_wm_visible_icon_name = iwm_atom("_NET_WM_VISIBLE_ICON_NAME");
    atoms.net_wm_desktop = iwm_atom("_NET_WM_DESKTOP");

    // window type
    atoms.net_wm_window_type = iwm_atom("_NET_WM_WINDOW_TYPE");
    atoms.net_wm_window_type_desktop = iwm_atom("_NET_WM_WINDOW_TYPE_DESKTOP");
    atoms.net_wm_window_type_dock = iwm_atom("_NET_WM_WINDOW_TYPE_DOCK");
    atoms.net_wm_window_type_toolbar = iwm_atom("_NET_WM_WINDOW_TYPE_TOOLBAR");
    atoms.net_wm_window_type_menu = iwm_atom("_NET_WM_WINDOW_TYPE_MENU");
    atoms.net_wm_window_type_utility = iwm_atom("_NET_WM_WINDOW_TYPE_UTILITY");
    atoms.net_wm_window_type_splash = iwm_atom("_NET_WM_WINDOW_TYPE_SPLASH");
    atoms.net_wm_window_type_dialog = iwm_atom("_NET_WM_WINDOW_TYPE_DIALOG");
    atoms.net_wm_window_type_normal = iwm_atom("_NET_WM_WINDOW_TYPE_NORMAL");

    // XXX THIS IS A TEMPORARY HACK FOR GNUSTEP APPS THAT USE THIS ATOM
    atoms.kde_net_wm_window_type_override = iwm_atom("_KDE_NET_WM_WINDOW_TYPE_OVERRIDE");
    
    // state
    atoms.net_wm_state = iwm_atom("_NET_WM_STATE");
    atoms.net_wm_state_modal = iwm_atom("_NET_WM_STATE_MODAL");
    atoms.net_wm_state_sticky = iwm_atom("_NET_WM_STATE_STICKY");
    atoms.net_wm_state_maximized_vert = 
        iwm_atom("_NET_WM_STATE_MAXIMIZED_VERT");
    atoms.net_wm_state_maximized_horz = 
        iwm_atom("_NET_WM_STATE_MAXIMIZED_HORZ");
    atoms.net_wm_state_shaded = iwm_atom("_NET_WM_STATE_SHADED");
    atoms.net_wm_state_skip_taskbar = iwm_atom("_NET_WM_STATE_SKIP_TASKBAR");
    atoms.net_wm_state_skip_pager = iwm_atom("_NET_WM_STATE_SKIP_PAGER");
    atoms.net_wm_state_hidden = iwm_atom("_NET_WM_STATE_HIDDEN");
    atoms.net_wm_state_fullscreen = iwm_atom("_NET_WM_STATE_FULLSCREEN");
    atoms.net_wm_state_above = iwm_atom("_NET_WM_STATE_ABOVE");
    atoms.net_wm_state_below = iwm_atom("_NET_WM_STATE_BELOW");

    // allowed action atoms
    atoms.net_wm_allowed_actions = iwm_atom("_NET_WM_ALLOWED_ACTIONS");
    atoms.net_wm_action_move = iwm_atom("_NET_WM_ACTION_MOVE");
    atoms.net_wm_action_resize = iwm_atom("_NET_WM_ACTION_RESIZE");
    atoms.net_wm_action_minimize = iwm_atom("_NET_WM_ACTION_MINIMIZE");
    atoms.net_wm_action_shade = iwm_atom("_NET_WM_ACTION_SHADE");
    atoms.net_wm_action_stick = iwm_atom("_NET_WM_ACTION_STICK");
    atoms.net_wm_action_maximize_horz = 
        iwm_atom("_NET_WM_ACTION_MAXIMIZE_HORZ");
    atoms.net_wm_action_maximize_vert = 
        iwm_atom("_NET_WM_ACTION_MAXIMIZE_VERT");
    atoms.net_wm_action_fullscreen = iwm_atom("_NET_WM_ACTION_FULLSCREEN");
    atoms.net_wm_action_change_desktop = 
        iwm_atom("_NET_WM_ACTION_CHANGE_DESKTOP");
    atoms.net_wm_action_close = iwm_atom("_NET_WM_ACTION_CLOSE");

    atoms.net_wm_strut = iwm_atom("_NET_WM_STRUT");
    atoms.net_wm_icon_geometry = iwm_atom("_NET_WM_ICON_GEOMETRY");
    atoms.net_wm_icon = iwm_atom("_NET_WM_ICON");
    atoms.net_wm_pid = iwm_atom("_NET_WM_PID");
    atoms.net_wm_handled_icons = iwm_atom("_NET_WM_HANDLED_ICONS");

    /* EWMH window manager */

    atoms.net_wm_ping = iwm_atom("_NET_WM_PING");
    
           
    /* MOTIF */

    atoms.motif_wm_hints = iwm_atom("_MOTIF_WM_HINTS");

    /* InterfaceWM */

    atoms.iwm_window_type = iwm_atom("_IWM_WINDOW_TYPE");
    atoms.iwm_window_type_unknown = iwm_atom("_IWM_WINDOW_TYPE_UNKNOWN");
    atoms.iwm_window_type_root_window =
        iwm_atom("_IWM_WINDOW_TYPE_ROOT_WINDOW");
    atoms.iwm_window_type_client_window =
        iwm_atom("_IWM_WINDOW_TYPE_CLIENT_WINDOW");
    atoms.iwm_window_type_parent_window =
        iwm_atom("_IWM_WINDOW_TYPE_PARENT_WINDOW");
    atoms.iwm_window_type_titlebar = iwm_atom("_IWM_WINDOW_TYPE_TITLEBAR");
    atoms.iwm_window_type_close_button =
        iwm_atom("_IWM_WINDOW_TYPE_CLOSE_BUTTON");
    atoms.iwm_window_type_minimize_button =
        iwm_atom("_IWM_WINDOW_TYPE_MINIMIZE_BUTTON");
    atoms.iwm_window_type_maximize_button =
        iwm_atom("_IWM_WINDOW_TYPE_MAXIMIZE_BUTTON");
    atoms.iwm_window_type_resizebar = iwm_atom("_IWM_WINDOW_TYPE_RESIZEBAR");
    atoms.iwm_window_type_left_grip = iwm_atom("_IWM_WINDOW_TYPE_LEFT_GRIP");
    atoms.iwm_window_type_right_grip = iwm_atom("_IWM_WINDOW_TYPE_RIGHT_GRIP");
    atoms.iwm_window_type_icon = iwm_atom("_IWM_WINDOW_TYPE_ICON");
    atoms.iwm_window_type_reference = iwm_atom("_IWM_WINDOW_TYPE_REFERENCE");
    
    /* GNUstep */
    
    atoms.gnustep_wm_attr = iwm_atom("_GNUSTEP_WM_ATTR");
    atoms.gnustep_wm_miniaturizable_window = 
        iwm_atom("_GNUSTEP_WM_MINIATURIZABLE_WINDOW");
    atoms.gnustep_titlebar_state = iwm_atom("_GNUSTEP_TITLEBAR_STATE");
    
    return (void)0x0;
}

- (BOOL)initializeDisplay:(NSString *)aDisplay
{
    IWMScreen *aScreen = nil;
    
    IWMTRACE;

    // initialize signal handlers for IWM
    if (![self initializeSignalHandlers])
    {
        NSLog(@"Failed to initialize signal handlers.");

        return NO;
    }

    // open display & populate $DISPLAY variable in user's environment
    if (!(GlobalDisplay = iwm_display_open(aDisplay)))
    {
        NSLog(@"Failed to open display %@.", aDisplay);

        return NO;
    }

    // atoms
    [self initializeAtoms];
    
    //
    // check for screens
    //
    
#if 1

    {
      int	count = ScreenCount(GlobalDisplay);
      int	number = DefaultScreen(GlobalDisplay);
      BOOL	singleScreen = NO;
      
      //
      // no screens at all?
      //
      
      if( 0 >= count )
      {
        NSLog(@"This display has no screen");
        iwm_display_close(GlobalDisplay);
        
        return NO;
      }
      
      //
      // the following if() isn't really necessary, but we might
      // want to add a -s(ingle screen) option later
      //
      
      if( singleScreen )
      {
        switch( count )
        {
          //
          // There only is 1 screen anyway
          //
          case 1 :
            singleScreen = YES;
            IWMNote(@"Display supports only one screen", nil);
            break;
          
          //
          // multiple screens
          //
          default:
            {
              int	dpy = -1;
              int	scr = -1;
              char	*dpyName = (char *)[aDisplay cString];
              char	*str = ( dpyName ? strchr(dpyName, ':') : NULL );
              
              //
              // ...but user requested only one screen by specifying
              // -d :<display>.<screen>
              //
              if( str && 2 == sscanf(str, ":%i.%i", &dpy, &scr) )
              {
                singleScreen = YES;
                number = [[aDisplay pathExtension] intValue];
                
                IWMNote(@"Using specified screen \"%d\"", number);
              }
              //
              // -d :<display>[.] given, try all screens on <display> 
              //
              else
                IWMNote(@"Trying to use all %d screens on \"%s\"",
                        count, dpyName);
            }
            break;
        }
      }
      
      //
      // again, only one screen, either it's the default, or the one
      // specified
      //
      if( singleScreen )
      {
        aScreen = [[IWMScreen alloc] initWithScreenNumber: number];
        
        if( aScreen )
          [screenArray addObject: aScreen];
        
        currentScreenNumber = number;
      }
      //
      // multiple screens, so loop and init each
      //
      else
      {
        for( number = 0; number < count; number++ )
        {
          aScreen = [[IWMScreen alloc] initWithScreenNumber: number];
          
          if( aScreen )
            [screenArray addObject: aScreen];
        }
        
        currentScreenNumber = 0;
      }
      
      //
      // D'uh! couldn't init any screen
      //
      if( 0 == [screenArray count] )
      {
        NSLog(@"Could not manage any screen");
        iwm_display_close(GlobalDisplay);
        
        return NO;
      }
    }

#else /* 1 */

    // determine which screen we are initializing
    if ((currentScreenNumber = ([screenArray count] - 1)) < 0)
    {
        currentScreenNumber = 0;
    }

    // initialize first IWMScreen
    if (!(aScreen = [[IWMScreen alloc] initWithScreenNumber:currentScreenNumber]))
    {
        NSLog(@"Failed to initialize screen.");

        return NO;
    }

    // add screen to screen array
    [screenArray addObject:aScreen];

#endif /* 1 */

#ifdef SHAPE
    _flags.shape =
      XQueryExtension(GlobalDisplay, "SHAPE",
                      &_shapeRequestBase, &_shapeEventBase, &_shapeErrorBase);
#endif /* SHAPE */

    return YES;
}

/*
 * clients may have already been mapped before IWM was started; these need to
 * be remapped and decorated
 */
- (void)scanWindows
{
    unsigned int    nchildren, i = 0, j = 0;
    Window          root;
    Window          parent;
    Window         *children;
    
    IWMTRACE;
    
    if ((None == XQueryTree(GlobalDisplay, [[self currentScreen] rootXWindow],
                           &root, &parent, &children, &nchildren)))
    {
        return (void)0x0;
    }
    
    for (i = 0; i < nchildren; i++)
    {
        XWMHints *wmhintsp;
        
        if (children[i] && (wmhintsp = XGetWMHints(GlobalDisplay, children[i])))
        {
            if (wmhintsp && (wmhintsp->flags & IconWindowHint))
            {
                for (; j < nchildren; j++)
                {
                    if (children[j] == wmhintsp->icon_window)
                    {
                        children[j] = None;
                        break;
                    }
                }

                XFree ((caddr_t) wmhintsp);
            }
        }
    }

    // remap client present before IWM was started
    for (i = 0; i < nchildren; i++)
    {
        if (children[i] && iwm_mapped_not_override(self, children[i]))
        {
            XEvent event;
            
            XUnmapWindow(GlobalDisplay, children[i]);
            
            event.xmaprequest.window = children[i];
            
            [self handleMapRequestEvent:&event];
        }
    }

    if (0 < nchildren)
        XFree((caddr_t)children);
  
    return (void)0x0;
}

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/


- (Atom)typeForWindow:(Window)window
{
    return iwm_window_type(window);
}

- (void)runCommand:(NSString *)command
{
    pid_t pid;

    IWMTRACE;

    IWMDebug(@"command: %@", command);

    pid = fork();

    switch (pid)
    {
        case 0:
            execlp("/bin/sh", "sh", "-c", [command cString], NULL);
            NSLog(@"exec failed.");
            exit(EXIT_FAILURE);

        case -1:
            NSLog(@"Can't fork process.");
    }

    return (void)0x0;
}

/*
 * main run loop
 */
- (void)run
{
    IWMTRACE;
    
    XEvent event;
        
    for (;;)
    {
        XNextEvent(GlobalDisplay, &event);
        [self handleEvent:&event];
    }
}

/*
 * quit
 */
- (void)quit
{
    NSLog(@"Quitting...");

    [clientArray release];
    [screenArray release];
    [mouseButtons.one release];
    [mouseButtons.two release];
    [mouseButtons.three release];
    
    //
    // CBV: To terminate nicely/cleanly, we need to re-set X11's
    //      error handler and the signal(s)
    //
    
    [self resetSignalHandlers];
    
    iwm_display_close(GlobalDisplay);
    
    exit(EXIT_SUCCESS);
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setButton1:(id)aCommand
{
    mouseButtons.one = aCommand;
}

- (void)setButton2:(id)aCommand
{
    mouseButtons.two = aCommand;
}

- (void)setButton3:(id)aCommand
{
    mouseButtons.three = aCommand;
}

- (void)setOpaqueMovement:(BOOL)opaque
{
    _flags.opaqueMovement = opaque;
}

/*==========================================================================*
   INDIRECT ACCESSOR METHODS
 *==========================================================================*/

- (XPoint)mousePosition
{
    return iwm_mouse_position(NULL);
}

- (IWMWindow *)rootWindow
{
    return [[self currentScreen] rootWindow];
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (BOOL)opaqueMovement
{
    return _flags.opaqueMovement;
}

- (IWMFocusType)focusType
{
    return focusType;
}

- (XContext)windowContext
{
    return _windowContext;
}

+ (BOOL) getSensitiveHandling
{
    return _sensitiveHandling;
}

+ (void) setSensitiveHandling: (BOOL) flag
{
    if( _sensitiveHandling != flag )
        _sensitiveHandling = flag;
  
    return;
}

- (void)dealloc
{
    [screenArray release];
    [themePaths release];
    [imagePaths release];

    [super dealloc];
}

/*==========================================================================*
   C FUNCTIONS
 *==========================================================================*/

/* private */
static
void _print_x11_error(NSString *message, Display *display, XErrorEvent *event)
{
  char *dbtext = malloc(BUFSIZ),
       *errtext = malloc(BUFSIZ),
       *number = malloc(32);
  
  sprintf(number, "%d", event->request_code);
  
  XGetErrorDatabaseText(display, "XRequest", number, "", dbtext, BUFSIZ);
  XGetErrorText(display, event->error_code, errtext, BUFSIZ);
  
  IWMWarn(@"%@\n\t%s\n"
          @"\t\t   on display: %s\n"
          @"\t     offending caller: %s\n"
          @"\t   request major code: %d\n"
          @"\t   request minor code: %d\n"
          @"\t\t  resource ID: 0x%lx\n"
          @"\t\tserial number: %ld\n"
          @"\tcurrent serial number: %ld",
          message,
          errtext,
          DisplayString(display),
          dbtext,
          event->request_code,
          event->minor_code,
          event->resourceid,
          event->serial,
          LastKnownRequestProcessed(display) + 1);
  
  free(number);
  free(errtext);
  free(dbtext);
  
  return;
}

void signal_handler(int signal)
{
    NSLog(@"ERROR: caught signal %i.  Exiting.", signal);
    [GlobalIWM quit];

    return (void)0x0;
}

int handle_xerror(Display *display, XErrorEvent *event)
{
    IWMClient *client = nil;

    //
    // CBV: This error handler will only work correctly AFTER
    //      IWMWindowManager is fully initialized and GlobalIWM
    //      is set
    //

    client = [GlobalIWM clientWithWindow:event->resourceid isParent:NO];

    if ( (event->error_code == BadAccess) &&
         ( _sensitiveHandling ||
           (event->resourceid ==
               RootWindow(display, [[GlobalIWM rootWindow] xWindow])) ) )
    {
        NSLog(@"Root window unavailable.  Exiting.");
        [GlobalIWM quit];
        
        exit(EXIT_FAILURE);
    }
    
    // CBV: Is it an X11 Extension error?
    else if( X_NoOperation < event->request_code )
    {
#ifdef SHAPE
      // Don't care about SHAPE...
      if( ([GlobalIWM shapeRequestBase] == event->request_code) &&
          (BadWindow == event->error_code) )
        return 0;
#endif
      
      // ...but about all others
      _print_x11_error(@"X extension error", display, event);
    }
    
    //
    // CBV: This is potentially dangerous.
    //      IWM should sort out whether the error is fatal or just a warning
    //
    
    else 
    {
        _print_x11_error(@"X protocol error", display, event);
    }
    
    if (client) 
    {
        //[[GlobalIWM clientArray] removeObject:client];
    }
    
    return 0;
}

int XIO_Handler(Display *dpy)
{
    NSLog(@"Connection to display %s lost", XDisplayString(dpy));
    [GlobalIWM quit];
    exit(EXIT_FAILURE);
  
    // Keep compiler happy...
    return 0;
}

@end

