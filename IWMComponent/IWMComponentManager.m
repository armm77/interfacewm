
/*
 * $Id: IWMComponentManager.m,v 1.2 2003/12/12 04:30:51 copal Exp $
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

#define BOOL XWINDOWSBOOL
#include "InterfaceWM.h"
#undef BOOL

#include "IWMComponentManager.h"
#include "IWMComponent.h"
#include "IWMCoreUtilities.h"

#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSUtilities.h>
#include <Foundation/NSPathUtilities.h>
#include <Foundation/NSFileManager.h>
#include <Foundation/NSNotification.h>
#include <Foundation/NSAutoreleasePool.h>

NSString *iwmcomponentString = @"iwmcomponent";

@implementation IWMComponentManager

+ defaultManager
{
    static IWMComponentManager *_IWMCMSharedInstance;
    
    if (!_IWMCMSharedInstance)
    {
	_IWMCMSharedInstance = [[[self class] alloc] init];
#ifdef DEBUG
        NSLog(@"Initialized IWMComponentManager");
#endif
    }
    
    return _IWMCMSharedInstance;
}

- init
{
    _userhome           = [[NSString alloc] initWithString:NSHomeDirectory()];
    _searchPaths        = [[NSMutableArray alloc] init];
    _loadedComponents   = [[NSMutableArray alloc] init];

    [self reloadSearchPaths];
    
    return self;
}

- (void)reloadSearchPaths
{
    NSMutableArray      *array = [NSMutableArray array];
    NSArray             *defpaths = nil;
    
    // default path: ~/GNUstep/Library/InterfaceWM/Components
    [array addObject:
        [_userhome stringByAppendingPathComponent:INTERFACE_COMPONENT_DIR]];
    
    // paths specified in defaults
    if ((defpaths = iwm_default_value(COMPONENT_DIRECTORIES)))
    {
        [array addObjectsFromArray:defpaths];
    }

    [self setSearchPaths:array];
}

- (NSMutableArray *)searchPaths
{
    if (!_searchPaths)
    {
        _searchPaths = [[NSMutableArray alloc] init];
        [self reloadSearchPaths];
    }
    
    return _searchPaths;
}

- (void)setSearchPaths:(NSMutableArray *)paths
{
    [_searchPaths autorelease];
    _searchPaths = [paths retain];
}

- (void)addSearchPath:(NSString *)path
{
    if (path && [path cStringLength])
    {
	[[self searchPaths] addObject:path];
    }
}

- (void)removeSearchPath:(NSString *)path
{
    if (path && [path cStringLength])
    {
	[[self searchPaths] removeObject:path];
    }
}

- (NSMutableArray *)availableComponentPaths
{
    NSMutableArray      *array = [NSMutableArray array];
    NSMutableArray      *searchPaths = [self searchPaths];
    NSString            *path = nil;
    NSArray             *contents = nil;
    NSFileManager       *manager = [NSFileManager defaultManager];
    int                  pathCount, i;
    int                  contentCount, j;
    
    pathCount = [searchPaths count];
    for (i = 0; i < pathCount; i++)
    {
        path     = [searchPaths objectAtIndex:i];
        contents = [manager directoryContentsAtPath:path];

        contentCount = [contents count];
        for (j = 0; j < contentCount; j++)
        {
            NSString *element = [contents objectAtIndex:j];
            if ([[element pathExtension] isEqualToString:iwmcomponentString])
            {
                [array addObject:
                    [path stringByAppendingPathComponent:element]];
            }
        }
    }

    return array;
}

- (NSMutableArray *)availableComponentNames
{
    NSMutableArray      *paths = [self availableComponentPaths];
    NSMutableArray      *names = [NSMutableArray array];
    NSString            *aPath = nil;
    int                  count, i;

    count = [paths count];
    for (i = 0; i < count; i++)
    {
        aPath = [paths objectAtIndex:i];
        [names addObject:
            [[aPath lastPathComponent] stringByDeletingPathExtension]];
    }

    return names;
}

- (NSMutableArray *)loadedComponents
{
    if (!_loadedComponents)
    {
        _loadedComponents = [[NSMutableArray alloc] init];
    }

    return _loadedComponents;
}

- (BOOL)loadComponentNamed:(NSString *)name
{
    NSMutableArray      *loaded = [self loadedComponents];
    IWMComponent        *component = nil;
    IWMComponent        *tmp = nil;
    NSString            *path = nil;
    int                  count, i;

    // determine if named component has already been loaded
    count = [loaded count];
    for (i = 0; i < count; i++)
    {
        tmp = [loaded objectAtIndex:i];
        
        if ([[tmp name] isEqualToString:name])
        {
            NSLog(@"IWMComponent already loaded:%@", name);
        }
    }
    
    // load the component
    if ((path = [self pathForComponentNamed:name]))
    {
        component = [IWMComponent componentWithPath:path];
        NSLog(@"Loaded component:\n%@", component);

        return YES;
    }
    
    NSLog(@"Path for component \"%@\" not found", name);
    
    return NO;
}

- (NSString *)pathForComponentNamed:(NSString *)name
{
    NSMutableArray *components = [self availableComponentPaths];
    int count, i;

    count = [components count];
    for (i = 0; i < count; i++)
    {
        NSString *path = [components objectAtIndex:i];
        if (([[[path lastPathComponent] stringByDeletingPathExtension]
                    isEqualToString:name]))
        {
            return path;
        }
    }
    
    return nil;
}

- (void)dealloc
{
    [_userhome release];
    [_searchPaths release];
    [_loadedComponents release];

    [super dealloc];
}

@end

