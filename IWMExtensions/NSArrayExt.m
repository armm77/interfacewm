
/*
 * $Id: NSArrayExt.m,v 1.1 2003/08/19 01:42:54 copal Exp $
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

#include "NSArrayExt.h"
#include <Foundation/NSValue.h>
#include <Foundation/NSAutoreleasePool.h>

@implementation NSMutableArray (IWMExtentions)

- (void)cycleObjects
{
    id tmp = [self objectAtIndex:0];

    [self removeObject:tmp];
    [self addObject:tmp];

    return (void)0x0;
}

- (int)intAtIndex:(int)anIndex
{
    id object = [self objectAtIndex:anIndex];
    
    if ([object respondsTo:@selector(intValue)])
        return [object intValue];
    else
        return 0;
}

- (void)addInt:(int)anInt
{
    [self addObject:[NSNumber numberWithInt:anInt]];
}

- (void)removeInt:(int)anInt
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSNumber *number = [NSNumber numberWithInt:anInt];
    
    [self removeObject:number];

    [pool release];
}

@end

