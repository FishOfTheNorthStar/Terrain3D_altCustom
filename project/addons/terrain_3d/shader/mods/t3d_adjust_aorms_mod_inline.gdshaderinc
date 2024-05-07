#if defined(ADJUST_AORMS_ENABLED) && defined(__T3D_ADJUST_AORMS_MOD__)
	// *** CONFIRM NECESSARY OVERLAY OUTPUT REGISTER CREATED ***
	#if !defined(INLINE_EFFECT_SETUP)
		#include "res://addons/terrain_3d/shader/core/t3d_inline_effect_first.gdshaderinc"
	#endif

	// *** PROCESS THE AO / ROUGHNESS / METALLIC / SATURATIOON MOD OVERLAY EFFECT ***
	// Save the results for the commit or next overlay effect
	get_adjust_aorms_mod_effects(
		__overlay_shared_param_mixed_material,			// The mixed material, we mostly need index [2], amount of adjustment to AO/R/M/S(at), but the other channels may be useful too.
		__overlay_fx__ );								// Pass the daisy-chained overlay effect output register

#endif