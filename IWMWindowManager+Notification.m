
/*
 * $Id: IWMWindowManager+Notification.m,v 1.1 2003/08/19 02:36:11 copal Exp $
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

#include "IWMWindowManager.h"
#include "IWMNotifications.h"
#include "IWMDebug.h"

#include <Foundation/NSNotification.h>

@implementation IWMWindowManager (NotificationMethods)

- (void)registerObservedNotifications
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // change name
    [center addObserver:self selector:@selector(changeClientName:)
        name:IWMClientChangeNameNotification object:nil];
    
    // focus
    [center addObserver:self selector:@selector(focusClient:)
        name:IWMClientFocusNotification object:nil];

    [center addObserver:self selector:@selector(unfocusClient:)
        name:IWMClientUnfocusNotification object:nil];

    // resize
    [center addObserver:self selector:@selector(resizeClient:)
        name:IWMClientResizeNotification object:nil];

    // move
    [center addObserver:self selector:@selector(moveClient:)
        name:IWMClientMoveNotification object:nil];

    // move & resize
    [center addObserver:self selector:@selector(moveResizeClient:)
        name:IWMClientMoveResizeNotification object:nil];

    // change screen
    [center addObserver:self selector:@selector(changeClientScreen:)
        name:IWMClientChangeScreenNotification object:nil];

    [center addObserver:self selector:@selector(didChangeClientScreen:)
        name:IWMClientDidChangeScreenNotification object:nil];

    // close
    [center addObserver:self selector:@selector(closeClient:)
        name:IWMClientCloseNotification object:nil];

    [center addObserver:self selector:@selector(didCloseClient:)
        name:IWMClientDidCloseNotification object:nil];

    // minimize
    [center addObserver:self selector:@selector(minimizeClient:)
        name:IWMClientMinimizeNotification object:nil];

    [center addObserver:self selector:@selector(didMinimizeClient:)
        name:IWMClientDidMinimizeNotification object:nil];

    [center addObserver:self selector:@selector(unminimizeClient:)
        name:IWMClientUnminimizeNotification object:nil];

    [center addObserver:self selector:@selector(didUnminimizeClient:)
        name:IWMClientDidUnminimizeNotification object:nil];

    // maximize
    [center addObserver:self selector:@selector(maximizeClient:)
        name:IWMClientMaximizeNotification object:nil];

    [center addObserver:self selector:@selector(didMaximizeClient:)
        name:IWMClientDidMaximizeNotification object:nil];

    [center addObserver:self selector:@selector(unmaximizeClient:)
        name:IWMClientUnmaximizeNotification object:nil];

    [center addObserver:self selector:@selector(didUnmaximizeClient:)
        name:IWMClientDidUnmaximizeNotification object:nil];

    // hide
    [center addObserver:self selector:@selector(hideClient:)
        name:IWMClientHideNotification object:nil];

    [center addObserver:self selector:@selector(didHideClient:)
        name:IWMClientDidHideNotification object:nil];

    [center addObserver:self selector:@selector(unhideClient:)
        name:IWMClientUnhideNotification object:nil];

    [center addObserver:self selector:@selector(didUnhideClient:)
        name:IWMClientDidUnhideNotification object:nil];

    // shade
    [center addObserver:self selector:@selector(shadeClient:)
        name:IWMClientShadeNotification object:nil];

    [center addObserver:self selector:@selector(didShadeClient:)
        name:IWMClientDidShadeNotification object:nil];

    [center addObserver:self selector:@selector(unshadeClient:)
        name:IWMClientUnshadeNotification object:nil];

    [center addObserver:self selector:@selector(didUnshadeClient:)
        name:IWMClientDidUnshadeNotification object:nil];

    return (void)0x0;
}

- (IWMClient *)obtainClientFromInfo:(NSDictionary *)info
{
    IWMClient   *client = nil;
    id           obj = nil;

    // check for direct reference to client object
    if ((obj = [info objectForKey:@"client"]))
    {
        return client = obj;
    }

    // check for reference to client id
    else if ((obj = [info objectForKey:@"client_id"]))
    {
        client = [self clientWithID:[obj intValue]];
    }

    // check for reference to a client's window
    else if ((obj = [info objectForKey:@"client_window"]))
    {
        client = [self clientWithWindow:[obj intValue] isParent:NO];
    }

    // check for reference to a client's parent window
    else if ((obj = [info objectForKey:@"client_parent_window"]))
    {
        client = [self clientWithWindow:[obj intValue] isParent:YES];
    }

    return client;
}

- changeClientName:(NSNotification *)notification
{
    IWMDebug(@"changeClientName: %@", [notification userInfo]);
    return self;
}

- focusClient:(NSNotification *)notification
{
    IWMDebug(@"focusClient: %@", [notification userInfo]);
    return self;
}

- unfocusClient:(NSNotification *)notification
{
    IWMDebug(@"unfocusCilent: %@", [notification userInfo]);
    return self;
}

- resizeClient:(NSNotification *)notification
{
    IWMDebug(@"resizeClient: %@", [notification userInfo]);
    return self;
}

- moveClient:(NSNotification *)notification
{
    IWMDebug(@"moveClient: %@", [notification userInfo]);
    return self;
}

- moveResizeClient:(NSNotification *)notification
{
    IWMDebug(@"moveResizeClient: %@", [notification userInfo]);
    return self;
}

- changeClientScreen:(NSNotification *)notification
{
    IWMDebug(@"changeClientScreen: %@", [notification userInfo]);
    return self;
}

- didChangeClientScreen:(NSNotification *)notification
{
    IWMDebug(@"didChangeClientScreen: %@", [notification userInfo]);
    return self;
}

- closeClient:(NSNotification *)notification
{
    IWMDebug(@"closeClient: %@", [notification userInfo]);
    return self;
}

- didCloseClient:(NSNotification *)notification
{
    IWMDebug(@"didCloseClient: %@", [notification userInfo]);
    return self;
}

- minimizeClient:(NSNotification *)notification
{
    IWMDebug(@"minimizeClient: %@", [notification userInfo]);
    return self;
}

- didMinimizeClient:(NSNotification *)notification
{
    IWMDebug(@"didMinimizeClient: %@", [notification userInfo]);
    return self;
}

- unminimizeClient:(NSNotification *)notification
{
    IWMDebug(@"unminimizeClient: %@", [notification userInfo]);
    return self;
}

- didUnminimizeClient:(NSNotification *)notification
{
    IWMDebug(@"didUnminimizeClient: %@", [notification userInfo]);
    return self;
}

- maximizeClient:(NSNotification *)notification
{
    IWMDebug(@"maximizeClient : %@", [notification userInfo]);
    return self;
}

- didMaximizeClient:(NSNotification *)notification
{
    IWMDebug(@"didMaximizeClient : %@", [notification userInfo]);
    return self;
}

- unmaximizeClient:(NSNotification *)notification
{
    IWMDebug(@"unmaximizeClient : %@", [notification userInfo]);
    return self;
}

- didUnmaximizeClient:(NSNotification *)notification
{
    IWMDebug(@"didUnmaximizeClient : %@", [notification userInfo]);
    return self;
}

- hideClient:(NSNotification *)notification
{
    IWMDebug(@"hideClient : %@", [notification userInfo]);
    return self;
}

- didHideClient:(NSNotification *)notification
{
    IWMDebug(@"didHideClient : %@", [notification userInfo]);
    return self;
}

- unhideClient:(NSNotification *)notification
{
    IWMDebug(@"unhideClient : %@", [notification userInfo]);
    return self;
}

- didUnhideClient:(NSNotification *)notification
{
    IWMDebug(@"didUnhideClient : %@", [notification userInfo]);
    return self;
}

- shadeClient:(NSNotification *)notification
{
    IWMDebug(@"shadeClient : %@", [notification userInfo]);
    return self;
}

- didShadeClient:(NSNotification *)notification
{
    IWMDebug(@"didShadeClient : %@", [notification userInfo]);
    return self;
}

- unshadeClient:(NSNotification *)notification
{
    IWMDebug(@"unshadeClient : %@", [notification userInfo]);
    return self;
}

- didUnshadeClient:(NSNotification *)notification
{
    IWMDebug(@"didUnshadeClient : %@", [notification userInfo]);
    return self;
}


@end

