
/*
 * $Id: IWMImage.m,v 1.3 2004/06/02 01:10:24 copal Exp $
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
#include "IWMClient.h"
#include "IWMWindow.h"
#include "IWMScreen.h"
#include "IWMWindowManager.h"

#define BOOL XWINDOWSBOOL
#include "IWMImage.h"
//#include "IWMTexture.h"
#include "IWMPixmapTexture.h"
#undef BOOL

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSAutoreleasePool.h>

@implementation IWMImage

+ (IWMImage *)imageNamed:(NSString *)name screen:(IWMScreen *)aScreen
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    
    /*
     * full path given
     */
    if ([manager fileExistsAtPath:name isDirectory:&isDir] && !isDir)
    {
        return [[IWMImage alloc] initOnScreen:aScreen file:name];
    }

    /*
     * perform search for image
     */
    else
    {
        NSString        *imageName = [name lastPathComponent];
        NSArray         *imagePaths = nil;
        NSString        *pathbase = nil;
        NSString        *imagePath = nil;
        BOOL             isDir = NO;
        int              count, i;

        imagePaths = [GlobalIWM imagePaths];
        count = [imagePaths count];
        for (i = 0; i < count; i++)
        {
            pathbase  = [imagePaths objectAtIndex:i];
            imagePath = [pathbase stringByAppendingPathComponent:imageName];

            if ([manager fileExistsAtPath:imagePath isDirectory:&isDir] && 
                    !isDir)
            {
                return [[IWMImage alloc] initOnScreen:aScreen file:imagePath];
            }
        }
    }

    return nil;
}

/*==========================================================================*
   DESIGNATED INITIALIZERS
 *==========================================================================*/

- initOnScreen:(IWMScreen *)aScreen image:(IWMCoreImage)anImage
{
#if 0
    if ((self = [super init]))
    {
        screen = aScreen;
        image  = anImage;

        return self;
    }
#endif
    return nil;
}

- initOnScreen:(IWMScreen *)aScreen file:(NSString *)aFilepath
{
    if ((self = [super init]))
    {
        XColor color;

        screen = aScreen;
        
        if (!XParseColor(GlobalDisplay, [aScreen colormap], "black", &color))
            return nil;
        
        texture = [[IWMPixmapTexture alloc] initWithScreen:aScreen
            style:WTP_SCALE pixmapFile:(char *)[aFilepath cString]
            color:&color];

        return self;
    }

    return nil;
}

/*==========================================================================*
   INSTANCE METHODS
 *==========================================================================*/

/*==========================================================================*
   IMAGE MANIPULATION
 *==========================================================================*/

/*
 * scaling
 */
- (IWMImage *)scaleToWidth:(unsigned)aWidth height:(unsigned)aHeight
{
    //IWMCoreImage  core;
    //IWMImage     *new;
    //core = iwm_image_scale(image, aWidth, aHeight);
    //new = [[IWMImage alloc] initOnScreen:screen image:core];
    //return [new autorelease];

    if (image)
        RReleaseImage(image);
    image = NULL;
    image = [texture centerImageToWidth:aWidth height:aHeight relief:WREL_FLAT];

    return self;
}

/*
 * tiling
 */
- (IWMImage *)tileToWidth:(unsigned)aWidth height:(unsigned)aHeight
{
    //IWMCoreImage  core;
    //IWMImage     *new;
    //core = iwm_image_tile(image, aWidth, aHeight);
    //new  = [[IWMImage alloc] initOnScreen:screen image:core];
    //return [new autorelease];

    if (image)
        RReleaseImage(image);
    image = NULL;
    image = [texture tileImageToWidth:aWidth height:aHeight relief:WREL_FLAT];
    
    return self;
}

/*==========================================================================*
   CONVERSION TO X PIXMAPS
 *==========================================================================*/

- (Pixmap)convertToPixmap
{
    Pixmap pixmap;
    int result;

    if (!(result = RConvertImage(screen->rcontext, image, &pixmap)))
    {
        fprintf(stderr, "Failed to convert image to pixmap\n");
        return 0;
    }

    fprintf(stderr, "Converted image to pixmap\n");

    return pixmap;
}

/*==========================================================================*
   FILLING WINDOWS
 *==========================================================================*/

/*
 * automatically smooth-scale the image to the size of aWindow
 */
- (Pixmap)setAsPixmapBackgroundInWindow:(IWMWindow *)aWindow
{
    Pixmap       pixmap;
    IWMScreen   *_screen;
    int width = [aWindow width];
    int height = [aWindow height];

    if (!(_screen = [[aWindow client] screen]))
        _screen = [[GlobalIWM screenArray] objectAtIndex:0];

    [self scaleToWidth:width height:height];
    pixmap = [self convertToPixmap];
    

    [aWindow setPixmap:pixmap];
    
    return pixmap;
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setImage:(IWMCoreImage)anImage
{
    //iwm_image_release(image);
    //image = anImage;
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/


- (IWMCoreImage)image
{
    IWMCoreImage foo;
    
    return foo;
    //return image;
}

- (unsigned char *)data
{
    return image->data;
}

- (int)width
{
    return image->width;
}

- (int)height
{
    return image->height;
}

- (IWMImageFormat)format
{
    return (IWMImageFormat)image->format;
}

- (RColor)background
{
    return image->background;
}

- (NSString *)imageFormatString
{
    NSString *string = nil;

    //string = [NSString stringWithCString:iwm_image_format(image)];

    return string;
}

/*==========================================================================*
   MANDATORY
 *==========================================================================*/

- (NSString *)description
{
    NSString *description;

    description = [NSString stringWithFormat:@"<IWMImage: %s>",
        [self imageFormatString]];

    return description;
}

- (void)dealloc
{
    screen = nil;
    //iwm_image_release(image);
    RReleaseImage(image);
    [texture dealloc];
    
    [super dealloc];
}

@end

