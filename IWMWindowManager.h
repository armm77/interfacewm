
/*
 * $Id: IWMWindowManager.h,v 1.22 2004/06/13 06:58:31 copal Exp $
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

#ifndef _IWMWINDOWMANAGER_H_
#define _IWMWINDOWMANAGER_H_    1

#include "InterfaceWM.h"

#define BOOL XWINDOWSBOOL
#    include <Foundation/NSObject.h>
#    include <Foundation/NSGeometry.h>
#undef BOOL

@class IWMClient, IWMWindow, IWMScreen, IWMTheme;
@class NSString, NSMutableArray, NSMutableDictionary, NSNotification;

/*!
 * @class IWMWindowManager
 * @abstract The core window manager class
 */
@interface IWMWindowManager : NSObject
{
    NSMutableArray      *screenArray;
    NSMutableArray      *clientArray;
    NSMutableArray      *themePaths;
    NSMutableArray      *imagePaths;
    
    IWMFocusType         focusType;

    struct {                                    // button commands
        id one, two, three;
    } mouseButtons;

@public
    IWMAtomStruct atoms;
    int currentScreenNumber;
    
@private
    unsigned int         _headClientIndex;
    XContext             _windowContext;
    BOOL                 _debug;
    int                  _currentScreen;
    int                  (* _oldX11ErrorHandler)();
    int                  (* _oldXIOErrorHandler)();
    
    struct {
        unsigned int opaqueMovement : 1;
#ifdef SHAPE
        unsigned int shape : 1;
#endif
    } _flags;

#ifdef SHAPE
    int                  shapeEvent;
    int			_shapeRequestBase; // major opcode for error handling
    int			_shapeEventBase;   // first custom event type
    int			_shapeErrorBase;   // first custom error defined
#endif
}

/*==========================================================================*
   GLOBAL VARIABLES
 *==========================================================================*/

IWMWindowManager *GlobalIWM;
Display          *GlobalDisplay;
Time              GlobalTimestamp;
Time              GlobalLastButtonClick;
Window            GlobalLastEventWindow;
Window            GlobalLastButtonClickWindow;

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

/*!
 * @method initWithDisplayName:
 * @param aName A display name (i.e. 0:1)
 * @discussion Designated initializer.
 */
- initWithDisplayName:(NSString *)aName;

/*==========================================================================*
   INITIALIZATION STAGES
 *==========================================================================*/

/*!
 * @method initializePaths
 * @abstract Initializes internal paths to themes and images
 */
- (BOOL)initializePaths;

- (BOOL)initializeSignalHandlers;
- (void)resetSignalHandlers;

/*!
 * @method initializeAtoms
 * @abstract Initializes all atoms recognized by Interface WM
 */
- (void)initializeAtoms;

/*!
 * @method initialzeDisplay:
 * @abstract Initializes named display
 * @param aDisplay Named display
 */
- (BOOL)initializeDisplay:(NSString *)aDisplay;

/*!
 * @method scanWindows
 * @abstract Scans for any previously mapped windows & remaps them into IWM
 */
- (void)scanWindows;

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

/*!
 * @method typeForWindow:
 * @param window An X Window
 * @discussion Returns the type of the provided window
 */
- (Atom)typeForWindow:(Window)window;

/*!
 * @method runCommand:
 * @abstract Fork process to run given command
 * @param command Command to run
 */
- (void)runCommand:(NSString *)command;

/*!
 * @method run
 * @abstract Start InterfaceWM
 */
- (void)run;

/*!
 * @method quit
 * @abstract Quit InterfaceWM
 */
- (void)quit;

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

/*!
 * @method setButton1:
 * @discussion Sets the command to run when mouse button 1 is pressed
 */
- (void)setButton1:(id)aCommand;

/*!
 * @method setButton2:
 * @discussion Sets the command to run when mouse button 2 is pressed
 */
- (void)setButton2:(id)aCommand;

/*!
 * @method setButton2:
 * @discussion Sets the command to run when mouse button 3 is pressed
 */
- (void)setButton3:(id)aCommand;

/*!
 * @method setOpaqueMovement:
 * @discussion Sets whether or not clients should be moved opaquely (default:
 * <b>NO</b>)
 * @param opaque
 */
- (void)setOpaqueMovement:(BOOL)opaque;

/*==========================================================================*
   INDIRECT ACCESSOR METHODS
 *==========================================================================*/

/*!
 * @method mousePosition
 * @discussion Returns the current position of the cursor
 */
- (XPoint)mousePosition;

/*!
 * @method rootWindow
 * @discussion Returns the IWMWindow object for the root window
 */
- (IWMWindow *)rootWindow;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (BOOL)opaqueMovement;
- (IWMFocusType)focusType;

- (XContext)windowContext;

+ (BOOL)getSensitiveHandling;
+ (void)setSensitiveHandling:(BOOL)flag;

/*==========================================================================*
   C FUNCTIONS
 *==========================================================================*/

void signal_handler(int signal);
int handle_xerror(Display *display, XErrorEvent *event);
int XIO_Handler(Display *dpy);

@end

@interface IWMWindowManager (ScreenMethods)

/*!
* @method currentScreen
 * @discussion Returns the current IWMScreen object
 */
- (IWMScreen *)currentScreen;

    /*!
    * @method screenNumber:
     * @param aScreen A screen number
     * @discussion Returns the IWMScreen object for the given screen number
     */
- (IWMScreen *)screenNumber:(unsigned int)aScreen;

- (NSMutableArray *)screenArray;

@end

/*
 * THEME METHODS
 */

@interface IWMWindowManager (ThemeMethods)

/*!
* @method applyOverridesToTheme:
 * @discussion Applies defaults settings to the provided theme
 * @param aTheme An IWMTheme
 */
- (void)applyOverridesToTheme:(IWMTheme *)aTheme;

    /*!
    * @method loadThemeAtPath:
     * @discussion Loads the IWMTheme specified by the provided path
     * @param path A fully qualified path
     */
- (BOOL)loadThemeAtPath:(NSString *)path;

    /*!
 * @method loadThemeNamed:
     * @discussion Searches for and loads the theme with the provided name
     * @param themeName An IWMTheme name
     */
- (BOOL)loadThemeNamed:(NSString *)themeName;

- (IWMTheme *)theme;
- (NSMutableArray *)themePaths;
- (NSMutableArray *)imagePaths;

@end

/*==========================================================================* 
DEFAULTS METHODS
*==========================================================================*/

@interface IWMWindowManager (DefaultsMethods)

/*!
* @method applyOverridesToWindowManager
 * @discussion Applies defaults settings to the window manager
 */
- (void)applyOverridesToWindowManager;

    /*!
    * @method currentDefaults
     * @abstract Returns a current copy of the InterfaceWM defaults
     */
- (NSDictionary *)currentDefaults;

    /*!
    * @method valueForDefaultsKey:
     * @abstract Obtains the value for a single default in the InterfaceWM defaults
     * @discussion Returns nil if the value is not present or is empty
     * @param key Target default name
     */
- (id)valueForDefaultsKey:(NSString *)key;

    /*!
       * @method setValue:forDefaultsKey:
     * @abstract Sets the value for a single default in the InterfaceWM defaults
     * @param value Target default value
     * @param key Target default name
     */
- (void)setValue:(id)value forDefaultsKey:(NSString *)key;

- (void)saveDefaults;

@end

/*
 * CLIENT MANAGEMENT
 */

@interface IWMWindowManager (ClientMethods)

/*!
* @method addClient:
 * @discussion Adds the provided client to the internal array of managed clients
 * @param aClient An IWMClient
 */
- (void)addClient:(IWMClient *)aClient;

    /*!
 * @method removeClient:
     * @discussion Closes the provided client and removes it from the array of managed
     * clients
     * @param aClient An IWMClient
     */
- (void)removeClient:(IWMClient *)aClient;

    /*!
    * @method headClient
     * @discussion Returns the head client
     */
- (IWMClient *)headClient;

    /*!
    * @method setHeadClient:
     * @discussion Sets the provided client as the head client
     * @param aClient An IWMClient
     */
- (void)setHeadClient:(IWMClient *)aClient;

    /*!
    * @method cycleClients
     * @discussion Cycles the clients on the screen
     */
- (void)cycleClients;

- (void)clientIsClosing:(IWMClient *)aClient;


    /*!
    * @method updateClientWindowList
     * @discussion Called to update the _NET_CLIENT_LIST property
     */
- (void)updateClientWindowList;

    /*!
    * @method clientWindowList
     * @discussion Returns the client window list as stored in the _NET_CLIENT_LIST property
     */
- (Window *)clientWindowList;


    /*!
    * @method clientNames
     * @discussion Returns an NSArray of all client names
     */
- (NSArray *)clientNames;

    /*!
    * @method longestClientName
     * @discussion Returns the longest name of all current clients
     */
- (NSString *)longestClientName;

    /*!
    * @method clientWithID:
     * @param anID A unique client ID
     * @discussion Returns the IWMClient with the provided unique ID
     */
- (IWMClient *)clientWithID:(int)anID;

- (IWMClient *)clientWithWindow:(Window)window isParent:(BOOL)isParent;

@end

@interface IWMWindowManager (IconMethods)

/*!
* @method availableIconCoordinates
 * @abstract Returns the first available coordinates for icons
 * @discussion Coordinates are based on icon width/height defaults
 */
- (NSRect)availableIconCoordinates;

@end

@interface IWMWindowManager (ShapeMethods)

#ifdef SHAPE
- (BOOL)shape;
- (int)shapeEvent;
- (int)shapeRequestBase;
- (int)shapeEventBase;
- (int)shapeErrorBase;
#endif

@end

/*==========================================================================*
   EventMethods
 *==========================================================================*/

@interface IWMWindowManager (EventMethods)

/*
 * Server grabbing
 */

- (BOOL)grabPointerAndServer;
- (void)ungrabPointerAndServer;

/*
 * Time caching
 */

- (void)cacheEventTime:(XEvent *)event;

/*
 * Event handling
 */

- (void)handleEvent:(XEvent *)event;

- (void)handleKeyPressEvent:(XEvent *)anEvent;
- (void)handleKeyReleaseEvent:(XEvent *)anEvent;
- (void)handleKeyReleaseEvent:(XEvent *)anEvent;
- (void)handleButtonPressEvent:(XEvent *)anEvent;
- (void)handleButtonReleaseEvent:(XEvent *)anEvent;
- (void)handleClientMessageEvent:(XEvent *)anEvent;
- (void)handleColormapChangeEvent:(XEvent *)anEvent;
- (void)handleConfigureNotifyEvent:(XEvent *)anEvent;
- (void)handleConfigureRequestEvent:(XEvent *)anEvent;
- (void)handleEnterEvent:(XEvent *)anEvent;
- (void)handleExposeEvent:(XEvent *)anEvent;
- (void)handleMapRequestEvent:(XEvent *)anEvent;
- (void)handleMapNotifyEvent:(XEvent *)anEvent;
- (void)handlePropertyNotifyEvent:(XEvent *)anEvent;
- (void)handleReparentNotifyEvent:(XEvent *)anEvent;
- (void)handleDestroyNotifyEvent:(XEvent *)anEvent;
- (void)handleUnmapNotifyEvent:(XEvent *)anEvent;
- (void)handleVisibilityNotifyEvent:(XEvent *)anEvent;
#ifdef SHAPE
- (void)handleShapeChangeEvent:(XEvent *)anEvent;
#endif

@end

/*==========================================================================*
   NotificationMethods
 *==========================================================================*/

@interface IWMWindowManager (NotificationMethods)

- (void)registerObservedNotifications;
- (IWMClient *)obtainClientFromInfo:(NSDictionary *)info;

- changeClientName:(NSNotification *)notification;

- focusClient:(NSNotification *)notification;
- unfocusClient:(NSNotification *)notification;

- resizeClient:(NSNotification *)notification;
- moveClient:(NSNotification *)notification;
- moveResizeClient:(NSNotification *)notification;

- changeClientScreen:(NSNotification *)notification;
- didChangeClientScreen:(NSNotification *)notification;

- closeClient:(NSNotification *)notification;
- didCloseClient:(NSNotification *)notification;

- minimizeClient:(NSNotification *)notification;
- didMinimizeClient:(NSNotification *)notification;
- unminimizeClient:(NSNotification *)notification;
- didUnminimizeClient:(NSNotification *)notification;

- maximizeClient:(NSNotification *)notification;
- didMaximizeClient:(NSNotification *)notification;
- unmaximizeClient:(NSNotification *)notification;
- didUnmaximizeClient:(NSNotification *)notification;

- hideClient:(NSNotification *)notification;
- didHideClient:(NSNotification *)notification;
- unhideClient:(NSNotification *)notification;
- didUnhideClient:(NSNotification *)notification;

- shadeClient:(NSNotification *)notification;
- didShadeClient:(NSNotification *)notification;
- unshadeClient:(NSNotification *)notification;
- didUnshadeClient:(NSNotification *)notification;

@end

#endif /* _IWMWINDOWMANAGER_H_ */

