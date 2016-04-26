
/*
 * $Id: IWMClient+Initialization.m,v 1.2 2005/07/28 00:09:03 copal Exp $
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
 
 #import "IWMClient.h"

@implementation IWMClient (InitializationMethods)

- initializeFrame
{
    XSizeHints *sizeHints = [window wmNormalHints];
    int xMax = DisplayWidth(GlobalDisplay, _screenNumber);
    int yMax = DisplayHeight(GlobalDisplay, _screenNumber);

    // base/minimum size specified (base size is used over minimum size)
    if (sizeHints->flags & PBaseSize)
    {
        minimumSize.width = sizeHints->base_width;
        minimumSize.height = sizeHints->base_height;
    }
    else if (sizeHints->flags & PMinSize)
    {
        minimumSize.width = sizeHints->min_width;
        minimumSize.height = sizeHints->min_height;
    }

    // maximum size specified
    if (sizeHints->flags & PMaxSize)
    {
        maximumSize.width = sizeHints->max_width;
        maximumSize.height = sizeHints->max_height;

        IWMDebug(@"Maximum size: %i x %i", (int)maximumSize.width,
                (int)maximumSize.height);
    }

    // resize increments
    if (sizeHints->flags & PResizeInc)
    {
        resizeIncrements.width = sizeHints->width_inc;
        resizeIncrements.height = sizeHints->height_inc;
    }

    /* XXX
     * width/height and  x/y are supposed to be obsolete according to
     * ICCCM specification, but where do we get the preliminary info
     * from then?
     */
    
    // user-specified size
    if (sizeHints->flags & USSize)
    {
        _frame.size.width = sizeHints->width;
        _frame.size.height = sizeHints->height;
    }

    // user-specified position
    if (sizeHints->flags & USPosition)
    {
        _frame.origin.x = sizeHints->x;
        _frame.origin.y = sizeHints->y;
    }
    else
    {
        XPoint position;
        
        position = [GlobalIWM mousePosition];

        _frame.origin.x = ((position.x / (float)xMax) * 
                (xMax - _frame.size.width));

        _frame.origin.y = ((position.y / (float)yMax) * 
                (yMax - [self titlebarHeight] - _frame.size.height));
    }

    return self;
}

- initializeDecorations
{
    decor.border           = YES;
    decor.resizebar        = YES;
    decor.titlebar         = YES;
    decor.close_button     = YES;
    decor.minimize_button  = YES;
    decor.icon             = YES;

    if (![self initializeEWMHDecorations])
    {
        [self initializeMOTIFDecorations];
    }

    return self;
}

- initializeEWMHDecorations
{
    Atom *data;
    Atom allowedActions[10];
    int count, i = 0;

    IWMTRACE;

    data = (Atom *)[window property:GlobalIWM->atoms.net_wm_window_type
                        type:XA_ATOM count:&count];

    if (data && data[0])
    {
        IWMDebug(@"Initializing decor via EWMH hints...", nil);
        IWMDebug(@"EWMH hint: %s", XGetAtomName(GlobalDisplay, data[0]));
        
        if (data[0] == GlobalIWM->atoms.net_wm_window_type_desktop)
        {
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_dock ||
                data[0] == GlobalIWM->atoms.kde_net_wm_window_type_override)
        {
            decor.resizebar = NO;
            decor.titlebar = NO;
            decor.icon = NO;
            decor.close_button = NO;
            decor.minimize_button = NO;
            decor.border = NO;

            if ([[window xClassInstance] isEqualToString:@"GNUstep"])
                NSLog(@"\n#\n#GNUstep Dock Icon\n#");
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_toolbar)
        {
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_menu)
        {
            decor.resizebar = NO;
            decor.icon = NO;
            decor.minimize_button = NO;
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_utility)
        {
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_splash)
        {
            decor.resizebar = NO;
            decor.titlebar = NO;
            decor.icon = NO;
            decor.close_button = NO;
            decor.minimize_button = NO;
            decor.border = NO;
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_dialog)
        {
            decor.resizebar = NO;
            decor.icon = NO;
            decor.minimize_button = NO;
        }
        else if (data[0] == GlobalIWM->atoms.net_wm_window_type_normal)
        {
        }
	
        // _NET_WM_ALLOWED_ACTIONS property
	
	// allow resizing if resizebar is present
	if (decor.resizebar)
	    allowedActions[i++] = GlobalIWM->atoms.net_wm_action_resize;
	// allow shading if titlebar is present
	if (decor.titlebar)
	    allowedActions[i++] = GlobalIWM->atoms.net_wm_action_shade;
	// allow minimization if minimize button is present
	if (decor.minimize_button)
	    allowedActions[i++] = GlobalIWM->atoms.net_wm_action_minimize;
	// allow closing if close button is present
	if (decor.close_button)
	    allowedActions[i++] = GlobalIWM->atoms.net_wm_action_close;
	
	// XXX - fix these
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_move;
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_stick;
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_maximize_horz;
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_maximize_vert;
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_fullscreen;
	allowedActions[i++] = GlobalIWM->atoms.net_wm_action_change_desktop;
	
	// set _NET_WM_ALLOWED_ACTIONS with updated array
	[window setProperty:GlobalIWM->atoms.net_wm_allowed_actions type:XA_ATOM
            format:32 data:(unsigned char *)allowedActions elements:i];

        return self;
    }

    return nil;
}

- initializeMOTIFDecorations
{
    //int                  num;
    //Atom                 atom_return;
    //unsigned long        /*num,*/ len;
    MWMHints            *mwm_hints;

    IWMTRACE;
    
    // obtain the hints
#if 0
    int num;
    if ((mwm_hints = (MWMHints *)[window property:GlobalIWM->atoms.motif_wm_hints
                            type:GlobalIWM->atoms.motif_wm_hints count:&num]))
#endif
#if 1
    Atom atom_return;
    unsigned long num, len;
    int format;

    if ((XGetWindowProperty(GlobalDisplay, [window xWindow],
                GlobalIWM->atoms.motif_wm_hints, 0, MWM_HINTS_ELEMENTS, 
                False, GlobalIWM->atoms.motif_wm_hints, &atom_return, 
                &format, &num, &len, (unsigned char **)&mwm_hints) == Success)
            && mwm_hints)
#endif
    {
        IWMDebug(@"Initializing decor via MOTIF hints...", nil);
        
        // verify that we obtained three elements
        if (num == MWM_HINTS_ELEMENTS)
        {
            if (mwm_hints->flags & MWM_HINTS_DECORATIONS)
            {
                // all decorations are present
                if (mwm_hints->decorations & MWM_DECOR_ALL)
                {
                    decor.border = YES;
                    decor.titlebar = YES;
                    decor.close_button = YES;
                    decor.minimize_button = YES;
                    decor.resizebar = YES;
                }

                // customized subset of decorations
                else 
                {
                    decor.border = NO;
                    decor.titlebar = NO;
                    decor.close_button = NO;
                    decor.minimize_button = NO;
                    decor.resizebar = NO;

                    // has border
                    if (mwm_hints->decorations & MWM_DECOR_BORDER)
                        decor.border = YES;
                    
                    // has resize bar
                    if (mwm_hints->decorations & MWM_DECOR_HANDLE)
                        decor.resizebar = YES;
                    
                    // has titlebar
                    if (mwm_hints->decorations & MWM_DECOR_TITLE)
                        decor.titlebar = YES;
                                        
                    // has miniaturize button
                    if (mwm_hints->decorations & MWM_DECOR_ICONIFY)
                        decor.minimize_button = YES;
                    
                    if (mwm_hints->decorations & MWM_DECOR_MENU)
                    {
                        /*XXX no menu for Interface yet, sorry */
                        // menu flag
                    }
                }
            }

            /******** not dealing with these at the moment *************

            if (mwm_hints->flags & MwmHintsFunctions)
            {
                if (mwm_hints->functions & MwmFuncAll)
                {
                    functions.resize = functions.move = functions.iconify =
                    functions.maximize = functions.close = True;
                }
                else 
                {
                    functions.resize = functions.move = functions.iconify =
                        functions.maximize = functions.close = False;
                    
                    if (mwm_hints->functions & MwmFuncResize)
                        functions.resize = True;
                    if (mwm_hints->functions & MwmFuncMove)
                        functions.move = True;
                    if (mwm_hints->functions & MwmFuncIconify)
                        functions.iconify = True;
                    if (mwm_hints->functions & MwmFuncMaximize)
                        functions.maximize = True;
                    if (mwm_hints->functions & MwmFuncClose)
                        functions.close = True;
                }
            }

            *************************************************************/
        }

    }

    return nil;
}

- initializeParentWindow
{
    NSPoint point;
    
    // initialize parent window
    [self setParent:[[IWMWindow alloc] initAsParentForClient:self]];

    // set titlebar into parent if present
    if (decor.titlebar)
        [self setTitlebar:[[IWMTitlebar alloc] initForClient:self]];

    // place main window into parent
    point.x = 0;
    point.y = [self titlebarHeight];
    [window setInto:parent point:point];

    // place resizebar into parent if present
    if (decor.resizebar)
        [self setResizebar:[[IWMResizebar alloc] initForClient:self]];
    
    // initialize the application icon
    icon = [[IWMIcon alloc] initForClient:self];

    [self configureNotify];
    [self redraw];

    return self;
}

@end