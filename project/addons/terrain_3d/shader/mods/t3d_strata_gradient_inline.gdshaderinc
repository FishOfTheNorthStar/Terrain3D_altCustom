#if defined(STRATA_GRADIENT_ENABLED) && defined(STRATA_GRADIENT_ENABLED_SUPPORT)
	// *** CONFIRM NECESSARY OVERLAY OUTPUT REGISTER CREATED ***
	#if !defined(INLINE_EFFECT_SETUP)
		#include "res://addons/terrain_3d/shader/core/t3d_inline_effect_first.gdshaderinc"
	#endif

	// *** PROCESS THE CARTOGRAPHY OVERLAY EFFECT ***
	// Save the results for the commit or next overlay effect
	get_strata_tint_effects(
		__overlay_shared_param_best_gradient_periods,
		__overlay_shared_param_best_elevmarks,
		__overlay_shared_param_best_veg,
		__overlay_shared_param_pixel_worldpos,		// The world position of the vertex (looks better if it's not flat varying)
		__overlay_shared_param_normal_map_flatness,		// The flatness of the mixed normal map texture
		v_role,
		v_noise,
		__overlay_fx__ );								// Pass the daisy-chained overlay effect output register

#endif