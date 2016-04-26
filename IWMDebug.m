
/*
 * $Id: IWMDebug.m,v 1.7 2003/11/18 03:40:12 copal Exp $
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

#include "IWMDebug.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSString.h>

#include <stdlib.h>
#include <string.h>

/*
 * If DEBUG is defined during compile-time, this function dumps a formatted
 * message according to level. The levels are as follows:
 *
 *   IWM_Fatal -- fatal error, process will abort(3)
 *   IWM_Error -- error message
 *   IWM_Warn -- warning message
 *   IWM_Note -- notice message
 *   IWM_Debug -- debugging info
 *   IWM_Trace -- method and function trace
 *
 * Note: For convenience, instead of IWMLog(IWM_Trace, ...), you can use
 *       IWMTRACE.
 */

#ifdef DEBUG

/* public */
void IWMLog(int level, NSString *format, ...)
{
    // Check the level
    if( GSDebugSet(@"verbose") )
    {
        // If --GNU-Debug=trace isn't set explicitly, return
        if( (level == IWM_Trace) && ! GSDebugSet(@"trace") )
            return (void)0x0;
    }
    else
    {
        if( ! GSDebugSet(@"all") )
        {
            switch( level )
            {
                case IWM_Fatal :
                    // Always print Fatal errors
                    break;
                    
                case IWM_Error :
                    if( ! GSDebugSet(@"error") )
                        return;
                    break;
                    
                case IWM_Warn :
                    if( ! GSDebugSet(@"warn") )
                        return;
                    break;
                    
                case IWM_Note :
                    if( ! GSDebugSet(@"note") )
                        return;
                    break;
                    
                case IWM_Debug :
                    if( ! GSDebugSet(@"debug") )
                        return;
                    break;
                    
                case IWM_Trace :
                    if( ! GSDebugSet(@"trace") )
                        return;
                    break;
            }
        }
    }
    
    // Now create the message
    {
        va_list ap;
        NSMutableString *temp = nil;
        
        // Create a temporary string that holds the complete message
        va_start(ap, format);
        {
            temp = [[NSMutableString allocWithZone:NSDefaultMallocZone()]
                initWithFormat:format arguments:ap];
        }
        va_end(ap);
        
        // If we're tracing, check whether we got a C function and add '()'
        // otherwise indicate the debug level
        switch (level)
        {
            case IWM_Fatal :
                [temp insertString: @"Fatal: " atIndex: 0];
                break;
                
            case IWM_Error :
                [temp insertString: @"[ERROR] " atIndex: 0];
                break;
                
            case IWM_Warn :
                [temp insertString: @"[WARNING] " atIndex: 0];
                break;
                
            case IWM_Note :
                [temp insertString: @"[NOTE] " atIndex: 0];
                break;
                
            case IWM_Debug :
                [temp insertString: @"[DEBUG] " atIndex: 0];
                break;
                
            case IWM_Trace :
                if( 0 == [temp rangeOfString: @"["].length )
                    [temp appendString: @"()"];
                break;
        }
        
        // Dump it and clean up
        {
            NSLog(@"%@", temp);
            [temp release];
        }
        
        // abort() if it's fatal
        if( level <= IWM_Fatal )
            abort();
    }
    
    return (void)0x0;
}

#endif /* DEBUG */

