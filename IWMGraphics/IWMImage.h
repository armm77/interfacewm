
/*
 * $Id: IWMImage.h,v 1.2 2003/12/12 04:31:59 copal Exp $
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

#ifndef _IWMIMAGE_H_
#define _IWMIMAGE_H_    1

#include "IWMCoreImage.h"

#include "wraster.h"

#include <Foundation/NSObject.h>

@class NSString;
@class IWMWindow;
@class IWMPixmapTexture;

typedef enum {
    IM_UNKNOWN, IM_XPM, IM_TIFF, IM_PNG, IM_PPM, IM_JPEG, IM_GIF
} IWMImageFormat;

@interface IWMImage : NSObject
{
    IWMScreen    *screen;
    //IWMCoreImage  image;
    IWMPixmapTexture *texture;
    RImage *image;
}

/*==========================================================================*
   LOADING
 *==========================================================================*/

/*
 * @method imageNamed:screen:
 * @abstract Loads an image file
 * @discussion You are responsible for deallocating the IWMImage object
 * returned from this method!  This will search for the image if not given
 * a valid path by searching IWM's default image paths
 */
+ (IWMImage *)imageNamed:(NSString *)name screen:(IWMScreen *)aScreen;

/*==========================================================================*
   DESIGNATED INITIALIZERS
 *==========================================================================*/

- initOnScreen:(IWMScreen *)aScreen image:(IWMCoreImage)anImage; 
- initOnScreen:(IWMScreen *)aScreen file:(NSString *)aFilepath;
             
/*==========================================================================*
   IMAGE MANIPULATION
 *==========================================================================*/

/*
 * scaling
 */
- (IWMImage *)scaleToWidth:(unsigned)aWidth height:(unsigned)aHeight;

/*
 * tiling
 */
- (IWMImage *)tileToWidth:(unsigned)aWidth height:(unsigned)aHeight;

/*==========================================================================*
   CONVERSION TO X PIXMAPS
 *==========================================================================*/

- (Pixmap)convertToPixmap;
                                      
/*==========================================================================*
   FILLING WINDOWS
 *==========================================================================*/

/*
 * automatically smooth-scale the image to the size of aWindow
 */
- (Pixmap)setAsPixmapBackgroundInWindow:(IWMWindow *)aWindow;
                             
/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setImage:(IWMCoreImage)anImage;

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (IWMCoreImage)image;
- (unsigned char *)data;
- (int)width;
- (int)height;
- (IWMImageFormat)format;
- (RColor)background;
- (NSString *)imageFormatString;

/*==========================================================================*
   MANDATORY
 *==========================================================================*/

- (NSString *)description;
- (void)dealloc;

@end

#endif /* _IWMIMAGE_H_ */

