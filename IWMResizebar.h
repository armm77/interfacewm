
/*
 * $Id: IWMResizebar.h,v 1.3 2003/10/29 04:08:03 copal Exp $
 *
 * This file is part of Interface WM.
 *
 * Copyright (C) 2003, Ian Mondragon
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

#ifndef _IWMRESIZEBAR_H_
#define _IWMRESIZEBAR_H_   1

#include "IWMWindow.h"

@class IWMClient;

/*!
 * @class IWMResizebar
 * Representation of a client's resizebar, including grips
 */
@interface IWMResizebar : IWMWindow
{
    IWMWindow *leftGrip;
    IWMWindow *rightGrip;
}

/*
 * @method initWithClient:
 * @discussion Designated initializer
 * @param aClient The IWMClient object that will contain the resizebar
 */
- initForClient:(IWMClient *)aClient;

- (void)redraw;
- (void)hide;
- (void)unhide;

- (IWMWindow *)leftGrip;
- (IWMWindow *)rightGrip;

- (void)dealloc;

@end

#endif /* _IWMRESIZEBAR_H_ */

