
/*
 * $Id: IWMWindowManager+Defaults.m,v 1.1 2004/06/13 06:50:45 copal Exp $
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


@implementation IWMWindowManager (DefaultsMethods)

/*
 * apply any defaults-based overrides to IWM
 */
- (void)applyOverridesToWindowManager
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    id                   tmp = nil;
    
    if ((tmp = [self valueForDefaultsKey:BUTTON1_DEFAULT]))
    {
        [self setButton1:tmp];
    }

    if ((tmp = [self valueForDefaultsKey:BUTTON2_DEFAULT]))
    {
        [self setButton2:tmp];
    }
    
    if ((tmp = [self valueForDefaultsKey:BUTTON3_DEFAULT]))
    {
        [self setButton3:tmp];
    }
    
    if ((tmp = [self valueForDefaultsKey:OPAQUE_MOVEMENT_DEFAULT]) &&
        ([tmp isEqualToString:@"YES"]))
    {
        [self setOpaqueMovement:YES];
    }

    if ((tmp = [self valueForDefaultsKey:FOCUS_TYPE_DEFAULT]))
    {
        int intValue = atoi([tmp cString]);

        if ((intValue == IWM_FOCUS_MOUSE) || (intValue == IWM_FOCUS_CLICK) || 
            (intValue == IWM_FOCUS_SLOPPY))
        {
            focusType = intValue;
        }
    }

    if ((tmp = [self valueForDefaultsKey:COMPONENTS_DEFAULT]) && 
            [tmp respondsToSelector:@selector(count)])
    {
        NSString *name = nil;
        int       count, i;

        count = [tmp count];
        for (i = 0; i < count; i++)
        {
            name = [tmp objectAtIndex:i];
            [[IWMComponentManager defaultManager] loadComponentNamed:name];
        }
    }

    [pool release];
}

/*==========================================================================* 
   DEFAULTS METHODS
 *==========================================================================*/

/*
 * returns a current copy of the InterfaceWM defaults
 */
- (NSDictionary *)currentDefaults
{
    NSDictionary *defaults;

    defaults = [[NSUserDefaults standardUserDefaults]
                    persistentDomainForName:INTERFACE_DEFAULTS];

    return defaults;
}

/*
 * obtain a defaults value
 */
- (id)valueForDefaultsKey:(NSString *)key
{
    id value = nil;

    if ((value = [[self currentDefaults] objectForKey:key]))
    {
        if ([value respondsToSelector:@selector(cStringLength)])
        {
            if ([value cStringLength])
            {
                return value;
            }
        }
        
        if ([value respondsToSelector:@selector(count)])
        {
            if ([value count])
            {
                return value;
            }
        }
    }
    
    return nil;
}

/*
 * set a defaults value
 */
- (void)setValue:(id)value forDefaultsKey:(NSString *)key
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults      *defaults;
    NSMutableDictionary *iwm_defaults;

    defaults     = [NSUserDefaults standardUserDefaults];
    iwm_defaults = [NSMutableDictionary dictionary];
    
    [iwm_defaults addEntriesFromDictionary:[self currentDefaults]];
    [iwm_defaults setObject:value forKey:key];
    
    [defaults setPersistentDomain:iwm_defaults forName:INTERFACE_DEFAULTS];
    [defaults synchronize];

    [pool release];
}


- (void)saveDefaults
{
#if 0
    NSUserDefaults      *defaults;
    //NSMutableDictionary *newDefaults;

    // don't overwrite!!!
    return (void)0x0;

    defaults = [NSUserDefaults standardUserDefaults];

    [defaults synchronize];
    
    return (void)0x0;
#endif
}

@end