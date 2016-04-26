/** FILE: IWMOptionParser.h
 *
 * $Id: IWMOptionParser.h,v 1.1 2003/09/24 19:12:18 cbv Exp $
 *
 * <title>IWMOptionParser</title>
 * <date>September 13, 2003</date>
 *
 * This file is part of Interface WM.
 *
 * Copyright (C) 2002, 2003, Ian Mondragon
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
 *
 ***************************************************************************/

#ifndef _IWMOPTIONPARSER_H_
#define _IWMOPTIONPARSER_H_ 1
/***************************************************************************/

//
// Include
//

#include <Foundation/NSObject.h>

//
// Define
//

//
// Public
//

//
// Referenced Classes
//

//
// Interface
//

@interface IWMOptionParser : NSObject
{
  @private
    int			  _count;
    char * const	* _vector;
    const char		* _list;
    //
    int			  _option;
    const char		* _argument;
    //
    BOOL		  _error;
    int			  _index;
    BOOL		  _reset;
    //
    const char		* _progname;
}

//
// Factory Methods
//

//
// Instance Methods
//

- (id) initWithArgumentCount: (int) aCount
              argumentVector: (char * const *) aVector
                     options: (NSString *) aList;

- (int) parse;

//
// Accessor Methods
//

- (BOOL) error;
- (void) setError: (BOOL) anError;

- (int) index;
- (void) setIndex: (int) anIndex;

- (void) reset;

- (int) option;
- (const char *) argument;

@end

//
// Prototypes
//

extern char *IWMFetchRight(int wordnum, char *line, char *delim);

/***************************************************************************/
#endif
