// --------------------------------------------------------------------------------------
// * Placeholder function / variable defs to appease syntax highlighter in Godot:
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
void placeholder_func_APPLY_OVERLAYS() {
#endif
// --------------------------------------------------------------------------------------
// BEGIN FRAGMENT APPLY OVERLAYS
// --------------------------------------------------------------------------------------

	#include "res://addons/terrain_3d/shader/mods/debug_view.gdshaderinc"
	
	#if defined(ADJUST_AORMS_ENABLED)
	#include "res://addons/terrain_3d/shader/mods/t3d_adjust_aorms_mod_inline.gdshaderinc"
	#endif

	#if defined(STRATA_GRADIENT_ENABLED)
	#include "res://addons/terrain_3d/shader/mods/t3d_strata_gradient_inline.gdshaderinc"
	#endif

	#if defined(RAIN_ENABLED)
	#include "res://addons/terrain_3d/shader/mods/t3d_rain_spec_mod_inline.gdshaderinc"
	#endif

	// * INLINE EFFECT COMMIT STAGE *
	// If anything created the inline effect output object, apply the final result 
	#if defined(INLINE_EFFECT_SETUP)
	#include "res://addons/terrain_3d/shader/core/t3d_inline_effect_commit.gdshaderinc"
	#endif

// --------------------------------------------------------------------------------------
// END FRAGMENT APPLY OVERLAYS 
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
}
#endif