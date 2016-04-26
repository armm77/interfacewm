
/*
 * $Id: IWMTGradientTexture.h,v 1.1 2003/11/30 22:42:44 copal Exp $
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

#ifndef _IWMTGRADIENTTEXTURE_H_
#define _IMWTGRADIENTTEXTURE_H_     1

#include "IWMTexture.h"
#include "wraster.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#undef BOOL

@class IWMScreen, NSString;

@interface IWMTGradientTexture : IWMTexture
{
@public
    RColor color1;
    RColor color2;
    struct RImage *pixmap;
    int opacity;
}

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    fromColor:(RColor *)fromColor toColor:(RColor *)toColor
    pixmapFile:(char *)aPixmapFile opacity:(int)anOpacity;

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

@end

#endif
