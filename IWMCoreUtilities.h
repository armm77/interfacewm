
/*
 * $Id: IWMCoreUtilities.h,v 1.12 2003/11/05 05:19:55 copal Exp $
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

#ifndef _IWMCOREUTILITIES_H_
#define _IWMCOREUTILITIES_H_    1

#include "InterfaceWM.h"

@class IWMWindowManager;
@class IWMWindow;
@class IWMScreen;
@class IWMAtom;
@class NSString;

#define IWM_MALLOC(bytes)       _iwm_malloc((bytes), __FILE__, __LINE__)
#define IWM_FREE(pointer)       _iwm_free((pointer), __FILE__, __LINE__)

void *_iwm_malloc(long nbytes, const char *filename, int line);
void _iwm_free(void *pointer, const char *filename, int line);

/*!
 * @method iwm_mouse_position()
 * @abstract Returns an XPoint structure containing the current mouse 
 * coordinates
 * @param windowManager Pointer to the IWMWindowManager object
 * @param target Optional parameter for obtaining coordinates relative to a
 * particular IWMWindow
 */
XPoint iwm_mouse_position(IWMWindow *target);

/*!
 * @method iwm_populate_env_display()
 * @abstract Populates the $DISPLAY environment variable
 */
void iwm_populate_env_display(Display *display);

/*
 * open display (calls iwm_populate_env_display() if successfull)
 */
Display *iwm_display_open(NSString *displayName);

/*
 * close display
 */
void iwm_display_close(Display *display);

/*
 * grab pointer and server
 */
BOOL iwm_grab_pointer_and_server(void);
void iwm_ungrab_pointer_and_server(void);

/*
 * verify screen number's validity
 */
BOOL iwm_verify_screen(int screenNumber);

/*
 * display dimentions
 */
int iwm_display_width(IWMScreen *screen);
int iwm_display_height(IWMScreen *screen);

/*
 * create an ClientMessage XEvent to send to a window
 */
void iwm_send_message_to_window(IWMWindow *window, Atom atom, long data);

int iwm_mapped_not_override(IWMWindowManager *windowManager, Window window);

/*
 * safe free of GC
 */
void iwm_free_gc(Display *display, GC gc);

void iwm_draw_circle(IWMWindow *window, int x, int y, int diameter);

/*!
 * @method iwm_default_value()
 * @abstract Utility function for obtaining a value from the IWM defaults
 * @param key The desired key value
 */
id iwm_default_value(NSString *key);

/*!
 * @method iwm_atom()
 * @abstract Utility function to create an atom
 * @param name Name of the atom
 */
Atom iwm_atom(const char *name);

unsigned char *iwm_window_property(Window window, Atom property, Atom type, 
        int *count);

// core wrapper for XChangeProperty()
void iwm_change_window_property(Window window, Atom property, Atom type,
        int format, unsigned char *data, int nelements, int mode);

// obtain the _IWM_WINDOW_TYPE property of a window
Atom iwm_window_type(Window window);

#endif /* _IWMCOREUTILITIES_H_ */

