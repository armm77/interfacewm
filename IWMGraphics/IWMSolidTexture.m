
/*
 * $Id: IWMSolidTexture.m,v 1.1 2003/11/30 22:42:44 copal Exp $
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

#include "IWMSolidTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#undef BOOL

@implementation IWMSolidTexture

- initWithScreen:(IWMScreen *)aScreen color:(XColor *)aColor
{
    int gcm;
    XGCValues gcv;
    Window rootWindow = ([aScreen rootWindow])->xWindow;
       
    [super init];

    type = WTEX_SOLID;
    subtype = 0;

    XAllocColor(GlobalDisplay, [aScreen colormap], aColor);
    
    color = *aColor;
    if (aColor->red==0 && aColor->blue==0 && aColor->green == 0)
    {
	light.red = 0xb6da;
	light.green = 0xb6da;
	light.blue = 0xb6da;
	dim.red = 0x6185;
	dim.green = 0x6185;
	dim.blue = 0x6185;
    }
    else
    {
	RColor rgb;
	RHSVColor hsv, hsv2;
	int v;

	rgb.red = aColor->red >> 8;
	rgb.green = aColor->green >> 8;
	rgb.blue = aColor->blue >> 8;
	RRGBtoHSV(&rgb, &hsv);
	RHSVtoRGB(&hsv, &rgb);
	hsv2 = hsv;

	v = hsv.value*16/10;
	hsv.value = (v > 255 ? 255 : v);
	RHSVtoRGB(&hsv, &rgb);
	light.red = rgb.red << 8;
	light.green = rgb.green << 8;
	light.blue = rgb.blue << 8;

	hsv2.value = hsv2.value/2;
	RHSVtoRGB(&hsv2, &rgb);
	dim.red = rgb.red << 8;
	dim.green = rgb.green << 8;
	dim.blue = rgb.blue << 8;
    }
    dark.red = 0;
    dark.green = 0;
    dark.blue = 0;
    
    XAllocColor(GlobalDisplay, [aScreen colormap], &light);
    XAllocColor(GlobalDisplay, [aScreen colormap], &dim);
    XAllocColor(GlobalDisplay, [aScreen colormap], &dark);

    gcm = GCForeground|GCBackground|GCGraphicsExposures;
    gcv.graphics_exposures = False;

    gcv.background = gcv.foreground = light.pixel;
    light_gc = XCreateGC(GlobalDisplay, rootWindow, gcm, &gcv);

    gcv.background = gcv.foreground = dim.pixel;	
    dim_gc = XCreateGC(GlobalDisplay, rootWindow, gcm, &gcv);
    
    gcv.background = gcv.foreground = dark.pixel;
    dark_gc = XCreateGC(GlobalDisplay, rootWindow, gcm, &gcv);

    gcv.background = gcv.foreground = aColor->pixel;
    gc = XCreateGC(GlobalDisplay, rootWindow, gcm, &gcv);

    return self;
}

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    RImage *image = NULL;
    RColor color1;

    image = RCreateImage(aWidth, aHeight, False);
    color1.red = color.red >> 8;
    color1.green = color.green >> 8;
    color1.blue = color.blue >> 8;
    color1.alpha = 255;

    RClearImage(image, &color1);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

- (void)dealloc
{
    XFreeGC(GlobalDisplay, light_gc);
    XFreeGC(GlobalDisplay, dim_gc);
    XFreeGC(GlobalDisplay, dark_gc);

    [super dealloc];
}

@end

