
/*
 * $Id: IWMWindowManager+Icon.m,v 1.1 2004/06/13 06:50:45 copal Exp $
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

@implementation IWMWindowManager (IconMethods)


- (NSRect)availableIconCoordinates
{
    NSString    *tmp = nil;
    NSRect       coords;

    tmp = [self valueForDefaultsKey:ICON_WIDTH_DEFAULT];
    coords.size.width = tmp ? atoi([tmp cString]) : 64;
    
    tmp = [self valueForDefaultsKey:ICON_HEIGHT_DEFAULT];
    coords.size.height = tmp ? atoi([tmp cString]) : 64;
    
    coords.origin.x = ([clientArray count] * (int)coords.size.width);
    coords.origin.y = ([[self currentScreen] height] - (int)coords.size.height);

    return coords;
}


@end
