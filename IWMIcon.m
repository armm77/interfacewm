
/*
 * $Id: IWMIcon.m,v 1.4 2003/11/18 03:29:38 copal Exp $
 *
 * This file is part of Interface WM.
 *
 * Copyright (C) 2003, Ian Mondragon
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

#include "IWMIcon.h"
#include "IWMWindowManager.h"
#include "IWMWindow.h"
#include "IWMClient.h"
#include "IWMScreen.h"
#include "IWMTheme.h"

@implementation IWMIcon

- initForClient:(IWMClient *)aClient
{
    NSRect coords = [GlobalIWM availableIconCoordinates];
    
    // initialize the top-level window
    [super initAsTopLevelWithFrame:coords];
    
    // set the client reference for icon reference & focusing
    [self setClient:aClient];

    // set the image
    [self setImage:[[[client screen] theme] backgroundImage]];

    // set window type atom
    [self setWindowType:GlobalIWM->atoms.iwm_window_type_icon];

    [super configureNotify];
    [super unhide];
    [super raise];

    return self;
}

@end

