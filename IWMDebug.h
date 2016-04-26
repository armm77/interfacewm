
/*
 * $Id: IWMDebug.h,v 1.5 2003/11/18 03:40:12 copal Exp $
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

#ifndef _IWMDEBUG_H_
#define _IWMDEBUG_H_    1

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDebug.h>


/*!
 * @method IS_CLASS(anObject)
 * @abstract Returns YES if anObject exists and is a class object, not an
 *           instance.
 */
#define IS_CLASS(anObject) ( (anObject) && object_is_class((anObject)) )

enum {
  IWM_Fatal       = 1,
  IWM_Error       = 2,
  IWM_Warn        = 3,
  IWM_Note        = 4,
  IWM_Debug       = 5,
  IWM_Trace       = 6
};

#ifdef DEBUG
extern void IWMLog(int level, NSString *format, ...);
#  define IWMFatal(format, args...)	IWMLog(IWM_Fatal, format, args)
#  define IWMError(format, args...)	IWMLog(IWM_Error, format, args)
#  define IWMWarn(format, args...)	IWMLog(IWM_Warn, format, args)
#  define IWMNote(format, args...)	IWMLog(IWM_Note, format, args)
#  define IWMDebug(format, args...)	IWMLog(IWM_Debug, format, args)
#  define IWMTRACE							\
	do {								\
		if( GSDebugSet(@"all") || GSDebugSet(@"trace") )	\
		  IWMLog(IWM_Trace, @"%s", __PRETTY_FUNCTION__);	\
	} while( 0 );
#else
#  define IWMLog(level, format, args...)	/* nothing here */
#  define IWMFatal(format, args...)		/* nothing here */
#  define IWMError(format, args...)		/* nothing here */
#  define IWMWarn(format, args...)		/* nothing here */
#  define IWMNote(format, args...)		/* nothing here */
#  define IWMDebug(format, args...)		/* nothing here */
#  define IWMTRACE				/* nothing here */
#endif /* DEBUG */

#endif /* _IWMDEBUG_H_ */

