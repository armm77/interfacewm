
/*
 * $Id: IWMTexture.h,v 1.2 2003/12/12 04:31:59 copal Exp $
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

#ifndef _IWMTEXTURE_H_
#define _IMWTEXTURE_H_     1

#include "wraster.h"
#include <Foundation/NSObject.h>

/* texture relief */
#define WREL_RAISED	0
#define WREL_SUNKEN	1
#define WREL_FLAT	2
#define WREL_ICON	4
#define WREL_MENUENTRY	6

/* texture types */
#define WREL_BORDER_MASK	1

#define WTEX_SOLID 	((1<<1)|WREL_BORDER_MASK)
#define WTEX_HGRADIENT	((1<<2)|WREL_BORDER_MASK)
#define WTEX_VGRADIENT	((1<<3)|WREL_BORDER_MASK)
#define WTEX_DGRADIENT	((1<<4)|WREL_BORDER_MASK)
#define WTEX_MHGRADIENT	((1<<5)|WREL_BORDER_MASK)
#define WTEX_MVGRADIENT	((1<<6)|WREL_BORDER_MASK)
#define WTEX_MDGRADIENT	((1<<7)|WREL_BORDER_MASK)
#define WTEX_IGRADIENT	((1<<8)|WREL_BORDER_MASK)
#define WTEX_PIXMAP	(1<<10)
#define WTEX_THGRADIENT	((1<<11)|WREL_BORDER_MASK)
#define WTEX_TVGRADIENT	((1<<12)|WREL_BORDER_MASK)
#define WTEX_TDGRADIENT	((1<<13)|WREL_BORDER_MASK)
#define WTEX_FUNCTION	((1<<14)|WREL_BORDER_MASK)

/* pixmap subtypes */
#define WTP_TILE	2
#define WTP_SCALE	4
#define WTP_CENTER	6

@interface IWMTexture : NSObject
{
@public
    short type;
    char subtype;
    XColor color;
    GC gc;
}

- init;

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief;

- (RImage *)checkImage:(RImage *)image width:(int)aWidth height:(int)aHeight;
    
- (void)bevelImage:(RImage *)image relief:(int)aRelief;
- (int)bevelDepthForRelief:(int)aRelief;

- (RImage *)finishProcessing:(RImage *)anImage width:(int)aWidth
    height:(int)aHeight relief:(int)aRelief;

// missing wDrawBevel() implementation

@end

#endif

