
/*
 * $Id: IWMClient+Movement.m,v 1.1 2004/06/17 05:35:10 copal Exp $
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
 
@implementation IWMClient (MovementMethods)

- (void)move
{
	// i don't recall why this code is here, and Yen-Ju Chen submitted a
	// patch to remove it (effectively making this simply a call to the
	// -moveMouseUntilButtonRelease method.  makes sense, after recalling
	// the movement problems IWM was having, but the codebase is b0rken
	// right now, so i'm just commenting it out until i can compile...
	
//    NSPoint origin;
//    
//    origin.x = _outline.origin.x;
//    origin.y = _outline.origin.y;
//    
    [self moveWithMouseUntilButtonRelease];
//    [self setTopLeftPoint:origin];
//    [self configureNotify];
}

- (void)moveWithMouseUntilButtonRelease
{
    XEvent      event;
    int         old_x, old_y, tmp;
    BOOL        opaque = [GlobalIWM opaqueMovement];
    XPoint      position = [GlobalIWM mousePosition];

    if (![GlobalIWM grabPointerAndServer])
        return (void)0x0;
    
    // update outline frame
    _outline.origin = [self origin];
    _outline.size.width  = [self width];
    _outline.size.height = (state.shaded ? [self titlebarHeight]:
                                [self height]);

    // cache old x/y coordinates
    old_x = _outline.origin.x;
    old_y = _outline.origin.y;
    
    if (!opaque)
        [self drawOutline];
    
    for (;;)
    {
        XMaskEvent(GlobalDisplay, 
                IWM_EVENT_MASK_BUTTON|IWM_EVENT_MASK_KEY|IWM_EVENT_MASK_MOUSE,
                &event);

        switch (event.type) {
            case MotionNotify:
                [GlobalIWM cacheEventTime:&event];

                if (!opaque)
                    [self drawOutline];

                // make sure window doesn't go beyond screen of boundaries
                tmp = old_x + (event.xmotion.x - position.x);
                _outline.origin.x = (0 > tmp) ? 0 : tmp;

                tmp = old_y + (event.xmotion.y - position.y);
                _outline.origin.y = (0 > tmp) ? 0 : tmp;
                
                if (!opaque)
                    [self drawOutline];
                else
                    [self setTopLeftPoint:_outline.origin];
		
                break;

            case ButtonRelease:
                if (!opaque)
                    [self drawOutline];
                [self setFrame:_outline];
                [GlobalIWM ungrabPointerAndServer];
                return (void)0x0;

            case ButtonPress:
                XAllowEvents(GlobalDisplay, ReplayPointer, CurrentTime);
                break;

            default:
                break;
        }
    }
}

- (void)setTopLeftPoint:(NSPoint)aPoint
{
    IWMTRACE;
    
    XGrabServer(GlobalDisplay);
    {
      [parent setTopLeftPoint:aPoint];
      [self raise];
      [self configureNotify];
      [self redraw];
    }
    XUngrabServer(GlobalDisplay);
}

@end