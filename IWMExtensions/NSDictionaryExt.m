
/*
 * $Id: NSDictionaryExt.m,v 1.1 2003/08/19 01:42:54 copal Exp $
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

#include "NSDictionaryExt.h"
#include <Foundation/NSString.h>
#include <Foundation/NSValue.h>

@implementation NSMutableDictionary (IWMExtentions)

- (void)setInt:(int)value forKey:(NSString *)key
{
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (int)intForKey:(NSString *)key
{
    id tmp = [self objectForKey:key];

    if (tmp && [tmp respondsToSelector:@selector(intValue)])
    {
        return [tmp intValue];
    }

    return 0;
}

- (id)objectForIntKey:(int)anInt
{
    return [self objectForKey:[NSNumber numberWithInt:anInt]];
}

- (void)setObjectForKey:(NSString *)aKey from:(NSDictionary *)aDictionary
{
    id object;

    if (!(object = [aDictionary objectForKey:aKey]))
    {
        object = @"";
    }
    
    [self setObject:object forKey:aKey];
}

- (NSString *)verifiedStringForKey:(NSString *)aKey
{
    NSString *tmp;

    tmp = [self objectForKey:aKey];

    if (tmp && [tmp cStringLength])
    {
        return tmp;
    }

    return nil;
}

@end
