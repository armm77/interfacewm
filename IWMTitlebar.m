
/*
 * $Id: IWMTitlebar.m,v 1.15 2003/11/26 23:47:55 copal Exp $
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
#include "IWMTitlebar.h"
#include "IWMWindowManager.h"
#include "IWMClient.h"
#include "IWMScreen.h"
#include "IWMTheme.h"
#include "IWMCoreUtilities.h"
#include "IWMDebug.h"

#include <Foundation/NSString.h>

@implementation IWMTitlebar : IWMWindow

/*==========================================================================*
   DESIGNATED INITIALIZER
 *==========================================================================*/

- initForClient:(IWMClient *)aClient
{
    if (aClient)
    {
        IWMScreen *screen = [aClient screen];
        NSRect frame;

        frame.origin = [aClient origin];
        frame.origin.y -= [screen titlebarHeight];
        
        frame.size.width = [aClient width];
        frame.size.height = [screen titlebarHeight];

        // initialize titlebar
        [super initWithParent:[aClient parent] frame:frame];
        
        [self setClient:aClient];
        [self setBorderWidth:0];
        [self initializeButtons];
        
        // populate initial images from theme
        [self initializeTheme:[screen theme]];

        // set window type atom
        [self setWindowType:GlobalIWM->atoms.iwm_window_type_titlebar];
        
        return self;
    }

    return nil;
}

- (void)initializeButtons
{
    NSRect frame;

    frame.size.width = [self buttonHeight];
    frame.size.height = [self buttonHeight];

    if ([client hasCloseButton])
    {
        frame.origin = [self closeButtonCoordinates];
        
        closeButton = [[IWMWindow alloc] initWithParent:self frame:frame];
        [closeButton setWindowType:GlobalIWM->atoms.iwm_window_type_close_button];
    }
    
    if ([client hasMinimizeButton])
    {
        frame.origin = [self minimizeButtonCoordinates];
        
        minimizeButton = [[IWMWindow alloc] initWithParent:self frame:frame];
        [minimizeButton setWindowType:GlobalIWM->atoms.iwm_window_type_minimize_button];
    }
}

- (void)initializeTheme:(IWMTheme *)aTheme
{
    if (aTheme)
    {
        // inital background is focused
        [self setImage:[aTheme focusedTitlebarImage]]; /* XXX X ERRORS!!! */
        
        // set image & position of buttons if they are present in the titlebar
        if ([self closeButton] != NULL)
        {
            [closeButton setImage:[aTheme closeButtonImage]];
        }

        if ([self minimizeButton] != NULL)
        {
            [minimizeButton setImage:[aTheme minimizeButtonImage]];
        }
    }
}

- (void)redraw
{
    NSPoint point;
    NSSize size;
    IWMImage *image = nil;
    
    IWMTRACE;

    size.width = [client width];
    size.height = [self titlebarHeight];

    if ([client focused])
        image = [[[client screen] theme] focusedTitlebarImage];
    else
        image = [[[client screen] theme] unfocusedTitlebarImage];
    
    [self setSize:size];
    [self setImage:image];
    [self clear];

    // if resized, the close button will move
    point = [self closeButtonCoordinates];
    [closeButton setTopLeftPoint:point];

    // redraw the name of the client
    [self setTitle:[client name] isFocused:[client focused]];
}

- (void)hide
{
    if (closeButton)
        [closeButton hide];
    
    if (minimizeButton)
        [minimizeButton hide];
#if 0
    if (maximizeButton)
        [maximizeButton hide];
#endif
    [super hide];
}

- (void)unhide
{
    [super unhide];

    if (closeButton)
        [closeButton unhide];

    if (minimizeButton)
        [minimizeButton unhide];
#if 0
    if (maximizeButton)
        [maximizeButton unhide];
#endif
}

/*==========================================================================*
   SET METHODS
 *==========================================================================*/

- (void)setTitle:(NSString *)aTitle isFocused:(BOOL)focused
{
    IWMScreen   *screen = [self screen];
    XftFont     *xftfont = screen->xftfonts.primary;
    XftColor     xftcolor = focused ? screen->xftcolors.focused : screen->xftcolors.unfocused;
    GC           context;
    int          indent, x, y;
    int          buttonCount = 0;

    indent  = [self titlebarHeight] - [self buttonHeight];
    context = (focused ? [screen focusedGC] : [screen unfocusedGC]);

    if (closeButton)
        buttonCount++;
    if (minimizeButton)
        buttonCount++;
#if 0
    if (maximizeButton)
        buttonCount++;
#endif
    x = ([self buttonHeight] * buttonCount) + (indent * 4);
    y = ([screen primaryFont])->ascent + BORDER_WIDTH;
    
    
    //XDrawString(GlobalDisplay, xWindow, context, x, y,
      //      [aTitle cString], [aTitle cStringLength]);

    XftDrawStringUtf8(xftdraw, &xftcolor, xftfont, x, y, [aTitle cString],
            [aTitle cStringLength]);
}

/*==========================================================================*
   ACCESSOR METHODS
 *==========================================================================*/

- (int)titlebarHeight
{
    return ([[[self client] screen] titlebarHeight]);
}

- (int)buttonHeight
{
    return ([self titlebarHeight] - 6);
}

- (IWMWindow *)closeButton
{
    if ([[self client] hasCloseButton])
    {        
        return closeButton;
    }

    return nil;
}

- (IWMWindow *)minimizeButton
{
    if ([[self client] hasMinimizeButton])
    {        
        return minimizeButton;
    }

    return nil;
}

// far right
- (NSPoint)closeButtonCoordinates
{
    NSPoint point;
    int indent;

    indent = [self titlebarHeight] - [self buttonHeight];

    point.x = ([self width] - (indent /** 2*/ + [self buttonHeight]));
    point.y = 2;

    return point;
}

// far left
- (NSPoint)minimizeButtonCoordinates
{
    NSPoint point;
    int indent;

    indent = [self titlebarHeight] - [self buttonHeight];
    
    point.x = ((indent + [self buttonHeight]) * 1) - [self buttonHeight];
    point.y = 2;

    return point;
}

#if 0
// mid left
- (NSRect)maximizeButtonCoordinates
{
    NSRect rect;
    int indent;

    indent = [self titlebarHeight] - [self buttonHeight];

    rect.origin.x = ((indent + [self buttonHeight]) * 2) - [self buttonHeight];
    rect.origin.y = 2;

    return rect;
}
#endif

// inside left
#if 0
{
    NSRect rect;
    int indent;

    indent = [self titlebarHeight] - [self buttonHeight];

    rect.origin.x = ((indent + [self buttonHeight]) * 3) - [self buttonHeight];
    rect.origin.y = 2;

    return rect;
}
#endif

- (void)dealloc
{
    [closeButton release];
    [minimizeButton release];
    [super dealloc];
}

@end

