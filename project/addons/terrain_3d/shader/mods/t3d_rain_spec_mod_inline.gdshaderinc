#if defined(RAIN_ENABLED) && defined(__T3D_RAIN_SPEC_MOD__)
	// *** CONFIRM NECESSARY OVERLAY OUTPUT REGISTER CREATED ***
	#if !defined(INLINE_EFFECT_SETUP)
		#include "res://addons/terrain_3d/shader/core/t3d_inline_effect_first.gdshaderinc"
	#endif

	// *** PROCESS THE RAIN SPECULAR (ROUGHNESS/METALLIC) MOD OVERLAY EFFECT ***
	// Save the results for the commit or next overlay effect		
	get_rain_spec_mod_effects(
		__overlay_shared_param_pixel_worldpos,		// The world position of the vertex (looks better if it's not flat varying)
		__overlay_shared_param_normal_map_flatness,		// The flatness of the mixed normal map texture
		v_role,
		v_noise,
		__overlay_fx__ );								// Pass the daisy-chained overlay effect output register

#endif