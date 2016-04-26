
/*
 * $Id: IWMPixmapTexture.h,v 1.2 2003/12/12 04:31:59 copal Exp $
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

#ifndef _IWMMPIXMAPTEXTURE_H_
#define _IMWMPIXMAPTEXTURE_H_     1

#include "IWMTexture.h"
#include "wraster.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#undef BOOL

@class IWMScreen;

@interface IWMPixmapTexture : IWMTexture
{
@public
    RImage *pixmap;
}

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    pixmapFile:(char *)aPixmapFile color:(XColor *)aColor;

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

- (RImage *)tileImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

- (RImage *)scaleImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

- (RImage *)centerImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

@end

#endif
