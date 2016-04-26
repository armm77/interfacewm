
/*
 * $Id: IWMCoreImage.m,v 1.1 2003/08/19 01:51:47 copal Exp $
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

#include "IWMCoreImage.h"
#include "IWMWindow.h"

/*
 * creation from file
 */
IWMCoreImage iwm_image_new(IWMScreen *screen, char *filepath)
{
    IWMCoreImage result;
    
    result.image = RLoadImage(screen->rcontext, filepath, 0);

    return result;
}

/*
 * scaling
 */
IWMCoreImage iwm_image_scale(IWMCoreImage image, int width, int height)
{
    IWMCoreImage result;

    result.image = RScaleImage(image.image, width, height);

    return result;
}

/*
 * tiling
 */
IWMCoreImage iwm_image_tile(IWMCoreImage image, int width, int height)
{
    IWMCoreImage result;

    result.image = RMakeTiledImage(image.image, (unsigned)width,
                        (unsigned)height);

    return result;
}

/*
 * obtaining pixmap format
 */
Pixmap iwm_image_pixmap(IWMCoreImage image, IWMScreen *screen)
{
    Pixmap pixmap;
    int    result;
    
    if ((result = RConvertImage(screen->rcontext, image.image, &pixmap)))
    {
        return pixmap;
    }

    return (Pixmap) NULL;
}

/*
 * setting into an IWMWindow
 */
Pixmap iwm_image_set_into_window(IWMCoreImage image, IWMWindow *window,
                                 IWMScreen *screen)
{
    XWindowAttributes    attr;
    Pixmap               pixmap;
    IWMCoreImage         tmp;

    // obtain attributes of target window
    attr = [window attributes];
    
    // scale image & create pixmap format
    tmp    = iwm_image_scale(image, attr.width+(BORDER_WIDTH * 2), attr.height);
    pixmap = iwm_image_pixmap(tmp, screen);

    // set the pixmap into target window
    [window setPixmap:pixmap];
    //XSetWindowBackgroundPixmap(GlobalDisplay, [window xWindow], pixmap);
    //[window clear];
    //XSync(display, False);
    
    // cleanup
    iwm_image_release(tmp);

    return pixmap;
}

/*
 * image format
 */
const char *iwm_image_format(IWMCoreImage image)
{
    const char *formats[] = { "", "XPM", "TIFF", "PNG", "PPM", "JPEG", "GIF", NULL };

    return (formats[image.image->format]);
}

/*
 * cleanup
 */
void iwm_image_release(IWMCoreImage image)
{
    // ensure that the image will be released by decrementing the reference
    // count to 1
    image.image->refCount = 1;
    RReleaseImage(image.image);
}

