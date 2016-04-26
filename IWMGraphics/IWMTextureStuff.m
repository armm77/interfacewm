
@interface IWMIGradientTexture : IWMTexture
{
@public
    char dummy;
    RColor colors1[2];
    RColor colors2[2];
    int thickness1;
    int thickness2;
}

- initWithScreen:(IWMScreen *)aScreen thickness1:(int)aThickness1
    
{
    WTexIGradient *texture;
    XGCValues gcv;
    int i;

    
    texture = wmalloc(sizeof(WTexture));
    memset(texture, 0, sizeof(WTexture));
    texture->type = WTEX_IGRADIENT;
    for (i = 0; i < 2; i++) {
	texture->colors1[i] = colors1[i];
	texture->colors2[i] = colors2[i];
    }
    texture->thickness1 = thickness1;
    texture->thickness2 = thickness2;
    if (thickness1 >= thickness2) {
	texture->normal.red = (colors1[0].red + colors1[1].red)<<7;
	texture->normal.green = (colors1[0].green + colors1[1].green)<<7;
	texture->normal.blue = (colors1[0].blue + colors1[1].blue)<<7;
    } else {
	texture->normal.red = (colors2[0].red + colors2[1].red)<<7;
	texture->normal.green = (colors2[0].green + colors2[1].green)<<7;
	texture->normal.blue = (colors2[0].blue + colors2[1].blue)<<7;
    }
    XAllocColor(dpy, scr->w_colormap, &texture->normal);
    gcv.background = gcv.foreground = texture->normal.pixel;
    gcv.graphics_exposures = False;
    texture->normal_gc = XCreateGC(dpy, scr->w_win, GCForeground|GCBackground
				   |GCGraphicsExposures, &gcv);

    return texture;
}

@end

