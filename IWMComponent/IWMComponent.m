
/*
 * $Id: IWMComponent.m,v 1.1 2003/08/19 02:01:36 copal Exp $
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

#include "IWMComponent.h"

#define BOOL XWINDOWSBOOL
#include "IWMWindowManager.h"
#undef BOOL

#include <Foundation/NSString.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSBundle.h>
#include <Foundation/NSCalendarDate.h>
#include <Foundation/NSPathUtilities.h>

NSString *IWMComponentNameString        = @"IWMComponentName";
NSString *IWMComponentDescriptionString = @"IWMComponentDescription";
NSString *IWMComponentVersionString     = @"IWMComponentVersion";

@implementation IWMComponent

/*
 * class methods
 */

+ componentWithPath:(NSString *)path
{
    return [[[IWMComponent alloc] initWithPath:path] autorelease];
}

- initWithPath:(NSString *)path
{
    if ((self = [super init]))
    {
        // load the bundle containing the component
        if ((_bundle = [[NSBundle alloc] initWithPath:path]))
        {
            // verify that the principal class is an IWMComponent
            //if ([[_bundle principalClass] isKindOfClass:[self class]])
            {
                //_class    = [_bundle principalClass];
                _class    = NULL;
                _username = NSUserName();
                _loadTime = [NSCalendarDate calendarDate];
                _debug    = NO;
            }
        }

        return self;
    }

    return nil;
}

/*
 * accessor methods
 */

- (NSDictionary *)infoDictionary
{
    return [_bundle infoDictionary];
}

- (NSString *)name
{
    return [[self infoDictionary] objectForKey:IWMComponentNameString];
}

- (NSString *)componentDescription
{
    return [[self infoDictionary] objectForKey:IWMComponentDescriptionString];
}

- (NSString *)version
{
    return [[self infoDictionary] objectForKey:IWMComponentVersionString];
}

- (NSString *)username
{
    return _username;
}

- (BOOL)debug
{
    return _debug;
}

- (NSString *)description
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    [dict addEntriesFromDictionary:[self infoDictionary]];
    [dict setObject:_username forKey:@"Username"];
    [dict setObject:_loadTime forKey:@"Load Time"];

    return ([dict description]);
}

- (void)mouseAction
{
    NSLog(@"Method not implemented: mouseAction");
}

- (void)dealloc
{
    [_bundle release];
    [_username release];
    [_loadTime release];

    [super dealloc];
}

@end

