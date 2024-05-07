#if defined(CARTOGRAPHY_SUPPORT)
	// *** CONFIRM NECESSARY OVERLAY OUTPUT REGISTER CREATED ***
	#if !defined(INLINE_EFFECT_SETUP)
		#include "res://addons/terrain_3d/shader/core/t3d_inline_effect_first.gdshaderinc"
	#endif

	// *** PROCESS THE CARTOGRAPHY OVERLAY EFFECT ***
	// Save the results for the commit or next overlay effect
	__overlay_fx__ =			
		get_carto_effects(
			__overlay_shared_param_pixel_worldpos,			// The world position of the vertex (looks better if it's not flat varying)
			__overlay_shared_param_pixel_world_normal,		// The world normal of the terrain at that position (without effects of texture normal)
			__overlay_fx__ );								// Pass the daisy-chained overlay effect output register

#endif