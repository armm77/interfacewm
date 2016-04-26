
/*
 * $Id: InterfaceWM.h,v 1.14 2003/12/14 06:15:35 copal Exp $
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

#ifndef _INTERFACEWM_H_
#define _INTERFACEWM_H_ 1

/*==========================================================================*
   Xlib includes
 *==========================================================================*/

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/Xproto.h>
#include <X11/keysym.h>
#include <X11/cursorfont.h>
#include <X11/Xresource.h>

#include <ft2build.h>
#include FT_FREETYPE_H
#include <X11/Xft/Xft.h>

#ifdef SHAPE
#include <X11/extensions/shape.h>
#endif

/*==========================================================================*
   Other C includes
 *==========================================================================*/

#include <signal.h>

/*==========================================================================* 
   Motif details (used to determine window decorations)
 *==========================================================================*/

#define MWM_HINTS_ELEMENTS      3

#define MWM_HINTS_FUNCTIONS     (1l << 0)
#define MWM_HINTS_DECORATIONS   (1l << 1)

#define MWM_FUNC_ALL            (1l << 0)
#define MWM_FUNC_RESIZE         (1l << 1)
#define MWM_FUNC_MOVE           (1l << 2)
#define MWM_FUNC_ICONIFY        (1l << 3)
#define MWM_FUNC_MAXIMIZE       (1l << 4)
#define MWM_FUNC_CLOSE          (1l << 5)

#define MWM_DECOR_ALL           (1l << 0)
#define MWM_DECOR_BORDER        (1l << 1)
#define MWM_DECOR_HANDLE        (1l << 2)
#define MWM_DECOR_TITLE         (1l << 3)
#define MWM_DECOR_MENU          (1l << 4)
#define MWM_DECOR_ICONIFY       (1l << 5)
#define MWM_DECOR_MAXIMIZE      (1l << 6)

/*
 * the motif 2.0 structure contains 5 elements, but we only need 3
 */
typedef struct {
    unsigned long flags;
    unsigned long functions;
    unsigned long decorations;
} MWMHints;

/*==========================================================================*
   GNUstep details
 *==========================================================================*/

#define GSWindowStyleAttr 	        (1<<0)
#define GSWindowLevelAttr 	        (1<<1)
#define GSMiniaturizePixmapAttr	        (1<<3)
#define GSClosePixmapAttr	        (1<<4)
#define GSMiniaturizeMaskAttr   	(1<<5)
#define GSCloseMaskAttr		        (1<<6)
#define GSExtraFlagsAttr        	(1<<7)

/* extra flags */
#define GSDocumentEditedFlag	        (1<<0)
#define GSNoApplicationIconFlag	        (1<<5)

/*==========================================================================*
   defaults database strings
   XXX - replace this horribleness with extern NSStrings
 *==========================================================================*/

#define INTERFACE_DEFAULTS              @"InterfaceWM"
#define INTERFACE_DIR                   @"GNUstep/Library/InterfaceWM"
#define INTERFACE_THEME_DIR             @"GNUstep/Library/InterfaceWM/Themes"
#define INTERFACE_IMAGE_DIR             @"GNUstep/Library/InterfaceWM/Images"
#define INTERFACE_COMPONENT_DIR         @"GNUstep/Library/InterfaceWM/Components"
#define THEME_DIRECTORIES               @"ThemeDirectories"
#define IMAGE_DIRECTORIES               @"ImageDirectories"
#define COMPONENT_DIRECTORIES           @"ComponentDirectories"

#define BUTTON_DEFAULTS                 @"ButtonDefaults"
#define BUTTON1_DEFAULT                 @"Button1"
#define BUTTON2_DEFAULT                 @"Button2"
#define BUTTON3_DEFAULT                 @"Button3"

#define FONT_DEFAULTS                   @"FontDefaults"
#define PRIMARY_FONT_DEFAULT            @"PrimaryFont"
#define SECONDARY_FONT_DEFAULT          @"SecondaryFont"
#define TERTIARY_FONT_DEFAULT           @"TertiaryFont"

#define COLOR_DEFAULTS                  @"ColorDefaults"
#define BACKGROUND_COLOR_DEFAULT        @"BackgroundColor"
#define FOREGROUND_COLOR_DEFAULT        @"ForegroundColor"
#define BORDER_COLOR_DEFAULT            @"BorderColor"

#define RESIZEBAR_HEIGHT_DEFAULT        @"ResizebarHeight"

#define OPAQUE_MOVEMENT_DEFAULT         @"OpaqueMovement"
#define THEME_NAME_DEFAULT              @"ThemeName"
#define FOCUS_TYPE_DEFAULT              @"FocusType"

#define ICON_WIDTH_DEFAULT              @"IconWidth"
#define ICON_HEIGHT_DEFAULT             @"IconHeight"

#define COMPONENTS_DEFAULT              @"Components"

/*
 * default values for fonts, colors, etc.
 */

#define _BLACK                          @"#000000"
#define _WHITE                          @"#ffffff"
#define _GRAY                           @"#c0c0c0"
#define _GREY                           _GRAY
#define _BLUE                           @"#0000ff"
#define _YELLOW                         @"#ffff00"
#define _GREEN                          @"#008000"
#define _TAN                            @"#cccc99"

#define DEFAULT_FONT_PRIMARY            @"lucidasanstypewriter-12"
#define DEFAULT_FONT_SECONDARY          @"lucidasanstypewriter-10"
#define DEFAULT_FONT_TERTIARY           @"lucidasanstypewriter-10"

#define DEFAULT_COLOR_FOCUSED           _WHITE
#define DEFAULT_COLOR_UNFOCUSED         _WHITE
#define DEFAULT_COLOR_BACKGROUND        @"#d0d0d0"
#define DEFAULT_COLOR_BORDER_1          _BLACK

#define DEFAULT_COLOR_CLOSE_BUTTON      _BLACK
#define DEFAULT_COLOR_MINIMIZE_BUTTON   @"#808080"
#define DEFAULT_COLOR_MAXIMIZE_BUTTON   @"#c0c0c0"

/*
 * default values for images
 */

#define DEFAULT_IMAGE_BACKGROUND        @"Background"
#define DEFAULT_IMAGE_FOCUSED           @"FocusedTitlebar"
#define DEFAULT_IMAGE_UNFOCUSED         @"UnfocusedTitlebar"
#define DEFAULT_IMAGE_CLOSE             @"CloseButton"
#define DEFAULT_IMAGE_MINIMIZE          @"MinimizeButton"
#define DEFAULT_IMAGE_MAXIMIZE          @"MaximizeButton"
#define DEFAULT_IMAGE_RESIZE            @"Resizebar"
#define DEFAULT_IMAGE_ICON              @"Icon"

#define DEFAULT_BUTTON_1                @"xterm -ls -sb"
#define DEFAULT_BUTTON_2                @"xterm -e xprop"

#define BORDER_WIDTH                    1

#ifdef NEW_HANDLER

#define DOUBLE_CLICK_DEFAULT		@"DoubleClick"
#define DEFAULT_DOUBLE_CLICK		250

#endif

/*==========================================================================* 
   defines for IWMWindow
 *==========================================================================*/

/*--- event masks ---*/

#define IWM_EVENT_MASK_SUBSTRUCTURE     SubstructureRedirectMask |\
                                        SubstructureNotifyMask

#define IWM_EVENT_MASK_BUTTON           ButtonPressMask|ButtonReleaseMask |\
                                        ButtonMotionMask

#define IWM_EVENT_MASK_KEY              KeyPressMask|KeyReleaseMask

#define IWM_EVENT_MASK_WINDOW_ENTRY     EnterWindowMask|LeaveWindowMask

#define IWM_EVENT_MASK_EXPOSURE         ExposureMask

/* root window */
#define IWM_EVENT_MASK_ROOT_WINDOW      IWM_EVENT_MASK_SUBSTRUCTURE |\
                                        IWM_EVENT_MASK_BUTTON |\
                                        ColormapChangeMask |\
                                        PropertyChangeMask

/* parent window */
#define IWM_EVENT_MASK_PARENT           IWM_EVENT_MASK_SUBSTRUCTURE |\
                                        IWM_EVENT_MASK_BUTTON |\
                                        IWM_EVENT_MASK_WINDOW_ENTRY|\
                                        IWM_EVENT_MASK_EXPOSURE|\
                                        PropertyChangeMask

/* normal window */
#define IWM_EVENT_MASK_WINDOW           IWM_EVENT_MASK_KEY|\
                                        IWM_EVENT_MASK_BUTTON|\
                                        IWM_EVENT_MASK_WINDOW_ENTRY|\
                                        IWM_EVENT_MASK_EXPOSURE

/* client window */
#define IWM_EVENT_MASK_CLIENT           IWM_EVENT_MASK_WINDOW_ENTRY|\
                                        StructureNotifyMask|\
                                        PropertyChangeMask|ColormapChangeMask|\
                                        FocusChangeMask|VisibilityChangeMask
                                        
/* top level window (icon, menu, dock, etc.) */
#define IWM_EVENT_MASK_TOP_LEVEL        IWM_EVENT_MASK_BUTTON|\
                                        IWM_EVENT_MASK_WINDOW_ENTRY|\
                                        IWM_EVENT_MASK_EXPOSURE|\
                                        SubstructureRedirectMask

#if 0
/* normal window */
#define IWM_EVENT_MASK_WINDOW           IWM_EVENT_MASK_BUTTON |\
                                        IWM_EVENT_MASK_KEY |\
                                        ExposureMask | EnterWindowMask |\
                                        LeaveWindowMask|PropertyChangeMask
#endif

#define IWM_EVENT_MASK_MOUSE            IWM_EVENT_MASK_BUTTON |\
                                        PointerMotionMask

/*--- window masks ---*/

#define IWM_WINDOW_MASK_PARENT          CWBackPixel|CWBorderPixel|\
                                        CWEventMask|CWOverrideRedirect

#define IWM_WINDOW_MASK                 CWBackPixmap|CWBackPixel|CWBorderPixel|\
                                        CWCursor|CWEventMask

/*==========================================================================*
   defines for IWMScreen
 *==========================================================================*/

#define IWMSCREEN_EVENT_MASK (LeaveWindowMask | EnterWindowMask |\
                              PropertyChangeMask | SubstructureNotifyMask |\
                              PointerMotionMask | SubstructureRedirectMask |\
                              ButtonPressMask | ButtonReleaseMask |\
                              KeyPressMask | KeyReleaseMask)

/*==========================================================================*
   IWMWindowManager structures
 *==========================================================================*/

typedef struct {
    Atom wm_state;                          // standard properties
    Atom wm_change_state;
    Atom wm_protocols;
    Atom wm_delete_window;
    Atom wm_save_yourself;
    Atom wm_take_focus;
    Atom wm_colormap_windows;
    
    Atom net_supported;                     // EWMH root window
    Atom net_client_list;
    Atom net_client_list_stacking;
    Atom net_number_of_desktops;
    Atom net_desktop_geometry;
    Atom net_desktop_viewport;
    Atom net_current_desktop;
    Atom net_desktop_names;
    Atom net_active_window;
    Atom net_workarea;
    Atom net_supporting_wm_check;
    Atom net_virtual_roots;
    Atom net_desktop_layout;
    Atom net_showing_desktop;
    
    Atom net_close_window;                  // other EWMH root window
    Atom net_moveresize_window;
    Atom net_wm_moveresize;
    
    Atom net_wm_name;                       // EWMH app window 
    Atom net_wm_visible_name;
    Atom net_wm_icon_name;
    Atom net_wm_visible_icon_name;
    Atom net_wm_desktop;
    
    Atom net_wm_window_type;
    Atom net_wm_window_type_desktop;
    Atom net_wm_window_type_dock;
    Atom net_wm_window_type_toolbar;
    Atom net_wm_window_type_menu;
    Atom net_wm_window_type_utility;
    Atom net_wm_window_type_splash;
    Atom net_wm_window_type_dialog;
    Atom net_wm_window_type_normal;
    
    Atom kde_net_wm_window_type_override;
    
    Atom net_wm_state;
    Atom net_wm_state_modal;
    Atom net_wm_state_sticky;
    Atom net_wm_state_maximized_vert;
    Atom net_wm_state_maximized_horz;
    Atom net_wm_state_shaded;
    Atom net_wm_state_skip_taskbar;
    Atom net_wm_state_skip_pager;
    Atom net_wm_state_hidden;
    Atom net_wm_state_fullscreen;
    Atom net_wm_state_above;
    Atom net_wm_state_below;        /* enum{REMOVE,ADD,TOGGLE} */
    
    Atom net_wm_allowed_actions;
    Atom net_wm_action_move;
    Atom net_wm_action_resize;
    Atom net_wm_action_minimize;
    Atom net_wm_action_shade;
    Atom net_wm_action_stick;
    Atom net_wm_action_maximize_horz;
    Atom net_wm_action_maximize_vert;
    Atom net_wm_action_fullscreen;
    Atom net_wm_action_change_desktop;
    Atom net_wm_action_close;
    
    Atom net_wm_strut;
    Atom net_wm_icon_geometry;
    Atom net_wm_icon;
    Atom net_wm_pid;
    Atom net_wm_handled_icons;
    
    Atom net_wm_ping;                           // EWMH window manager
    
    Atom motif_wm_hints;                        // MOTIF (horrible)

    Atom iwm_window_type;                       // IWM atoms
    Atom iwm_window_type_unknown;
    Atom iwm_window_type_root_window;
    Atom iwm_window_type_client_window;
    Atom iwm_window_type_parent_window;
    Atom iwm_window_type_titlebar;
    Atom iwm_window_type_close_button;
    Atom iwm_window_type_minimize_button;
    Atom iwm_window_type_maximize_button;
    Atom iwm_window_type_resizebar;
    Atom iwm_window_type_left_grip;
    Atom iwm_window_type_right_grip;
    Atom iwm_window_type_icon;
    Atom iwm_window_type_reference;
    
    Atom gnustep_wm_attr;                       // GNUstep (needed?)
    Atom gnustep_titlebar_state;
    Atom gnustep_wm_miniaturizable_window;
} IWMAtomStruct;

// for use with EWMH _NET_WM_STATE
enum {
    _NET_WM_STATE_REMOVE,
    _NET_WM_STATE_ADD,
    _NET_WM_STATE_TOGGLE
};

// for use with EWMH _NET_WM_MOVERESIZE
enum {
    _NET_WM_MOVERESIZE_SIZE_TOPLEFT,
    _NET_WM_MOVERESIZE_SIZE_TOP,
    _NET_WM_MOVERESIZE_SIZE_TOPRIGHT,
    _NET_WM_MOVERESIZE_SIZE_RIGHT,
    _NET_WM_MOVERESIZE_SIZE_BOTTOMRIGHT,
    _NET_WM_MOVERESIZE_SIZE_BOTTOM,
    _NET_WM_MOVERESIZE_SIZE_LEFT,
    _NET_WM_MOVERESIZE_SIZE_MOVE,       // movement only
    _NET_WM_MOVERESIZE_SIZE_KEYBOARD,   // size via keyboard
    _NET_WM_MOVERESIZE_MOVE_KEYBOARD    // move via keyboard
};

/*==========================================================================*
   IWMClient structures
 *==========================================================================*/

typedef struct {
    struct {
        unsigned int border : 1;
        unsigned int resizebar : 1;
        unsigned int titlebar : 1;
        unsigned int close_button : 1;
        unsigned int minimize_button : 1;
        unsigned int maximize_button : 1;
        unsigned int icon : 1;
    } decor;
    
    struct {
        unsigned int focused : 1;
        unsigned int modal :1;
        unsigned int sticky : 1;
        unsigned int hidden : 1;
        unsigned int shaded : 1;
        unsigned int maximized_horz : 1;
        unsigned int maximized_vert : 1;
        unsigned int fullscreen : 1;
        unsigned int skip_taskbar : 1;
        unsigned int skip_pager : 1;
        unsigned int above : 1;
        unsigned int below : 1;
        unsigned int shaped : 1;
        unsigned int gnustep : 1;
    } state;
    
    struct {
        Window window;
        Window parent;
        Window titlebar;
        Window close_button;
        Window minimize_button;
        Window maximize_button;
        Window resizebar;
        Window left_grip;
        Window right_grip;
        Window transient;
        Window icon;
    } windows;
} IWMClientDescriptor;

/*==========================================================================*
   IWMWindow structures
 *==========================================================================*/

typedef enum {
    IWM_WINDOW_TYPE_UNKNOWN = 0,
    IWM_WINDOW_TYPE_ROOT_WINDOW = 1,
    IWM_WINDOW_TYPE_CLIENT_WINDOW = 2,
    IWM_WINDOW_TYPE_PARENT_WINDOW = 3,
    IWM_WINDOW_TYPE_TITLEBAR = 4,
    IWM_WINDOW_TYPE_CLOSE_BUTTON = 5,
    IWM_WINDOW_TYPE_MINIMIZE_BUTTON = 6,
    IWM_WINDOW_TYPE_MAXIMIZE_BUTTON = 7,
    IWM_WINDOW_TYPE_RESIZEBAR = 8,
    IWM_WINDOW_TYPE_LEFT_GRIP = 9,
    IWM_WINDOW_TYPE_RIGHT_GRIP = 10,
    IWM_WINDOW_TYPE_ICON = 11,
    IWM_WINDOW_TYPE_REFERENCE = 12
} IWMWindowType;

typedef struct {
    Window        window;
    Pixmap        pixmap;
    XContext      clientID;
    IWMWindowType type;
} IWMWindowDescriptor;

/*==========================================================================*
   defines for IWMTitlebar
 *==========================================================================*/

#define IWM_MINIMUM_SIZE        32
#define IWM_RESIZEBAR_HEIGHT    4
#define GRIP_WIDTH              30

typedef enum {
    IWM_FOCUS_MOUSE,
    IWM_FOCUS_CLICK,
    IWM_FOCUS_SLOPPY
} IWMFocusType;

/*
 * courtesy of WindowMaker's GNUstep.h
 */

#define GSWindowStyleAttr 	(1<<0)
#define GSWindowLevelAttr 	(1<<1)
#define GSMiniaturizePixmapAttr	(1<<3)
#define GSClosePixmapAttr	(1<<4)
#define GSMiniaturizeMaskAttr	(1<<5)
#define GSCloseMaskAttr		(1<<6)
#define GSExtraFlagsAttr	(1<<7)
#define GSDocumentEditedFlag	(1<<0)
#define GSNoApplicationIconFlag	(1<<5)

#endif /* _INTERFACEWM_H_ */

