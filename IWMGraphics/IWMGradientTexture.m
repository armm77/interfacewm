
/*
 * $Id: IWMGradientTexture.m,v 1.2 2003/12/12 04:31:59 copal Exp $
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

#include "IWMGradientTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#undef BOOL

@implementation IWMGradientTexture

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    fromColor:(RColor *)fromColor toColor:(RColor *)toColor
{
    XGCValues gcv;
    Window rootWindow = ([aScreen rootWindow])->xWindow;

    [super init];

    type = aStyle;
    subtype = 0;
    
    color1 = *fromColor;
    color2 = *toColor;

    color.red = (fromColor->red + toColor->red)<<7;
    color.green = (fromColor->green + toColor->green)<<7;
    color.blue = (fromColor->blue + toColor->blue)<<7;

    XAllocColor(GlobalDisplay, [aScreen colormap], &color);
    gcv.background = gcv.foreground = color.pixel;
    gcv.graphics_exposures = False;
    gc = XCreateGC(GlobalDisplay, rootWindow, GCForeground|GCBackground
				   |GCGraphicsExposures, &gcv);

    return self;
}

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    RImage *image;
    
    switch (type) {
        case WTEX_HGRADIENT:
            subtype = RGRD_HORIZONTAL;
            break;
            
        case WTEX_VGRADIENT:
            subtype = RGRD_VERTICAL;
            break;
            
        case WTEX_DGRADIENT:
            subtype = RGRD_DIAGONAL;
            break;
    }

    image = RRenderGradient(aWidth, aHeight, &color1, &color2, subtype);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

@end

