
/*
 * $Id: IWMWindowManager+Theme.m,v 1.1 2004/06/13 06:50:45 copal Exp $
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

@implementation IWMWindowManager (ThemeMethods)

/*
 * apply any defaults-based overrides to aTheme; if aTheme is nil, the current
 * screen's theme is located.
 */
- (void)applyOverridesToTheme:(IWMTheme *)aTheme
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSString            *tmp = nil;

    if (!aTheme)
    {
        aTheme = [[self currentScreen] theme];
    }

    if ((tmp = [self valueForDefaultsKey:PRIMARY_FONT_DEFAULT]))
    {
        [aTheme setPrimaryFontName:tmp];
    }
    
    if ((tmp = [self valueForDefaultsKey:SECONDARY_FONT_DEFAULT]))
    {
        [aTheme setSecondaryFontName:tmp];
    }
    
    if ((tmp = [self valueForDefaultsKey:TERTIARY_FONT_DEFAULT]))
    {
        [aTheme setTertiaryFontName:tmp];
    }

    if ((tmp = [self valueForDefaultsKey:BACKGROUND_COLOR_DEFAULT]))
    {
        [aTheme setEmptyBackgroundColorName:tmp];
    }

    if ((tmp = [self valueForDefaultsKey:BORDER_COLOR_DEFAULT]))
    {
        [aTheme setBorderColorName:tmp];
    }

    [pool release];
}

- (BOOL)loadThemeAtPath:(NSString *)path
{
    return NO;
}

- (BOOL)loadThemeNamed:(NSString *)themeName
{
    return NO;
}


- (NSMutableArray *)themePaths
{
    if (!themePaths)
    {
        themePaths = [[NSMutableArray alloc] init];
    }

    return themePaths;
}

- (NSMutableArray *)imagePaths
{
    if (!imagePaths)
    {
        imagePaths = [[NSMutableArray alloc] init];
    }

    return imagePaths;
}

- (IWMTheme *)theme
{
    IWMTheme *theme;

    theme = [[self currentScreen] theme];

    return theme;
}

@end