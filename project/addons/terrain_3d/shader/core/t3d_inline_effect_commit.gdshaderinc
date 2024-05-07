#if defined(INLINE_EFFECT_SETUP)
	ALBEDO			= __overlay_fx__[0].rgb;
	NORMAL_MAP		= __overlay_fx__[1].rgb;
	EMISSION		= __overlay_fx__[2].rgb;
	ROUGHNESS		= __overlay_fx__[3].x;
	METALLIC		= __overlay_fx__[3].y;
	SPECULAR		= __overlay_fx__[3].z;
	AO				= __overlay_fx__[2].w;
	AO_LIGHT_AFFECT	= __overlay_fx__[3].w;
#endif