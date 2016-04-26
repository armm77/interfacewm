
/*
 * $Id: IWMTGradientTexture.m,v 1.1 2003/11/30 22:42:44 copal Exp $
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

#include "IWMTGradientTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
//#include <Foundation/NSString.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#undef BOOL

@implementation IWMTGradientTexture

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    fromColor:(RColor *)fromColor toColor:(RColor *)toColor
    pixmapFile:(char *)aPixmapFile opacity:(int)anOpacity
{
    XGCValues gcv;
    RImage *image;

    //XXX verify file path here
    
    image = RLoadImage(aScreen->rcontext, aPixmapFile, 0);
    if (!image)
    {
        NSLog(@"Could not load texture pixmap: %s", aPixmapFile);
        NSLog(@"%s", RMessageForError(RErrorCode));
	return nil;
    }
    
    [super init];
    
    type = aStyle;
    opacity = anOpacity;

    color1 = *fromColor;
    color2 = *toColor;

    color.red = (fromColor->red + toColor->red)<<7;
    color.green = (fromColor->green + toColor->green)<<7;
    color.blue = (fromColor->blue + toColor->blue)<<7;

    XAllocColor(GlobalDisplay, [aScreen colormap], &color);
    gcv.background = gcv.foreground = color.pixel;
    gcv.graphics_exposures = False;
    gc = XCreateGC(GlobalDisplay, ([aScreen rootWindow])->xWindow, 
            GCForeground|GCBackground|GCGraphicsExposures, &gcv);

    pixmap = image;

    return self;
}

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    switch (type) {
        case WTEX_THGRADIENT:
            subtype = RGRD_HORIZONTAL;
            break;
            
        case WTEX_TVGRADIENT:
            subtype = RGRD_VERTICAL;
            break;
            
        case WTEX_TDGRADIENT:
            subtype = RGRD_DIAGONAL;
            break;
    }

    RImage *image;
    RImage *gradient;

    image = RMakeTiledImage(pixmap, aWidth, aHeight);
    if (image)
    {
        gradient = RRenderGradient(aWidth, aHeight, &color1, &color2, subtype);
        if (gradient) {
            RCombineImagesWithOpaqueness(image, gradient, opacity);
            RReleaseImage(gradient);
        }
        else {
            RReleaseImage(image);
            image = NULL;
        }
    }
    
    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

- (void)dealloc
{
    RReleaseImage(pixmap);

    [super dealloc];
}

@end

