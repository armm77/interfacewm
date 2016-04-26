
/*
 * $Id: IWMTheme.h,v 1.7 2003/10/29 04:08:03 copal Exp $
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

#ifndef _IWMTHEME_H_
#define _IWMTHEME_H_    1

#include "InterfaceWM.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#undef BOOL

@class IWMScreen;
@class IWMTheme;
@class IWMImage;
@class NSString;
@class NSArray;
@class NSMutableArray;
@class NSMutableDictionary;
@class NSBundle;

/*!
 * @class IWMTheme
 */
@interface IWMTheme : NSObject
{
    IWMImage    *backgroundImage;
    IWMImage    *focusedTitlebarImage;
    IWMImage    *unfocusedTitlebarImage;
    IWMImage    *closeButtonImage;
    IWMImage    *minimizeButtonImage;
    IWMImage    *maximizeButtonImage;
    IWMImage    *resizebarImage;
    IWMImage    *iconImage;

@private
    NSBundle            *_bundle;
    NSDictionary        *_info;
    NSMutableDictionary *_theme;
}

/*==========================================================================*
   FACTORY METHODS
 *==========================================================================*/

+ (NSString *)defaultThemePath;

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

+ themeNamed:(NSString *)aTheme screen:(IWMScreen *)aScreen;

- initWithThemeNamed:(NSString *)aTheme screen:(IWMScreen *)aScreen;

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

- (void)loadThemeImagesForScreen:(IWMScreen *)aScreen;

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setPrimaryFontName:(NSString *)aName;
- (void)setSecondaryFontName:(NSString *)aName;
- (void)setTertiaryFontName:(NSString *)aName;

- (void)setFocusedTitleColorName:(NSString *)aColor;
- (void)setUnfocusedTitleColorName:(NSString *)aColor;

- (void)setEmptyBackgroundColorName:(NSString *)aColor;
- (void)setBorderColorName:(NSString *)aColor;

- (void)setBackgroundImagePath:(NSString *)aPath;
- (void)setFocusedTitlebarImagePath:(NSString *)aPath;
- (void)setUnfocusedTitlebarImagePath:(NSString *)aPath;
- (void)setCloseButtonImagePath:(NSString *)aPath;
- (void)setMinimizeButtonImagePath:(NSString *)aPath;
- (void)setMaximizeButtonImagePath:(NSString *)aPath;

- (void)setResizebarImagePath:(NSString *)aPath;
- (void)setIconImagePath:(NSString *)aPath;

- (void)setBackgroundImage:(IWMImage *)anImage;
- (void)setUnfocusedTitlebarImage:(IWMImage *)anImage;
- (void)setFocusedTitlebarImage:(IWMImage *)anImage;
- (void)setCloseButtonImage:(IWMImage *)anImage;
- (void)setMinimizeButtonImage:(IWMImage *)anImage;
- (void)setMaximizeButtonImage:(IWMImage *)anImage;
- (void)setResizebarImage:(IWMImage *)anImage;
- (void)setIconImage:(IWMImage *)anImage;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

/*==========================================================================*
   COLOR & FONT NAMES
 *==========================================================================*/

- (NSString *)primaryFontName;
- (NSString *)secondaryFontName;
- (NSString *)tertiaryFontName;
- (NSString *)focusedTitleColorName;
- (NSString *)unfocusedTitleColorName;
- (NSString *)emptyBackgroundColorName;
- (NSString *)borderColorName;

/*==========================================================================*
   IMAGE PATHNAMES
 *==========================================================================*/

- (NSString *)backgroundImagePath;
- (NSString *)focusedTitlebarImagePath;
- (NSString *)unfocusedTitlebarImagePath;
- (NSString *)closeButtonImagePath;
- (NSString *)minimizeButtonImagePath;
- (NSString *)maximizeButtonImagePath;
- (NSString *)resizebarImagePath;
- (NSString *)iconImagePath;

/*==========================================================================*
   IMAGES
 *==========================================================================*/

- (IWMImage *)backgroundImage;
- (IWMImage *)unfocusedTitlebarImage;
- (IWMImage *)focusedTitlebarImage;
- (IWMImage *)closeButtonImage;
- (IWMImage *)minimizeButtonImage;
- (IWMImage *)maximizeButtonImage;
- (IWMImage *)resizebarImage;
- (IWMImage *)iconImage;

/*!
 * @method pathForThemeElement:
 * @abstract Returns the path to an element with the key value name in the
 * theme bundle's Info.plist
 * @param name The key value sought from Info.plist
 */
- (NSString *)pathForThemeElement:(NSString *)name;

- (NSString *)description;

@end

#endif /* _IWMTHEME_H_ */

