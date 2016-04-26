
/*
 * $Id: IWMController.m,v 1.6 2003/12/12 04:30:07 copal Exp $
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

#include "InterfaceWM.h"
#include "IWMWindowManager.h"
#include "IWMDebug.h"

#if 0

#include <Foundation/NSString.h>
#include <Foundation/NSAutoreleasePool.h>

#endif /* 0 */

static void print_usage()
{
    fprintf(stderr, "Usage: interfacewm [-options]\n\n");
    fprintf(stderr, "  -d host:display\tdisplay to use\n");
    fprintf(stderr, "  -h\t\t\tshow this message\n");
    fprintf(stderr, "\n");
}

/* public */
int main(int argc, char * const *argv, char * const *envp)
{
    NSAutoreleasePool   *_pool = [[NSAutoreleasePool alloc] init];
    char                *display = malloc(100);
    int                  i;
    BOOL                 showHelp = YES;
    
    // default display name
    strcpy(display, ":0");
    
    // parse the command line arguments
    for (i = 1; i < argc; i++)
    {
        if (((strcmp(argv[i], "-display") == 0) || 
                    (strcmp(argv[i], "-d") == 0)) && 
                ((i + 1) < argc))
        {
            display = argv[++i];
            showHelp = NO;
            
            continue;
        }
        
        // CBV: Ignore unknown options, to allow usage of --GNU-Debug=...
    }
    
    if (showHelp)
    {
        print_usage();
        exit(EXIT_SUCCESS);
    }
    
    (IWMWindowManager *)GlobalIWM = [[IWMWindowManager alloc]
        initWithDisplayName:[NSString stringWithCString:display]];
    
    [GlobalIWM run];
    [GlobalIWM release];
    
    [_pool release];
    
    return EXIT_SUCCESS;
}

