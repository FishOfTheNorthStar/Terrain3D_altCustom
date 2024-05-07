#if !defined(INLINE_EFFECT_SETUP)
#define INLINE_EFFECT_SETUP
#if defined(ALREADY_CALCULATED_PIXELPOS)
	vec3 __overlay_shared_param_pixel_worldpos = __best_pixelpos;
#else
	vec3 __overlay_shared_param_pixel_worldpos = ( INV_VIEW_MATRIX * vec4(VERTEX,1.0) ).xyz;
#endif
vec3 __overlay_shared_param_pixel_world_normal = v_normal;
vec3 __overlay_shared_param_best_noise = __best_noise;
vec4 __overlay_shared_param_best_gradient_periods = __best_gradients;
vec4 __overlay_shared_param_best_elevmarks = __best_elevmarks;
float __overlay_shared_param_best_veg = __best_veg;
float __overlay_shared_param_best_camdist = __best_camdist;

float __overlay_shared_param_normal_map_flatness = clamp((dot(NORMAL_MAP.rgb*2.0-1.0, vec3(0.0,0.0,1.0))),0.,1.);
mat4 __overlay_shared_param_mixed_material = mixed_mat; // 3rd entry in the mixed down material from fragment()
mat4 __overlay_fx__ = mat4(
	vec4( ALBEDO.rgb,		0.),
	vec4( NORMAL_MAP.rgb,	0.),
	vec4(
		EMISSION.rgb, 
		AO ),	
	vec4(
		ROUGHNESS, 
		METALLIC, 
		SPECULAR, 
		AO_LIGHT_AFFECT) );
#endif