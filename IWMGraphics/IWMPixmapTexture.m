
/*
 * $Id: IWMPixmapTexture.m,v 1.3 2004/06/02 01:08:28 copal Exp $
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

#include "IWMPixmapTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
//#include <Foundation/NSString.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#include <IWMDebug.h>
#undef BOOL

@implementation IWMPixmapTexture

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    pixmapFile:(char *)aPixmapFile color:(XColor *)aColor
{
    XGCValues gcv;
    RImage *image;

    IWMTRACE;

    fprintf(stderr, "Initializing IWMPixmapTexture: %s\n", aPixmapFile);

    //XXX verify file path here
    
    image = RLoadImage(aScreen->rcontext, aPixmapFile, 0);
    if (!image)
    {
        NSLog(@"Could not load texture pixmap: %s", aPixmapFile);
        NSLog(@"%s", RMessageForError(RErrorCode));
	return nil;
    }

    type = WTEX_PIXMAP;
    subtype = aStyle;

    color = *aColor;

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
    return [self scaleImageToWidth:aWidth height:aHeight relief:aRelief];
}

- (RImage *)tileImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    RImage *image = NULL;

    fprintf(stderr, "Tiling image...\n");
    
    image = RMakeTiledImage(pixmap, aWidth, aHeight);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

- (RImage *)scaleImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    RImage *image = NULL;

    fprintf(stderr, "Scaling image...\n");

    image = RScaleImage(pixmap, aWidth, aHeight);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

- (RImage *)centerImageToWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    RImage *image = NULL;
    RColor color1;

    IWMTRACE;
    
    fprintf(stderr, "Centering image...\n");
    
    color1.red = color.red>>8;
    color1.green = color.green>>8;
    color1.blue = color.blue>>8;
    color1.alpha = 255;
    image = RMakeCenteredImage(pixmap, aWidth, aHeight, &color1);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

- (void)dealloc
{
    RReleaseImage(pixmap);

    [super dealloc];
}

@end
