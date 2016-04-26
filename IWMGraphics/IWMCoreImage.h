

/*
 * $Id: IWMCoreImage.h,v 1.1 2003/08/19 01:51:47 copal Exp $
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

/*
 * The IWMCoreImage structure is present to further abstract the image types
 * used by Interface.  This will allow easier porting to other graphics
 * libraries in the future.
 */

#ifndef _IWMCOREIMAGE_H_
#define _IWMCOREIMAGE_H_ 1

//#include "IWMCoreWindow.h"
#include "IWMWindow.h"
#include "IWMScreen.h"

#include "wraster.h"

typedef struct _IWMCoreImage IWMCoreImage;

struct _IWMCoreImage {
    RImage *image;
};

/*
 * creation from file
 */
IWMCoreImage iwm_image_new(IWMScreen *screen, char *filepath);

/*
 * scaling
 */
IWMCoreImage iwm_image_scale(IWMCoreImage image, int width, int height);

/*
 * tiling
 */
IWMCoreImage iwm_image_tile(IWMCoreImage image, int width, int height);

/*
 * obtaining pixmap format
 */
Pixmap iwm_image_pixmap(IWMCoreImage image, IWMScreen *screen);

/*
 * setting into an IWMWindow
 */
Pixmap iwm_image_set_into_window(IWMCoreImage image, IWMWindow *window,
                                 IWMScreen *screen);

/*
 * image format
 */
const char *iwm_image_format(IWMCoreImage image);

/*
 * cleanup
 */
void iwm_image_release(IWMCoreImage image);

#endif /* _IWMCOREIMAGE_H_ */

