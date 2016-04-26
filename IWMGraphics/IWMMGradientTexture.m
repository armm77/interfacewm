
/*
 * $Id: IWMMGradientTexture.m,v 1.1 2003/11/30 22:42:44 copal Exp $
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

#include "IWMMGradientTexture.h"

#define BOOL XWINDOWSBOOL
#include <Foundation/NSObject.h>
#include <IWMScreen.h>
#include <IWMWindow.h>
#include <IWMWindowManager.h>
#undef BOOL

@implementation IWMMGradientTexture

- initWithScreen:(IWMScreen *)aScreen style:(int)aStyle
    colors:(RColor **)theColors
{
    XGCValues gcv;
    int i;

    [super init];
    
    type = aStyle;
    subtype = 0;
    
    i=0;
    while (theColors[i]!=NULL) i++;
    i--;
    
    color.red = (theColors[0]->red<<8);
    color.green = (theColors[0]->green<<8);
    color.blue =  (theColors[0]->blue<<8);
    
    colors = theColors;

    XAllocColor(GlobalDisplay, [aScreen colormap], &color);
    gcv.background = gcv.foreground = color.pixel;
    gcv.graphics_exposures = False;
    gc = XCreateGC(GlobalDisplay, ([aScreen rootWindow])->xWindow,
            GCForeground|GCBackground|GCGraphicsExposures, &gcv);

    return self;
}

- (RImage *)renderImageWithWidth:(int)aWidth height:(int)aHeight
    relief:(int)aRelief
{
    switch (type)
     case WTEX_MHGRADIENT:
	subtype = RGRD_HORIZONTAL;
        break;
        
     case WTEX_MVGRADIENT:
	subtype = RGRD_VERTICAL;
	break;
        
     case WTEX_MDGRADIENT:
	subtype = RGRD_DIAGONAL;
        break;
        
    RImage *image = RRenderMultiGradient(aWidth, aHeight, 
				     &colors[1], subtype);

    return [super finishProcessing:image width:aWidth height:aHeight
        relief:aRelief];
}

@end

