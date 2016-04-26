
/*
 * $Id: IWMWindowManager+Client.m,v 1.3 2004/06/15 05:22:21 copal Exp $
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

@implementation IWMWindowManager (ClientMethods)


- (IWMClient *)clientWithID:(int)anID
{
    if (anID)
    {
        IWMClient *client = nil;
        int count, i;

        count = [clientArray count];
        for (i = 0; i < count; i++)
        {
            client = [clientArray objectAtIndex:i];
            if (anID == [client clientID])
            {
                return client;
            }
        }
    }
    
    return nil;
}

- (IWMClient *)clientWithWindow:(Window)window isParent:(BOOL)parent
{
    int i, count = [clientArray count];

    if (count)
    {
        IWMClient *client = nil;

        for (i = 0; i < count; i++)
        {
            client = [clientArray objectAtIndex:i];
            if (client && [client containsXWindow:window isParent:parent])
            {
                return client;
            }
        }
    }

    return nil;
}


- (void)updateClientWindowList
{
    unsigned int count, i;
    
    IWMTRACE;
    
    count = [clientArray count];
    IWMDebug(@"Got %d client(s) in list", count);
    
    if (count > 0)
    {
        Window list[count];

		// loop over clients in the array, adding each client's
		// application window number to the list (EWMH)
        for (i = 0; i < count; i++)
        {
            IWMClient *client = nil;
            IWMWindow *tmp = nil;
            
            client = [clientArray objectAtIndex:i];
            IWMDebug(@"Got client %d: %@", i, client);
            
            tmp = [client window];
            IWMDebug(@"Client window info %@", tmp);
            
            list[i] = [tmp xWindow];
        }

        IWMDebug(@"updateClientWindowList: count: %i", i);

        // XXX - update _NET_CLIENT_LIST
        [[self rootWindow] setWindowProperty:atoms.net_client_list
            data:(unsigned char *)list elements:count];
    }
}

- (Window *)clientWindowList
{
    Window *windows = NULL;
    int count;
    
    IWMTRACE;
    
    // XXX - obtain _NET_CLIENT_LIST
    windows = (Window *)[[self rootWindow] property:atoms.net_client_list
                                type:XA_WINDOW count:&count];

    IWMDebug(@"clientWindowList: count: %i", count);
    
    return windows;
}

- (NSArray *)clientNames
{
    IWMClient *client = nil;
    NSMutableArray *names = [NSMutableArray array];
    int count, i;
    
    IWMTRACE;
    
    count = [clientArray count];
    for (i = 0; i < count; i++)
    {
        client = [clientArray objectAtIndex:i];
        [names addObject:[client name]];
    }
    
    return names;
}

- (NSString *)longestClientName
{
    NSArray *clientNames = [self clientNames];
    int count, length, longest, i, j;

    longest = j = 0;

    count = [clientNames count];
    for (i = 0; i < count; i++)
    {
        if ((length = [[clientNames objectAtIndex:i] cStringLength]) > longest)
        {
            j = i;
            longest = length;
        }
    }

    return [clientNames objectAtIndex:j];
}

- (void)addClient:(IWMClient *)aClient
{
    [clientArray addObject:aClient];
    [self setHeadClient:aClient];
}

- (void)removeClient:(IWMClient *)aClient
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    IWMTRACE;
    
    [aClient close];
    [clientArray removeObject:aClient];
    [self updateClientWindowList];

    if (_headClientIndex >= [clientArray count])
    {
        _headClientIndex = 0;
    }
    
    [pool release];
}


- (IWMClient *)headClient
{
    if ([clientArray count])
        return [clientArray objectAtIndex:_headClientIndex];

    return nil;
}

- (void)setHeadClient:(IWMClient *)aClient
{
    IWMTRACE;
    
    if (aClient)
    {
        int i, count = [clientArray count];
        Window window[1];
        
        window[0] = [[aClient window] xWindow];
        
        _headClientIndex = [clientArray indexOfObject:aClient];
        
        // unfocus all clients in clientArray
        for (i = 0; i < count; i++)
        {
            IWMClient *tmp = [clientArray objectAtIndex:i];
            if (tmp != aClient)
                [tmp unfocus];
        }
        
        // now display the target client and grab the focus
        [aClient display];
        [aClient raise];
        [aClient configureNotify];
        [aClient focus];
        
        // update the _NET_CLIENT_LIST property
        [self updateClientWindowList];
        
        // set _NET_ACTIVE_WINDOW property
        [[self rootWindow] setWindowProperty:atoms.net_active_window
            data:(unsigned char *)window elements:1];
    }
}

- (void)cycleClients
{
    unsigned int count = [clientArray count];
    
	// only perform a cycle if there is more than one client
    if (1 < count)
    {
		// unfocus all clients in place
        [clientArray makeObjectsPerform:@selector(unfocus)];
        
		// if the head client is the last client in the array,
		// change the head client index to 0
        if (++_headClientIndex >= count)
            _headClientIndex = 0;

        // XXX - yuk.  redo.
        [self setHeadClient:[clientArray objectAtIndex:_headClientIndex]];
    }
}

- (void)clientIsClosing:(IWMClient *)aClient
{
    return (void)0x0;
}

@end
