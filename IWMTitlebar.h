
/*
 * $Id: IWMTitlebar.h,v 1.10 2003/11/26 23:47:55 copal Exp $
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

#ifndef _IWMTITLEBAR_H_
#define _IWMTITLEBAR_H_ 1

#include "IWMWindow.h"

@class IWMClient, IWMTheme, IWMMenu;

/*! 
 * @class IWMTitlebar
 * A subclass of IWMWindow which manages the buttons displayed on an IWMClient
 */
@interface IWMTitlebar : IWMWindow
{
    IWMWindow   *closeButton;
    IWMWindow   *minimizeButton;
}

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

/*!
 * @method initWithClient:
 * @abstract Designated initializer.  Obtains theme information from aClient
 * @param aClient An IWMClient instance
 * @result Returns a newly initialized IWMTitlebar or nil on error
 */
- initForClient:(IWMClient *)aClient;

//- initForMenu:(IWMMenu *)menu;

/*!
 * @method initializeButtons
 * @abstract Initializes buttons appearing on titlebar according to the
 * client's flags
 */
- (void)initializeButtons;

/*!
 * @method initialzeTheme:
 * @abstract Decorate titlebar using parameters/images contained in aTheme
 * @param aTheme An IWMTheme instance
 */
- (void)initializeTheme:(IWMTheme *)aTheme;

/*!
 * @method redraw
 * @abstract Redraws the titlebar
 * @discussion When called, the redraw method refreshes the client's theme
 * data and re-reads the user's defaults database to allow any overrides (such
 * as a user-defined button layout preference).
 */
- (void)redraw;

- (void)hide;
- (void)unhide;

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

/*!
 * @method setTitle:
 * @abstract Sets text into the titlebar
 * @param aTitle Text to be displayed
 * @param focused Determines the GC used to draw text in the window
 */
- (void)setTitle:(NSString *)aTitle isFocused:(BOOL)focused;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

/*!
 * @method titlebarHeight
 * @abstract Returns the titlebar height
 * @discussion Titlebar height is dynamically calculated based on font size
 */
- (int)titlebarHeight;
- (int)buttonHeight;

- (IWMWindow *)closeButton;
- (IWMWindow *)minimizeButton;

- (NSPoint)closeButtonCoordinates;
- (NSPoint)minimizeButtonCoordinates;

@end

#endif /* _IWMTITLEBAR_H_ */

