
/*
 * $Id: IWMTexture.m,v 1.3 2004/06/02 01:05:05 copal Exp $
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

#include "IWMTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#include <IWMDebug.h>
#undef BOOL

@implementation IWMTexture

- init
{
    [super init];
    
    type = 0;
    gc = NULL;
    
    return self;
}

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    NSLog(@"Subclass responsibility");
    return NULL;
}

- (RImage *)checkImage:(RImage *)image width:(int)aWidth height:(int)aHeight
{
    IWMTRACE;
    
    if (!image) {
        RColor gray;

        NSLog(@"Could not render texture: %s", RMessageForError(RErrorCode));
        image = RCreateImage(aWidth, aHeight, False);
        if (image == NULL) {
            NSLog(@"Could not allocate image buffer");
            return NULL;
        }

        gray.red = 190;
        gray.green = 190;
        gray.blue = 190;
        gray.alpha = 255;
        RClearImage(image, &gray);
    }
    
    return image;
}

- (int)bevelDepthForRelief:(int)aRelief
{
    int depth = 0;
    
    switch (aRelief) {
        case WREL_ICON:
            depth = RBEV_RAISED3;
            break;
            
        case WREL_RAISED:
            depth = RBEV_RAISED2;
            break;
            
        case WREL_SUNKEN:
            depth = RBEV_SUNKEN;
            break;
            
        case WREL_FLAT:
            depth = 0;
            break;
            
        case WREL_MENUENTRY:
            depth = -WREL_MENUENTRY;
            break;
            
        default:
            depth = 0;
    }

    return depth;
}

- (void)bevelImage:(RImage *)image relief:(int)relief
{
    int width = image->width;
    int height = image->height;
    RColor rcolor;

    IWMTRACE;
    
    switch (relief) {
     case WREL_MENUENTRY:
	rcolor.red = rcolor.green = rcolor.blue = 80;
	rcolor.alpha = 0;
	/**/
	ROperateLine(image, RAddOperation, 1, 0, width-2, 0, &rcolor);
	/**/

	ROperateLine(image, RAddOperation, 0, 0, 0, height-1, &rcolor);

	rcolor.red = rcolor.green = rcolor.blue = 40;
	rcolor.alpha = 0;
	ROperateLine(image, RSubtractOperation, width-1, 0, width-1, 
		     height-1, &rcolor);

	/**/
	ROperateLine(image, RSubtractOperation, 1, height-2, width-2,
		     height-2, &rcolor);

	rcolor.red = rcolor.green = rcolor.blue = 0;
	rcolor.alpha = 255;
	RDrawLine(image, 0, height-1, width-1, height-1, &rcolor);
	/**/
	break;

    }
}

- (RImage *)finishProcessing:(RImage *)anImage width:(int)aWidth
    height:(int)aHeight relief:(int)aRelief
{
    IWMTRACE;

    RImage *image = [self checkImage:anImage width:aWidth height:aHeight];
    int d = [self bevelDepthForRelief:aRelief];

    if (0 < d)
        RBevelImage(image, d);
    else if (0 > d)
        [self bevelImage:image relief:d];

    return image;

}

- (void)dealloc
{
    XFreeGC(GlobalDisplay, gc);

    [super dealloc];
}

@end

