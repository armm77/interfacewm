
/*
 * $Id: IWMComponentManager.h,v 1.2 2005/07/28 00:07:22 copal Exp $
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

#ifndef _IWMCOMPONENTMANAGER_H_
#define _IWMCOMPONENTMANAGER_H_ 1

#include <Foundation/NSObject.h>

@class NSMutableArray;
@class NSString;

@interface IWMComponentManager : NSObject
{
@private
    NSString		*_userhome;
    NSMutableArray	*_searchPaths;
    NSMutableArray	*_loadedComponents;
}

/*!
 * @method defaultManager
 * @abstract Returns shared instance of IWMComponentManager
 */
+ defaultManager;

- init;

- (void)reloadSearchPaths;

- (NSMutableArray *)searchPaths;
- (void)setSearchPaths:(NSMutableArray *)paths;

- (void)addSearchPath:(NSString *)path;
- (void)removeSearchPath:(NSString *)path;

- (NSMutableArray *)availableComponentPaths;
- (NSMutableArray *)availableComponentNames;

- (NSMutableArray *)loadedComponents;
- (BOOL)loadComponentNamed:(NSString *)name;

- (NSString *)pathForComponentNamed:(NSString *)name;

@end

#endif /* _IWMCOMPONENTMANAGER_H_ */

