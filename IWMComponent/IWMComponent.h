
/*
 * $Id: IWMComponent.h,v 1.1 2003/08/19 02:01:36 copal Exp $
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

#ifndef _IWMCOMPONENT_H_
#define _IWMCOMPONENT_H_ 1

#include <Foundation/NSObject.h>

@class NSBundle;
@class NSString;
@class NSCalendarDate;

/*
 * an IWMComponent's Info.plist must contain the following key/value pairs:
 *
 * IWMComponentName        : Short name for the component
 * IWMComponentDescription : Short summary of the functionality
 * IWMComponentVersion     : Version information
 */

extern NSString *IWMComponentNameString;
extern NSString *IWMComponentDescriptionString;
extern NSString *IWMComponentVersionString;

@interface IWMComponent : NSObject
{
@private
    NSBundle            *_bundle;
    Class                _class;
    NSString            *_username;
    BOOL                 _debug;
    NSCalendarDate      *_loadTime;
}

/*
 * class methods
 */

+ componentWithPath:(NSString *)name;

- initWithPath:(NSString *)path;

/*
 * accessor methods
 */

- (NSDictionary *)infoDictionary;
- (NSString *)name;
- (NSString *)componentDescription;
- (NSString *)version;
- (NSString *)username;
- (BOOL)debug;

- (NSString *)description;

- (void)mouseAction;

@end

#endif /* _IWMCOMPONENT_H_ */

