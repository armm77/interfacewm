
/*
 * $Id: IWMWindow.h,v 1.18 2004/06/15 05:22:21 copal Exp $
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

#ifndef _IWMWINDOW_H_
#define _IWMWINDOW_H_   1

#include "InterfaceWM.h"

#define BOOL XWINDOWSBOOL
#    include <Foundation/NSObject.h>
#undef BOOL

#include <Foundation/NSGeometry.h>

@class IWMClient;
@class IWMImage;
@class IWMScreen;

/*! 
 * @class IWMWindow
 * @abstract Wrapper class for X windows.
 * @discussion The IWMWindow class provides transparent manipulation of X
 * windows and any image they might contain (which are contained within an
 * IWMImage).
 */

@interface IWMWindow : NSObject
{
    IWMClient     *client;
    Pixmap         pixmap;

@public
    Window xWindow;
    XftDraw *xftdraw;
}

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

/*!
 * @method initWithWindow:client:pixmap:type
 * @discussion Designated initializer
 * @param window The pre-existing X window
 * @param client The client this window belongs to, if any
 * @param pixmap The pixmap to display in the window
 * @param type The type of the window
 */
- initWithWindow:(Window)aWindow client:(IWMClient *)aClient
    pixmap:(Pixmap)aPixmap type:(Atom)aType;

/*!
 * @method initWithParent:x:y:width:height:image:
 * @discussion High level initialization of window
 * @param aParent Parent window
 * @param aFrame An NSRect containing size/origin
 */  
- initWithParent:(IWMWindow *)aParent frame:(NSRect)aFrame;

/*!
 * @method initAsClientWindow:sender:
 * @discussion Initializes an IWMWindow from a pre-existing client window
 * @param window The window created by the application
 * @param sender The initializing IWMClient requesting the window
 */
- initAsClientWindow:(Window)window sender:(IWMClient *)sender;
   
/*!
 * @method initAsParentForClient:
 * @discussion Initializes the parent window for a client
 */
- initAsParentForClient:(IWMClient *)client;

/*!
 * @method initAsTopLevelWithFrame:
 * @discussion Initializes an IWMWindow as a child of the root window. 
 * Used for creating menus, icons, etc.
 */
- initAsTopLevelWithFrame:(NSRect)aFrame;

/*!
 * @method initAsRootWindowForScreen:
 * @discussion Initializes the root window for the provided screen number
 */
- initAsRootWindowForScreen:(int)screen;
           
/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

/*!
 * @method setSize:
 * @param aSize An NSSize structure
 * @discussion Resizes the window to the provided width/height
 */
- (void)setSize:(NSSize)aSize;

/*!
 * @method setTopLeftPoint:
 * @discussion Moves a window to an x/y position
 */
- (void)setTopLeftPoint:(NSPoint)aPoint;

/*!
 * @method setInto:point:
 * @discussion Reparents the window into aParent at the specified point
 */
- (void)setInto:(IWMWindow *)aParent point:(NSPoint)aPoint;

/*!
 * @method hide
 * @discussion Hides the window
 */
- (void)hide;

/*!
 * @method unhide
 * @discussion Unhides the window
 */
- (void)unhide;

- (void)raise;
- (void)takeInputFocus;

/*!
 * @method name
 * @discussion Returns the name of the window
 */
- (NSString *)name;

- (void)setName:(NSString *)name;

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setClient:(IWMClient *)aClient;
- (void)setImage:(IWMImage *)anImage;
- (void)setPixmap:(Pixmap)aPixmap;

- (void)scaleImageInWindow;
- (void)tileImageInWindow;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (IWMClient *)client;
- (XContext)clientID;
- (IWMScreen *)screen;
- (Pixmap)pixmap;
- (Window)xWindow;

- (XWindowAttributes)attributes;

- (NSRect)frame;
- (void)setFrame:(NSRect)aRect;

- (int)width;
- (int)height;

- (NSSize)size;
- (NSPoint)origin;

- (void)configureNotify;

- (int)mapState;
- (Window)transient;

- (int)windowState;
- (void)setWindowState:(int)aState;
- (void)updateWindowState;

- (XWMHints *)wmHints;
- (XSizeHints *)wmNormalHints;
- (Atom *)wmProtocols:(int *)number;

- (NSString *)xClass;
- (NSString *)xClassInstance;

- (unsigned char *)property:(Atom)property type:(Atom)aType count:(int *)count;
- (unsigned char *)atomProperty:(Atom)property count:(int *)count;
- (unsigned char *)intProperty:(Atom)property count:(int *)count;
- (unsigned char *)windowProperty:(Atom)property count:(int *)count;
- (unsigned char *)stringProperty:(Atom)property count:(int *)count;
        
- (void)setProperty:(Atom)property type:(Atom)aType format:(int)format
        data:(unsigned char *)data elements:(int)elements;

- (void)setWindowProperty:(Atom)property
	       data:(unsigned char *)data elements:(int)elements;

- (void)setCardinalProperty:(Atom)property format:(int)format
	       data:(unsigned char *)data elements:(int)elements;

- (void)setStringProperty:(Atom)property format:(int)format
	       data:(unsigned char *)data elements:(int)elements;

- (void)setAtomProperty:(Atom)property format:(int)format
		     data:(unsigned char *)data elements:(int)elements;

/*!
 * @method windowType
 * @discussion Returns the type of the window
 */
- (Atom)windowType;

/*!
 * @method setWindowType:
 * @discussion Sets the type of the window
 * @param aType An atom identifying the window type
 */
- (void)setWindowType:(Atom)aType;
       
/*!
 * @method setRolloverCursor:
 * @discussion Defines the cursor to be displayed when the pointer is within
 * the window
 * @param aCursor The cursor to associate with the window.  If <i>nil</i>, the
 * default cursor will be set.
 */
- (void)setRolloverCursor:(Cursor)aCursor;

- (void)setBorderWidth:(int)width;
        
- (Colormap)colormap;
- (void)setColormap:(Colormap)aColormap;
- (void)clear;

- (NSString *)description;

- (void)dealloc;

@end

#endif /* _IWMWINDOW_H_ */

