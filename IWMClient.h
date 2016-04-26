
/*
 * $Id: IWMClient.h,v 1.26 2004/06/17 05:38:57 copal Exp $
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

#ifndef _IWMCLIENT_H_
#define _IWMCLIENT_H_   1

#include "InterfaceWM.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#undef BOOL

#include <Foundation/NSGeometry.h>

@class IWMWindowManager, IWMScreen, IWMWindow, IWMTitlebar, IWMResizebar;
@class IWMIcon, IWMImage;
@class NSMutableDictionary;

/*!
 * @class IWMClient
 * An application's client structure
 */
@interface IWMClient : NSObject
{
    IWMWindow    *parent;                // parent window of all windows
    IWMWindow    *window;                // application window
    IWMTitlebar  *titlebar;
    IWMResizebar *resizebar;
    IWMIcon      *icon;
    IWMImage     *iconImage;
    Window        transient;
    int           ignoreUnmap;

    NSSize        minimumSize;
    NSSize        maximumSize;
    NSSize        resizeIncrements;
    int           _gravity;
    
    struct {
        unsigned int border : 1;
        unsigned int resizebar : 1;
        unsigned int titlebar : 1;
        unsigned int close_button : 1;
        unsigned int minimize_button : 1;
        unsigned int icon : 1;
    } decor;
    
    struct {
        unsigned int focused : 1;
        unsigned int modal :1;
        unsigned int sticky : 1;
        unsigned int hidden : 1;
        unsigned int shaded : 1;
        unsigned int minimized : 1;
        unsigned int maximized_horz : 1;
        unsigned int maximized_vert : 1;
        unsigned int fullscreen : 1;
        unsigned int skip_taskbar : 1;
        unsigned int skip_pager : 1;
        unsigned int above : 1;
        unsigned int below : 1;
        unsigned int obscured : 1;
        unsigned int shaped : 1;
    } state;

    struct {
        unsigned int app : 1;   // belongs to a GNUstep application
        unsigned int menu : 1;  // is the menu for the GNUstep application
        unsigned int icon : 1;  // is the icon for the GNUstep application
    } gnustep;

@private
    int         _clientID;
    int         _screenNumber;
    NSRect      _frame;
    NSRect      _cached_size;
    NSRect      _outline;
    int		_shape;	// form of shape
}

/*==========================================================================*
   INITIALIZATION METHODS
 *==========================================================================*/

/*!
 * @method initWithWindow:onScreen:
 * @discussion Designated initializer.
 * @param aWindow The application X window
 * @param aScreen The screen number
 */
- initWithWindow:(Window)aWindow onScreen:(int)aScreenNumber;

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

/*!
 * @method drawOutline
 * @discussion Draws the outline of a client during resizing/movement
 */
- (void)drawOutline;

/*!
 * @method windowForXWindow:
 * @discussion Returns the IWMWindow object wrapping the provided X window if
 * it is present in the client's window hierarchy.
 * @param aWindow An X Window
 */
- (IWMWindow *)windowForXWindow:(Window)aWindow;

- (void)sendProtocol:(Atom)atom;

/*==========================================================================*
   CORE MANIPULATION METHODS
 *==========================================================================*/

/*!
 * @method hide
 * @discussion Hides the client
 */
- (void)hide;

/*!
 * @method unhide
 * @discussion Un-hides the client
 */
- (void)unhide;

/*!
 * @method shade
 * @discussion Shades the client, leaving only titlebar visible
 */
- (void)shade;

/*!
 * @method unshade
 * @discussion Un-shades the client
 */
- (void)unshade;

/*!
 * @method focus
 * @discussion Focuses the client
 */
- (void)focus;

/*!
 * @method unfocus
 * @discussion Un-focuses the client
 */
- (void)unfocus;

- (void)configureRequest:(XConfigureRequestEvent *)event;
- (void)configureNotify;

- (void)raise;
- (void)redraw;
- (void)display;

- (void)changeGravity:(int)aMultiplier;
- (void)gravitate;
- (void)ungravitate;

- (NSPoint)gravityOffsets;

- update;

- (void)close;
- (void)kill;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (IWMScreen *)screen;
- (IWMWindow *)parent;
- (IWMWindow *)window;
- (int)clientID;

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (IWMImage *)iconImage;
- (void)setIconImage:(IWMImage *)anImage;

- (int)screenNumber;
- (void)setScreenNumber:(int)aScreen;

- (Window)transient;
- (void)setTransient:(Window)aTransient;

- (IWMWindow *)parent;
- (void)setParent:(IWMWindow *)aParent;

- (IWMTitlebar *)titlebar;
- (void)setTitlebar:(IWMTitlebar *)aTitlebar;
- (int)titlebarHeight;

- (IWMResizebar *)resizebar;
- (void)setResizebar:(IWMResizebar *)aResizebar;
- (int)resizebarHeight;

- (IWMIcon *)icon;
- (void)setIcon:(IWMIcon *)anIcon;

- (BOOL)containsXWindow:(Window)aWindow isParent:(BOOL)isParent;

- (NSString *)xClass;
- (NSString *)xClassInstance;

- (int)wmState;
- (void)setWMState:(int)aState;

- (Colormap)colormap;
- (void)setColormap:(Colormap)aColormap;

- (int)ignoreUnmap;
- (void)incrementIgnoreUnmap;
- (void)decrementIgnoreUnmap;

- (int)borderWidth;
- (void)setBorderWidth:(int)aValue;

- (NSRect)frame;

- (int)width;
- (int)height;

- (NSSize)size;
- (NSPoint)origin;

- (BOOL)obscured;
- (void)setObscured:(BOOL)aValue;

#ifdef SHAPE
- (int) shape;
- (void) setShape:(int)shape;
#endif

- (BOOL)hasBorder;
- (BOOL)hasTitlebar;
- (BOOL)hasCloseButton;
- (BOOL)hasMinimizeButton;
- (BOOL)hasMaximizeButton;
- (BOOL)hasResizebar;

- (BOOL)minimized;
- (BOOL)maximized;
- (BOOL)shaped;
- (BOOL)focused; // XXX - change to isFocused
- (BOOL)modal;
- (BOOL)sticky;
- (BOOL)hidden;
- (BOOL)shaded;
- (BOOL)maximizedHorizontally;
- (BOOL)maximizedVertically;
- (BOOL)fullscreen;
- (BOOL)skipTaskbar;
- (BOOL)skipPager;

- (NSString *)description;
- (void)dealloc;

@end

@interface IWMClient (InitializationMethods)

/*!
 * @method initializeFrame
 * @discussion Initializes the client's size and origin
 */
- initializeFrame;

/*!
 * @method initializeDecorations
 * @discussion Initializes the client's decor (titlebar, resizebar)
 */
- initializeDecorations;

/*!
 * @method initializeMOTIFDecorations
 * @discussion Initializes the client's decor based on EWMH hints
 */
- initializeEWMHDecorations;

/*!
 * @method initializeMOTIFDecorations
 * @discussion Initializes the client's decor based on MOTIF hints
 */
- initializeMOTIFDecorations;

/*!
 * @method initializeParentWindow
 * @discussion Initializes the client's parent window, which contains
 * the application window, titlebar and resizebar
 */
- initializeParentWindow;

@end

@interface IWMClient (MovementMethods)
/*!
 * @method move
 * @discussion Moves the client
 */
- (void)move;

/*!
 * @method moveWithMouseUntilButtonRelease
 * @discussion Continues client movement until the mouse button is released
 */
- (void)moveWithMouseUntilButtonRelease;

/*!
 * @method setFrameTopLeftPoint:
 * @discussion Sets the client's top left point to the provided X/Y coordinates
 */
- (void)setTopLeftPoint:(NSPoint)aPoint;

@end

@interface IWMClient (ResizeMethods)

/*!
 * @method setSize:
 * @param aSize An NSSize structure
 * @discussion Resizes the client to the provided width/height
 */
- (void)setSize:(NSSize)aSize;

/*!
 * @method resize:
 * @discussion Resizes a client.  If <i>resizeWidth</i> is <b>YES</b>, then
 * the resizing will affect both width and height, otherwise, only height.
 * @param resizeWidth
 */
- (void)resize:(BOOL)resizeWidth;

/*!
 * @method resizeWithMouseUntilButtonRelease:
 * @discussion Continues client resizing until the mouse button is released.
 * @param resizeWidth
 */
- (void)resizeWithMouseUntilButtonRelease:(BOOL)resizeWidth;

- (void)resizeWithMouseMotionTo:(int)xValue :(int)yValue;

/*!
 * @method minimize
 * @discussion Minimizes the client
 */
- (void)minimize;

/*!
 * @method unminimize
 * @discussion Un-minimizes the client
 */
- (void)unminimize;

/*!
 * @method maximize
 * @discussion Maximizes the client
 */
- (void)maximize;

/*!
 * @method maximizeHorizontally
 * @discussion Maximizes the client horizontally
 */
- (void)maximizeHorizontally;

/*!
 * @method maximizeVertically
 * @discussion Maximizes the client vertically
 */
- (void)maximizeVertically;

/*!
 * @method unmaximize
 * @discussion Un-maximizes the client
 */
- (void)unmaximize;

- (void)setFrame:(NSRect)aRect;

- (void)verifyFrame:(NSRect)aFrame;

@end

#endif /* _IWMCLIENT_H_ */

