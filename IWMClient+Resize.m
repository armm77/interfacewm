
/*
 * $Id: IWMClient+Resize.m,v 1.2 2004/06/17 05:38:57 copal Exp $
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

@implementation IWMClient (ResizeMethods)

- (void)setSize:(NSSize)aSize
{
    IWMTRACE;
    XGrabServer(GlobalDisplay);
    {
        NSSize windowSize;
        
        windowSize.height = (int)aSize.height - [self titlebarHeight] -
            [self resizebarHeight];
        windowSize.width = aSize.width;
        
        [parent setSize:aSize];
        [window setSize:windowSize];
        
        [self configureNotify];
    }
    XUngrabServer(GlobalDisplay);
}

- (void)resize:(BOOL)resizeWidth
{
    [self resizeWithMouseUntilButtonRelease:resizeWidth];
    [self setSize:_outline.size];
    [self setTopLeftPoint:_outline.origin];
}

- (void)resizeWithMouseUntilButtonRelease:(BOOL)resizeWidth
{
    XEvent      event;
    int         cached_right_x;
   
    if (![GlobalIWM grabPointerAndServer]) {
        fprintf(stderr, "-> Error grabbing pointer & server...\n");
        return (void)0x0;
    }
    
    _outline.size = [self size];
    _outline.origin = [self origin];
    
    cached_right_x = _outline.origin.x + _outline.size.width;
    
    [self drawOutline];

    for (;;)
    {
        int new_x;

        XMaskEvent(GlobalDisplay, IWM_EVENT_MASK_MOUSE, &event);

        switch (event.type)
        {
            case MotionNotify:
                new_x = resizeWidth ? event.xmotion.x : cached_right_x;
                [self drawOutline];
                [self resizeWithMouseMotionTo:new_x :event.xmotion.y];
                [self drawOutline];
                break;
                
            case ButtonRelease:
                [self drawOutline];
                [GlobalIWM ungrabPointerAndServer];
                return (void)0x0;
                
            default:
                return (void)0x0;
        }
    }
}

// XXX THIS NEEDS SERIOUS FIXING
- (void)resizeWithMouseMotionTo:(int)xValue :(int)yValue
{
    XSizeHints  *hints = [window wmNormalHints];
    int          old_x, old_y;
    int          base_x, base_y;
    int          borderWidth = [self borderWidth];
    
    old_x = _outline.origin.x;
    old_y = _outline.origin.y;

    _outline.size.width  = abs(_outline.origin.x - xValue) - borderWidth;
    _outline.size.height = abs(_outline.origin.y - yValue) - borderWidth;

    if (hints->flags & PResizeInc)
    {
        base_x = (hints->flags & PBaseSize) ? hints->base_width :
                    ((hints->flags & PMinSize) ? hints->min_width : 0);
        
        base_y = (hints->flags & PBaseSize) ? hints->base_height :
                    ((hints->flags & PMinSize) ? hints->min_height : 0);

        _outline.size.width -= ((int)_outline.size.width - base_x) % hints->width_inc;
        _outline.size.height -= ((int)_outline.size.height - base_y) % hints->height_inc;
    }

    if (hints->flags & PMinSize)
    {
        if (_outline.size.width < hints->min_width)
            _outline.size.width = hints->min_width;
        
        if (_outline.size.height < hints->min_height)
            _outline.size.height = hints->min_height;
    }
    
    if (hints->flags & PMaxSize)
    {
        if (_outline.size.width > hints->max_width)
            _outline.size.width = hints->max_width;
        
        if (_outline.size.height > hints->max_height)
            _outline.size.height = hints->max_height;
    }

    _outline.origin.x = (old_x <= xValue) ? old_x : old_x - _outline.size.width;
    _outline.origin.y = (old_y <= yValue) ? old_y : old_y - _outline.size.height;

    return (void)0x0;
}

// XXX - no true minimization right now...
- (void)minimize
{
    IWMTRACE;
    
    if (!state.shaded)
        [self shade];
    else
        [self unshade];
}

// XXX - no true minimization right now...
- (void)unminimize
{
    [self unshade];
}

- (void)maximize
{
    IWMTRACE;

    [self maximizeHorizontally];
    [self maximizeVertically];

    // XXX - set _NET_WM_STATE properties
	[self update];
}

- (void)maximizeHorizontally
{
    IWMTRACE;
    
    if (!state.maximized_horz)// && decor.maximize_button)
    {
        NSRect frame;
        
        _cached_size.size.width = [self width];
        
        frame.size.width = iwm_display_width([self screen]) - [self borderWidth];
        frame.size.height = [self height];
        
        frame.origin = [self origin];
        frame.origin.x = 0;
        
        [self setFrame:frame];
        
        state.maximized_horz = YES;

        // XXX - set _NET_WM_STATE_MAXIMIZED_HORZ property
        [self update];
    }
}

- (void)maximizeVertically
{
    IWMTRACE;
    
    if (!state.maximized_vert) // && decor.maximize_button)
    {
        NSRect frame;
        
        _cached_size.size.height = [self height];

        frame.size.width = [self width];
        frame.size.height = iwm_display_height([self screen]) - [self borderWidth];
        frame.origin.x = ([parent origin]).x;
        frame.origin.y = 0;

        [self setFrame:frame];

        state.maximized_vert = YES;

        // XXX - set _NET_WM_STATE_MAXIMIZED_VERT property
        [self update];
    }
}

- (void)unmaximize
{
    IWMTRACE;
    
    if (state.maximized_horz || state.maximized_vert)
    {
        NSRect frame;
        
        frame.size.width = (state.maximized_horz ? _cached_size.size.width :
                [self width]);
        frame.size.height = (state.maximized_vert ? _cached_size.size.height :
                [self height]);
                
        frame.origin = _cached_size.origin;

        [self setFrame:frame];

        state.maximized_horz = NO;
        state.maximized_vert = NO;

        // XXX - unset _NET_WM_STATE_MAXIMIZED_{VERT,HORZ} properties
        [self update];
    }
}


- (void)setFrame:(NSRect)aRect
{
    int adjustment, windowHeight;
    NSSize windowSize;
    
    IWMTRACE;

    [self verifyFrame:aRect];
    
    XGrabServer(GlobalDisplay);
    
    adjustment = [self borderWidth] * 2;
    windowHeight = (int)aRect.size.height - [self titlebarHeight] -
        [self resizebarHeight] - adjustment;
    
    windowSize.width = (int)aRect.size.width - adjustment;
    windowSize.height = windowHeight;
    
    [parent setSize:aRect.size];
    [window setSize:windowSize];
    [parent setTopLeftPoint:aRect.origin];
    
    [self redraw];

    [self configureNotify];
    
    XUngrabServer(GlobalDisplay);
}

- (void)verifyFrame:(NSRect)aFrame
{
    int xMax = DisplayWidth(GlobalDisplay, _screenNumber);
    int yMax = DisplayHeight(GlobalDisplay, _screenNumber);

    if (minimumSize.width && (minimumSize.width > aFrame.size.width)) {
        IWMDebug(@"Correcting frame width...", nil);
        aFrame.size.width = minimumSize.width;
    }

    if (minimumSize.height && (minimumSize.height > aFrame.size.height)) {
        IWMDebug(@"Correcting frame height...", nil);
        aFrame.size.height = minimumSize.height;
    }

    if (aFrame.origin.y < 0) {
        IWMDebug(@"Correcting Y coordinate...", nil);
        aFrame.origin.y = 0;
    }

    if (aFrame.origin.y >= yMax) {
        IWMDebug(@"Correcting Y coordinate...", nil);
        aFrame.origin.y = yMax-10; //XXX 10 pixel leeway on bottom...?
    }
    
    if (aFrame.origin.x < 0) {
        IWMDebug(@"Correcting X coordinate...", nil);
        aFrame.origin.x = 0;
    }

    if (aFrame.origin.x >= xMax) {
        IWMDebug(@"Correcting X coordinate...", nil);
        aFrame.origin.x = xMax-10; //XXX 10 pixel leeway (change to mod screen)
    }
}

@end
