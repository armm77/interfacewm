/** FILE: IWMOptionParser.m
 *
 * $Id: IWMOptionParser.m,v 1.2 2003/10/04 01:41:55 cbv Exp $
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

//
// Include
//

#include "InterfaceWM.h"

#define BOOL XWINDOWSBOOL
#include "IWMOptionParser.h"
#include "IWMDebug.h"
#include "IWMCoreUtilities.h"
#undef BOOL

#include <Foundation/NSString.h>

//
// Define
//

#define BAD_CHARACTER	'?'
#define BAD_ARGUMENT	':'
#define EMPTY		""

//
// Typedef
//

//
// Public
//

//
// Private
//

static const char *DELIM = ".,;:!\"]/()? \t\n\f\r\0";

//
// Private Interface
//

@interface IWMOptionParser (Private)

@end

//
// Prototype
//

static char *IWMFetch(int wordnum, char *line, char *delim);
static char *IWMReverse(char *line);
static char *IWMSubString(char *str, unsigned start, unsigned len);

/***************************************************************************
**
** Implementation
**
*/

@implementation IWMOptionParser 

/***************************************************************************
**
** Factory Methods
**
*/

/***************************************************************************
**
** Instance Methods
**
*/

/**
 * Creates and returns a new option parser. aCount is the number of
 * arguments, aVector holds the command line arguments and aList specifies
 * a list of known option characters. By default, -index is set to 1, and
 * -error is set to YES.
 */

- (id) initWithArgumentCount: (int) aCount
              argumentVector: (char * const *) aVector
                     options: (NSString *) aList
{
  IWMTRACE;
  
  [aList retain];
  
  if( (self = [super init]) )
  {
    char
      *v = IWM_MALLOC(strlen(aVector[0]));
    
    strcpy(v, aVector[0]);
    _progname = IWMFetchRight(1, v, NULL);
    
    IWM_FREE(v);
    
    _count = aCount;
    _vector = aVector;
    
    _list = IWM_MALLOC([aList length]);
    _list = [aList cString];
    
    _error = YES;
    _index = 1;
    
    _reset = NO;
    
    return self;
  }

  //
  // That's it
  //

  return nil;
}

/**
 * Incrementally parses the command line arguments and returns the next
 * known option character. An option character is known if it has been
 * specified in the options list when the parser was initialized.
 * When all options have been processed, -parse returns -1.
 */

- (int) parse
{
  IWMTRACE;
  
  {
    static const char
      *loc = EMPTY;
    char
      *idx;
    
    if( _reset || ! *loc )
    {
      _reset = NO;
      
      if( (_index >= _count) || *(loc = _vector[_index]) != '-' )
      {
        loc = EMPTY;
        
        return -1;
      }
      
      if( loc[1] && (*++loc == '-') )
      {
        ++_index;
        loc = EMPTY;
        
        return -1;
      }
    }
    
    if( (_option = *loc++) == ':' || ! (idx = strchr(_list, _option)))
    {
      if( '-' == _option )
        return -1;
      
      if( ! *loc )
        ++_index;
      
      if( _error && (':' != *_list) && (BAD_CHARACTER != _option) )
        fprintf(stderr, "%s: illegal option -- %c\n", _progname, _option);
      
      return BAD_CHARACTER;
    }
    
    if( *++idx != ':' )
    {
      _argument = NULL;
      
      if( ! *loc )
        ++_index;
    }
    else
    {
      if( *loc )
        _argument = loc;
      else if( _count <= ++_index )
      {
        loc = EMPTY;
        
        if( ':' == *_list )
          return BAD_ARGUMENT;
        
        if( _error )
          fprintf(stderr, "%s: option requires an argument -- %c\n", _progname, _option);
        
        return BAD_CHARACTER;
      }
      else
        _argument = _vector[_index];
      
      loc = EMPTY;
      ++_index;
    }
  }

  //
  // That's it
  //

  return _option;
}

/***************************************************************************
**
** Accessor Methods
**
*/

/**
 * Returns YES if error messages will be printed, otherwise returns NO.
 * By default, error messages are printed. Use -setError: before
 * -parse is called to turn it off.
 */

- (BOOL) error
{
  IWMTRACE;
  
  //
  // That's it
  //

  return _error;
}

/**
 * If anError is set to NO, error messages will not be printed.
 *
 *
 */

- (void) setError: (BOOL) anError
{
  IWMTRACE;
  
  {
    _error = anError;
  }
  
  //
  // That's it
  //

  return;
}

/**
 * Returns the index of the next argument for a subsequent call to -parse.
 *
 *
 */

- (int) index
{
  IWMTRACE;
  
  //
  // That's it
  //

  return _index;
}

/**
 * -setIndex: can be used to set the index to another value before a set of
 * calls to -parse in order to skip over argument entries.
 *
 */

- (void) setIndex: (int) anIndex
{
  IWMTRACE;
  
  {
    _index = anIndex;
  }
  
  //
  // That's it
  //

  return;
}

/**
 * In order to use -parse to evaluate multiple sets of arguments, or to
 * evaluate a single set of arguments multiple times, -reset must be called
 * before the second and each additional set of calls to -parse. The index
 * is set back to 1.
 * -setIndex: can be used to reinitialize the index with a different value.
 */

- (void) reset
{
  IWMTRACE;
  
  {
    _reset = YES;
    _index = 1;
  }
  
  //
  // That's it
  //

  return;
}

/**
 * Returns the last known option character returned by -parse.
 *
 *
 */

- (int) option
{
  IWMTRACE;
  
  //
  // That's it
  //

  return _option;
}

/**
 * Returns the option argument, if appropriate, otherwise returns NULL.
 *
 *
 */

- (const char *) argument
{
  IWMTRACE;
  
  //
  // That's it
  //

  return _argument;
}

/***************************************************************************
**
** Protocol Methods
**
*/

/***************************************************************************
**
** Override Methods
**
*/

/**
 *
 *
 *
 */

- (id) init
{
  IWMTRACE;
  
  {
    [self notImplemented: _cmd];
  }

  //
  // That's it
  //

  return nil;
}

/**
 *
 *
 *
 */

- (void) dealloc
{
  IWMTRACE;
  
  {
    /* Barfs on Linux
    IWM_FREE((char *) _argument);
    IWM_FREE((char *) _progname);
    IWM_FREE((char *) _vector);
    IWM_FREE((char *) _list);
    */
  }
  [super dealloc];

  //
  // That's it
  //

  return;
}

/***************************************************************************
**
** Private Methods
**
*/

@end

/***************************************************************************
**
** Functions
**
*/

/**
 *
 *
 *
 */

/* public */
char *IWMFetchRight(int wordnum, char *line, char *delim)
{
  char	*rline = IWMReverse(line),
  	*temp  = IWMFetch(wordnum, rline, delim),
  	*rtemp = IWMReverse(temp);
  
  IWM_FREE(rline);
  IWM_FREE(temp);
  
  return rtemp;
}

/**
 *
 *
 *
 */

static
char *IWMFetch(int wordnum, char *line, char *delim)
{
  unsigned	linelen = strlen(line),
  		wlen    = 0,
  		wstart  = 0,
  		linepos = 0;
  
  if( ! delim )
  {
    delim = IWM_MALLOC((unsigned) *DELIM);
    strcpy(delim, DELIM);
  }
  
  while( wordnum && (linepos < linelen) )
  {
    wstart = strspn(line + linepos, delim) + linepos;
    wlen = strcspn(line + wstart, delim);
    
    linepos = wstart + wlen;
    
    wordnum--;
  }
  
  return ( wordnum || !wlen ? ((char *) 0)
                              : IWMSubString(line, wstart, wlen) );
}

/**
 *
 *
 *
 */

static
char *IWMReverse(char *line)
{
  char	*temp;
  
  if( (char *) 0 == line )
    temp = (char *) 0;
  else
  {
    unsigned	slen = strlen(line),
    		i1 = slen - 1,
    		i2 = 0;
    
    temp = IWM_MALLOC(slen + 1);
    
    for( ; i2 < slen; i2++)
      temp[i2] = line[i1--];
    
    temp[i2] = '\0';
  }
  
  return temp;
}

/**
 *
 *
 *
 */

static
char *IWMSubString(char *str, unsigned start, unsigned len)
{
  char		*temp;
  unsigned	 slen = strlen(str);
  
  if( (start > slen) || (0 > start) )
    temp = (char *) 0;
  else
  {
    unsigned	i = 0;
    
    if( (start + len) > slen )
      len = slen - start;
    
    temp = IWM_MALLOC(len + 1);
    
    for( ; i < len; i++ )
      temp[i] = str[start + i];
    
    temp[i] = '\0';
  }
  
  return temp;
}

/*
** End of File.
**
****************************************************************************/
