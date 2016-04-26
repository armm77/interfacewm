
/*
 * $Id: IWMScreen.h,v 1.7 2003/10/29 04:08:03 copal Exp $
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

#ifndef _IWMSCREEN_H_
#define _IWMSCREEN_H_   1

#include "InterfaceWM.h"
#include "wraster.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#undef BOOL

@class IWMWindowManager;
@class IWMWindow;
@class IWMTheme;
@class IWMImage;
@class IWMClient;
@class NSMutableArray;

/*!
 * @class IWMScreen
 * Representation of a screen, or virtual desktop
 */
@interface IWMScreen : NSObject
{
    IWMTheme    *theme;
    IWMWindow   *rootWindow;
    int          screenNumber;
    
    struct {                                    // cursors
        Cursor normal;
        Cursor move;
        Cursor resize;
        Cursor leftResize;
        Cursor rightResize;
        Cursor downResize;
    } cursors;

    struct {                                    // fonts
        XFontStruct *primary;
        XFontStruct *secondary;
        XFontStruct *tertiary;
    } fonts;
        
    struct {                                    // colors
        XColor focused;
        XColor unfocused;
        XColor background;
        XColor border;
    } colors;

    struct {                                    // X graphics contexts
        GC invert;
        GC focused;
        GC unfocused;
        GC border;
        GC background;
    } gcs;

@private
    IWMWindow *_ewmh_window; // used for EWMH properties, never mapped

@public
    struct {
        XftColor focused;
        XftColor unfocused;
        XftColor background;
        XftColor border;
    } xftcolors;

    struct {
        XftFont *primary;
        XftFont *secondary;
        XftFont *tertiary;
    } xftfonts;

    RContext *rcontext;
    Window rootXWindow; // XXX get rid of this now
}

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

- initWithScreenNumber:(int)aScreenNumber;

- (void)initializeEWMHSupport;

/*!
 * @method initializeFonts
 * @abstract Initializes all fonts used by window manager
 */
- (void)initializeFonts;

/*!
 * @method initializeColors
 * @abstract Initializes all colors used by window manager
 */
- (void)initializeColors;

/*!
 * @method initializeGraphicsContexts
 * @abstract Initializes all GC's used by window manager
 */
- (void)initializeGraphicsContexts;

/*!
 * @method initializeCursors
 * @abstract Initialize all cursors used by window manager
 */
- (void)initializeCursors;

/*!
 * @method initializeRContext
 * @abstract Initialize RContext used by window manager
 * @discussion Used if compiled with libwraster
 */
- (BOOL)initializeRContext;

/*!
 * @method initializeTheme:
 * @abstract Initializes provided theme on the screen
 * @param aTheme An IWMTheme
 */
- (BOOL)initializeTheme:(IWMTheme *)aTheme;

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

/*!
 * @method setTheme:
 * @discussion Sets the theme of the screen to the provided IWMTheme
 * @param aTheme An IWMTheme
 */
- (void)setTheme:(IWMTheme *)aTheme;

/*!
 * @method setScreenBackgroundImage:
 * @discussion Sets the background image of the screen
 * @param anImage An IWMImage
 */
- (void)setScreenBackgroundImage:(IWMImage *)anImage;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

/*!
 * @method titlebarHeight
 * @abstract Returns the appropriate titlebar height
 * @discussion Titlebar height is dynamically calculated based on font size
 */
- (int)titlebarHeight;

- (int)textWidthForString:(NSString *)aString;

/*!
 * @method drawCenteredText:
 * @discussion Draws the provided text in the center of the screen
 * @param aString The text to draw
 */
- (void)drawCenteredText:(NSString *)aString;

- (void)drawRectangleWithWidth:(int)width height:(int)height x:(int)xValue
    y:(int)yValue;

- (Window)rootXWindow;

/*!
 * @method rootWindow
 * @discussion Returns the IWMWindow representing the screen's root window
 */
- (IWMWindow *)rootWindow;

/*!
 * @method theme
 * @discussion Returns the screen's current theme
 */
- (IWMTheme *)theme;

/*!
 * @method screenNumber
 * @discussion Returns the screen's screen number
 */
- (int)screenNumber;

/*!
 * @method depth
 * @discussion Returns the screen's depth
 */
- (int)depth;

/*!
 * @method width
 * @discussion Returns the screen's width
 */
- (int)width;

/*!
 * @method height
 * @discussion Returns the screen's height
 */
- (int)height;
- (Colormap)colormap;
- (RContext *)rcontext;

/*!
 * @method clientArray
 * @discussion Returns an array of all IWMClient's on the screen
 */
- (NSMutableArray *)clientArray;

- (Cursor)normalCursor;
- (Cursor)moveCursor;
- (Cursor)resizeCursor;
- (Cursor)leftResizeCursor;
- (Cursor)rightResizeCursor;
- (Cursor)downResizeCursor;
- (XFontStruct *)primaryFont;
- (XFontStruct *)secondaryFont;
- (XColor)focusedColor;
- (XColor)unfocusedColor;
- (XColor)backgroundColor;
- (XColor)borderColor;
- (GC)invertGC;
- (GC)focusedGC;
- (GC)unfocusedGC;
- (GC)borderGC;
- (GC)backgroundGC;

@end

#endif /* _IWMSCREEN_H_ */

