
/*
 * $Id: IWMResizebar.m,v 1.6 2003/11/26 23:47:55 copal Exp $
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

#include "IWMResizebar.h"
#include "InterfaceWM.h"
#include "IWMWindowManager.h"
#include "IWMClient.h"
#include "IWMTheme.h"
#include "IWMScreen.h"
#include "IWMDebug.h"

@implementation IWMResizebar

- initForClient:(IWMClient *)aClient
{
    IWMWindow *parent = [aClient parent];
    IWMScreen *screen = [aClient screen];
    IWMTheme *theme = [screen theme];
    NSRect frame;

    frame.origin = [aClient origin];
    frame.size.width = [aClient width] - (GRIP_WIDTH * 2);
    frame.size.height = [aClient resizebarHeight];

    // initialize main resizebar
    [super initWithParent:parent frame:frame];

    [self setClient:aClient];
    [self setWindowType:GlobalIWM->atoms.iwm_window_type_resizebar];
    [self setRolloverCursor:[screen downResizeCursor]];
    [self setImage:[theme resizebarImage]];

    // create leftGrip
    frame.size.width = GRIP_WIDTH;
    leftGrip = [[IWMWindow alloc] initWithParent:parent frame:frame];

    [leftGrip setWindowType:GlobalIWM->atoms.iwm_window_type_left_grip];
    [leftGrip setRolloverCursor:[screen leftResizeCursor]];
    [leftGrip setImage:[theme focusedTitlebarImage]];

    // create rightGrip
    rightGrip = [[IWMWindow alloc] initWithParent:parent frame:frame];

    [rightGrip setWindowType:GlobalIWM->atoms.iwm_window_type_right_grip];
    [rightGrip setRolloverCursor:[screen rightResizeCursor]];
    [rightGrip setImage:[theme focusedTitlebarImage]];

    //[self setInto:parent x:GRIP_WIDTH y:([client height] - height)];

    return self;
}

- (void)redraw
{
    IWMScreen *screen = [client screen];
    int height = [client resizebarHeight];
    int y = [client height] - height;
    NSSize aSize;
    NSPoint aPoint;

    IWMTRACE;

    // resize
    aSize.width = [client width] - (GRIP_WIDTH * 2);
    aSize.height = [client resizebarHeight];
    [self setSize:aSize];
    
    // set image
    [self setImage:[[screen theme] resizebarImage]];
    
    // place left grip
    aPoint.x = 0;
    aPoint.y = y;
    [leftGrip setTopLeftPoint:aPoint];
    
    // place resizebar
    aPoint.x = GRIP_WIDTH;
    aPoint.y = y;
    [self setTopLeftPoint:aPoint];
    
    // place right grip
    aPoint.x = [client width] - GRIP_WIDTH;
    aPoint.y = y;
    [rightGrip setTopLeftPoint:aPoint];

    [leftGrip clear];
    [rightGrip clear];
    [self clear];
}

- (void)hide
{
    [leftGrip hide];
    [rightGrip hide];
    [super hide];
}

- (void)unhide
{
    [super unhide];
    [leftGrip unhide];
    [rightGrip unhide];
}

- (IWMWindow *)leftGrip
{
    return leftGrip;
}

- (IWMWindow *)rightGrip
{
    return leftGrip;
}

- (void)dealloc
{
    [leftGrip release];
    [rightGrip release];

    [super dealloc];
}

@end
