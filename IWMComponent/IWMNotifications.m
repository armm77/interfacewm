
/*
 * $Id: IWMNotifications.m,v 1.1 2003/08/19 02:01:36 copal Exp $
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

#include "IWMNotifications.h"

// new client
NSString *IWMClientIsInitializingNotification = @"IWMClientIsInitializingNotification";
NSString *IWMClientDidInitializeNotification = @"IWMClientDidInitializeNotification";

// change name
NSString *IWMClientChangeNameNotification = @"IWMClientChangeNameNotification";

// focus
NSString *IWMClientFocusNotification = @"IWMClientFocusNotification";
NSString *IWMClientUnfocusNotification = @"IWMClientUnfocusNotification";

// resize
NSString *IWMClientResizeNotification = @"IWMClientResizeNotification";

// move
NSString *IWMClientMoveNotification = @"IWMClientMoveNotification";

// move & resize
NSString *IWMClientMoveResizeNotification = @"IWMClientMoveResizeNotification";

// change screen
NSString *IWMClientChangeScreenNotification = @"IWMClientChangeScreenNotification";
NSString *IWMClientDidChangeScreenNotification = @"IWMClientDidChangeScreenNotification";

// close
NSString *IWMClientCloseNotification = @"IWMClientCloseNotification";
NSString *IWMClientDidCloseNotification = @"IWMClientDidCloseNotification";

// minimize
NSString *IWMClientMinimizeNotification = @"IWMClientMinimizeNotification";
NSString *IWMClientDidMinimizeNotification = @"IWMClientDidMinimizeNotification";

NSString *IWMClientUnminimizeNotification = @"IWMClientUnminimizeNotification";
NSString *IWMClientDidUnminimizeNotification = @"IWMClientDidUnminimizeNotification";

// maximize
NSString *IWMClientMaximizeNotification = @"IWMClientMaximizeNotification";
NSString *IWMClientDidMaximizeNotification = @"IWMClientDidMaximizeNotification";

NSString *IWMClientUnmaximizeNotification = @"IWMClientUnmaximizeNotification";
NSString *IWMClientDidUnmaximizeNotification = @"IWMClientDidUnmaximizeNotification";

// hide
NSString *IWMClientHideNotification = @"IWMClientHideNotification";
NSString *IWMClientDidHideNotification = @"IWMClientDidHideNotification";

NSString *IWMClientUnhideNotification = @"IWMClientUnhideNotification";
NSString *IWMClientDidUnhideNotification = @"IWMClientDidUnhideNotification";

// shade
NSString *IWMClientShadeNotification = @"IWMClientShadeNotification";
NSString *IWMClientDidShadeNotification = @"IWMClientDidShadeNotification";

NSString *IWMClientUnshadeNotification = @"IWMClientUnshadeNotification";
NSString *IWMClientDidUnshadeNotification = @"IWMClientDidUnshadeNotification";

