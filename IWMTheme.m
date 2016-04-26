
/*
 * $Id: IWMTheme.m,v 1.11 2003/12/12 04:30:07 copal Exp $
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

#include "IWMTheme.h"
#include "IWMScreen.h"
#include "IWMImage.h"
#include "IWMWindowManager.h"

#include <IWMExtensions/NSDictionaryExt.h>

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSUserDefaults.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSAutoreleasePool.h>

#include <stdlib.h>

#include "IWMDebug.h"

NSString *primaryFontNameString                 = @"PrimaryFont";
NSString *secondaryFontNameString               = @"SecondaryFont";
NSString *tertiaryFontNameString                = @"TertiaryFont";
NSString *focusedTitleColorNameString           = @"FocusedTitlebarColor";
NSString *unfocusedTitleColorNameString         = @"UnfocusedTitlebarColor";
NSString *emptyBackgroundColorNameString        = @"EmptyBackgroundColor";
NSString *borderColorNameString                 = @"BorderColor";

NSString *backgroundImageString                 = @"BackgroundImage";
NSString *focusedTitlebarImageString            = @"FocusedTitlebarImage";
NSString *unfocusedTitlebarImageString          = @"UnfocusedTitlebarImage";
NSString *closeButtonImageString                = @"CloseButtonImage";
NSString *minimizeButtonImageString             = @"MinimizeButtonImage";
NSString *maximizeButtonImageString             = @"MaximizeButtonImage";
NSString *resizebarImageString                  = @"ResizebarImage";
NSString *iconImageString                       = @"IconImage";

NSString *tiffString                            = @"tiff";

@implementation IWMTheme

/*==========================================================================*
   FACTORY METHODS
 *==========================================================================*/

+ (NSString *)defaultThemePath
{
    NSString *home;
    NSString *path;

    home = NSHomeDirectory();
    path = [[home stringByAppendingPathComponent:INTERFACE_THEME_DIR]
                stringByAppendingPathComponent:@"Default.themed"];

    return path;
}

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

+ (IWMTheme *)themeNamed:(NSString *)aTheme screen:(IWMScreen *)aScreen
{
    IWMTRACE;
    
    return nil;
}

/*
 * themes are kept in bundles with the extension .iwmtheme
 */
- initWithThemeNamed:(NSString *)aTheme screen:(IWMScreen *)aScreen
{
    IWMTRACE;
    
    if ((self = [super init]))
    {
        NSAutoreleasePool       *_pool = [[NSAutoreleasePool alloc] init];
        NSFileManager           *fileManager = nil;
        NSEnumerator            *enumerator = nil;
        NSString                *aThemePath = nil;
        
        fileManager = [NSFileManager defaultManager];

        /*
         * add .iwmtheme if not present
         */
        if (![[[aTheme componentsSeparatedByString:@"."] lastObject]
                isEqualToString:@"iwmtheme"])
        {
            NSString *tmp = nil;
            
            tmp = [NSString stringWithFormat:@"%@.iwmtheme", aTheme];
            
            [aTheme release];
            aTheme = nil;
            aTheme = [tmp retain];
        }
        
        /*
         * search for theme
         */
        enumerator = [[GlobalIWM themePaths] objectEnumerator];
        while ((aThemePath = [enumerator nextObject]))
        {
            NSString *aPath = nil;
            BOOL isDir = NO;
            
            // create the full path of the theme directory 
            aPath = [aThemePath stringByAppendingPathComponent:aTheme];
            
            IWMNote(@"Trying to load theme %@", aPath);

            // found the theme
            
            if ([fileManager fileExistsAtPath:aPath isDirectory:&isDir] &&
                    isDir)
            {
                NSLog(@"-> Found directory at path: %@", aPath);
                _bundle = [NSBundle bundleWithPath:aPath];
                _info   = [_bundle infoDictionary];
            }
        }

        /*
         * load the images pointed to in the theme
         */
        [self loadThemeImagesForScreen:aScreen];

        [_pool release];

        return self;
    }

    return nil;
}

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

- (void)loadThemeImagesForScreen:(IWMScreen *)aScreen
{
    NSString *tmp = nil;
    
    IWMTRACE;

    tmp = [self backgroundImagePath];
    backgroundImage = [IWMImage imageNamed:tmp screen:aScreen];
    
    tmp = [self focusedTitlebarImagePath];
    focusedTitlebarImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self unfocusedTitlebarImagePath];
    unfocusedTitlebarImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self closeButtonImagePath];
    closeButtonImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self minimizeButtonImagePath];
    minimizeButtonImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self maximizeButtonImagePath];
    maximizeButtonImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self resizebarImagePath];
    resizebarImage = [IWMImage imageNamed:tmp screen:aScreen];

    tmp = [self iconImagePath];
    iconImage = [IWMImage imageNamed:tmp screen:aScreen];
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setPrimaryFontName:(NSString *)aName
{
    [_theme setObject:aName forKey:primaryFontNameString];
}

- (void)setSecondaryFontName:(NSString *)aName
{
    [_theme setObject:aName forKey:secondaryFontNameString];
}

- (void)setTertiaryFontName:(NSString *)aName
{
    [_theme setObject:aName forKey:tertiaryFontNameString];
}

- (void)setFocusedTitleColorName:(NSString *)aColor
{
    [_theme setObject:aColor forKey:focusedTitleColorNameString];
}

- (void)setUnfocusedTitleColorName:(NSString *)aColor
{
    [_theme setObject:aColor forKey:unfocusedTitleColorNameString];
}

- (void)setEmptyBackgroundColorName:(NSString *)aColor
{
    [_theme setObject:aColor forKey:emptyBackgroundColorNameString];
}

- (void)setBorderColorName:(NSString *)aColor
{
    [_theme setObject:aColor forKey:borderColorNameString];
}

- (void)setBackgroundImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:backgroundImageString];
}

- (void)setFocusedTitlebarImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:focusedTitlebarImageString];
}

- (void)setUnfocusedTitlebarImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:unfocusedTitlebarImageString];
}

- (void)setCloseButtonImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:closeButtonImageString];
}

- (void)setMinimizeButtonImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:minimizeButtonImageString];
}

- (void)setMaximizeButtonImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:maximizeButtonImageString];
}

- (void)setResizebarImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:resizebarImageString];
}

- (void)setIconImagePath:(NSString *)aPath
{
    [_theme setObject:aPath forKey:iconImageString];
}

- (void)setBackgroundImage:(IWMImage *)anImage
{
    [backgroundImage autorelease];
    backgroundImage = [anImage retain];
}

- (void)setFocusedTitlebarImage:(IWMImage *)anImage
{
    [focusedTitlebarImage autorelease];
    focusedTitlebarImage = [anImage retain];
}

- (void)setUnfocusedTitlebarImage:(IWMImage *)anImage
{
    [unfocusedTitlebarImage autorelease];
    unfocusedTitlebarImage = [anImage retain];
}

- (void)setCloseButtonImage:(IWMImage *)anImage
{
    [closeButtonImage autorelease];
    closeButtonImage = [anImage retain];
}

- (void)setMinimizeButtonImage:(IWMImage *)anImage
{
    [minimizeButtonImage autorelease];
    minimizeButtonImage = [anImage retain];
}

- (void)setMaximizeButtonImage:(IWMImage *)anImage
{
    [maximizeButtonImage autorelease];
    maximizeButtonImage = [anImage retain];
}

- (void)setResizebarImage:(IWMImage *)anImage
{
    [resizebarImage autorelease];
    resizebarImage = [anImage retain];
}

- (void)setIconImage:(IWMImage *)anImage
{
    [iconImage autorelease];
    iconImage = [anImage retain];
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

/*==========================================================================*
   COLOR & FONT NAMES
 *==========================================================================*/

- (NSString *)primaryFontName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:primaryFontNameString]))
        return tmp;

    return DEFAULT_FONT_PRIMARY;
}

- (NSString *)secondaryFontName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:secondaryFontNameString]))
        return tmp;

    return DEFAULT_FONT_SECONDARY;
}

- (NSString *)tertiaryFontName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:tertiaryFontNameString]))
        return tmp;

    return DEFAULT_FONT_TERTIARY;
}

- (NSString *)focusedTitleColorName
{
    NSString *tmp;
    
    if ((tmp = [_theme verifiedStringForKey:focusedTitleColorNameString]))
        return tmp;
    
    return DEFAULT_COLOR_FOCUSED;
}

- (NSString *)unfocusedTitleColorName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:unfocusedTitleColorNameString]))
        return tmp;

    return DEFAULT_COLOR_UNFOCUSED;
}

- (NSString *)emptyBackgroundColorName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:emptyBackgroundColorNameString]))
        return tmp;

    return DEFAULT_COLOR_BACKGROUND;
}

- (NSString *)borderColorName
{
    NSString *tmp;

    if ((tmp = [_theme verifiedStringForKey:borderColorNameString]))
        return tmp;

    return DEFAULT_COLOR_BORDER_1;
}

/*==========================================================================*
   IMAGE PATHNAMES
 *==========================================================================*/

- (NSString *)backgroundImagePath
{
    return [self pathForThemeElement:backgroundImageString];
}

- (NSString *)focusedTitlebarImagePath
{
    return [self pathForThemeElement:focusedTitlebarImageString];
}

- (NSString *)unfocusedTitlebarImagePath
{
    return [self pathForThemeElement:unfocusedTitlebarImageString];
}

- (NSString *)closeButtonImagePath
{
    return [self pathForThemeElement:closeButtonImageString];
}

- (NSString *)minimizeButtonImagePath
{
    return [self pathForThemeElement:minimizeButtonImageString];
}

- (NSString *)maximizeButtonImagePath
{
    return [self pathForThemeElement:maximizeButtonImageString];
}

- (NSString *)resizebarImagePath
{
    return [self pathForThemeElement:resizebarImageString];
}

- (NSString *)iconImagePath
{
    return [self pathForThemeElement:iconImageString];
}

/*==========================================================================*
   IMAGES
 *==========================================================================*/

- (IWMImage *)backgroundImage
{
    return backgroundImage;
}

- (IWMImage *)focusedTitlebarImage
{
    return focusedTitlebarImage;
}

- (IWMImage *)unfocusedTitlebarImage
{
    return unfocusedTitlebarImage;
}

- (IWMImage *)closeButtonImage
{
    return closeButtonImage;
}

- (IWMImage *)minimizeButtonImage
{
    return minimizeButtonImage;
}

- (IWMImage *)maximizeButtonImage
{
    return maximizeButtonImage;
}

- (IWMImage *)resizebarImage
{
    return resizebarImage;
}


- (IWMImage *)iconImage
{
    return iconImage;
}

- (NSString *)pathForThemeElement:(NSString *)name
{
    id value = nil;
    
    if ((value = [[_bundle infoDictionary] objectForKey:name]) &&
            [value isKindOfClass:[NSString class]])
    {
        NSMutableArray  *components = nil;
        NSString        *path = nil;
        NSString        *type = nil;
        NSString        *resource = nil;
        int              count = 0;
        
        /*
         * determine if there is an extension
         */
        components = [NSMutableArray arrayWithArray:
                        [value componentsSeparatedByString:@"."]];
        count = [components count];
        if (count > 1)
        {
            // simple (name).(extension)
            if (count == 2)
            {
                resource = [components objectAtIndex:0];
                type = [components objectAtIndex:1];
            }
            // (name.containing.periods).(extension)
            else
            {
                type = [components lastObject];
                [components removeLastObject];
                resource = [components componentsJoinedByString:@"."];
            }
        }
        else
        {
            resource = value;
            type = @"";
        }

        /*
         * determine the path
         */
        if ((path = [_bundle pathForResource:resource ofType:type]))
        {
            return path;
        }
        else
        {
            return value;
        }
    }

    return nil;
}

- (NSString *)description
{
    return ([_info description]);
}

@end

