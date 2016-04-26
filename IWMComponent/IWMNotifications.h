
/*
 * $Id: IWMNotifications.h,v 1.1 2003/08/19 02:01:36 copal Exp $
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

#ifndef _IWMNOTIFICATIONS_H_
#define _IWMNOTIFICATIONS_H_    1

#include <Foundation/NSString.h>

/*==========================================================================*
   NOTIFICATIONS GENERATED ONLY BY WINDOW MANAGER
 *==========================================================================*/

// new client
extern NSString *IWMClientIsInitializingNotification;
extern NSString *IWMClientDidInitializeNotification;

/*==========================================================================*
   NOTIFICATIONS RECIEVABLE BY WINDOW MANAGER
 *==========================================================================*/

// change name
extern NSString *IWMClientChangeNameNotification;

// focus
extern NSString *IWMClientFocusNotification;
extern NSString *IWMClientUnfocusNotification;

// resize
extern NSString *IWMClientResizeNotification;

// move
extern NSString *IWMClientMoveNotification;

// move & resize
extern NSString *IWMClientMoveResizeNotification;

// change screen
extern NSString *IWMClientChangeScreenNotification;
extern NSString *IWMClientDidChangeScreenNotification;

// close
extern NSString *IWMClientCloseNotification;
extern NSString *IWMClientDidCloseNotification;

// minimize
extern NSString *IWMClientMinimizeNotification;
extern NSString *IWMClientDidMinimizeNotification;

extern NSString *IWMClientUnminimizeNotification;
extern NSString *IWMClientDidUnminimizeNotification;

// maximize
extern NSString *IWMClientMaximizeNotification;
extern NSString *IWMClientDidMaximizeNotification;

extern NSString *IWMClientUnmaximizeNotification;
extern NSString *IWMClientDidUnmaximizeNotification;

// hide
extern NSString *IWMClientHideNotification;
extern NSString *IWMClientDidHideNotification;

extern NSString *IWMClientUnhideNotification;
extern NSString *IWMClientDidUnhideNotification;

// shade
extern NSString *IWMClientShadeNotification;
extern NSString *IWMClientDidShadeNotification;

extern NSString *IWMClientUnshadeNotification;
extern NSString *IWMClientDidUnshadeNotification;

#endif /* _IWMNOTIFICATIONS_H_ */

