R"(
//INSERT: HEADER_START_MARK
// MARK:__START_HEADER__

//INSERT: HEADER
shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

/* This shader is generated based upon the debug views you have selected.
 * The terrain function depends on this shader. So don't change:
 * - vertex positioning in vertex()
 * - terrain normal calculation in fragment()
 * - the last function being fragment() as the editor injects code before the closing }
 *
 * Most will only want to customize the material calculation and PBR application in fragment()
 *
 * Uniforms that begin with _ are private and will not display in the inspector. However, 
 * you can set them via code. You are welcome to create more of your own hidden uniforms.
 *
 * This system only supports albedo, height, normal, roughness. Most textures don't need the other
 * PBR channels. Height can be used as an approximation for AO. For the rare textures do need
 * additional channels, you can add maps for that one texture. e.g. an emissive map for lava.
 *
 */

// _________________________________
// ** DEFINE requested features ( these could be defined much 
// earlier in the script but for clarity it sits here for now )
//
#define __T3D_STANDARD_TEXTURING__

#if defined(STRATA_GRADIENT_ENABLED)
	#define FRAG_SAMPLE_TINT_NOISE
	#define FRAG_SAMPLE_GRADIENTS
	#define FRAG_SAMPLE_VEGETATION
#endif

#include "res://addons/terrain_3d/shader/ext/fastnoiselite.gdshaderinc"

// Public uniforms
uniform bool height_blending = true;
uniform float blend_sharpness : hint_range(0, 1) = 0.87;

// Structs & Type Definitions
#include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"

// [ NOTE: If a custom shader wants to override a mod's standard parameter provider function with a user's custom version, that must happen before this line. ]
#include "res://addons/terrain_3d/shader/core/t3d_managed_uniforms.gdshaderinc"

// [_World_Noise_Uniforms_Begin_]
uniform int _world_noise_max_octaves;
uniform int _world_noise_min_octaves;
uniform float _world_noise_lod_distance;
uniform float _world_noise_scale;
uniform float _world_noise_height;
uniform vec3 _world_noise_offset;
uniform float _world_noise_blend_near;
uniform float _world_noise_blend_far;
// [_World_Noise_Uniforms_End_]

// [_Noise_Tint_Uniforms_Begin_]
uniform vec3 _noise_tint_macro_variation1;
uniform vec3 _noise_tint_macro_variation2;
// Generic noise at 3 scales, which can be used for anything 
uniform float _noise_tint_noise1_scale;
uniform float _noise_tint_noise1_angle;
uniform vec2 _noise_tint_noise1_offset = vec2(0.5);
uniform float _noise_tint_noise2_scale;
uniform float _noise_tint_noise3_scale;

float P_TINT_NZ_SCALE_3() { return _noise_tint_noise3_scale; }
vec3 P_TINT_NZ_SCL() { return vec3(
	_noise_tint_noise1_scale,
	_noise_tint_noise2_scale,
	_noise_tint_noise3_scale ); }
vec3 P_TINT_NZ_OFFS() { return vec3(
	_noise_tint_noise1_offset,
	_noise_tint_noise1_angle ); }
// [_Noise_Tint_Uniforms_End_]


// Varyings
#include "res://addons/terrain_3d/shader/core/t3d_managed_varyings.gdshaderinc"

// _________________________________
// ** IMPORT CORE FUNCTIONS
// These define the core internal functions the shader's vertex and fragment functions call.
#define __T3D_INTERNAL_GLOBALS_AVAILABLE__
#include "res://addons/terrain_3d/shader/core/t3d_standard_functions.gdshaderinc"
#include "res://addons/terrain_3d/shader/core/t3d_deliver_texture_id_funcs.gdshaderinc"


// [ NOTE: All requested mods parameter provider functions (or their overrides) must be declared before this line.]
// _________________________________
// ** IMPORT ADDITONAL FUNCTIONS
// First set this define, so the included files can detect that
// references out of scope to certain named globals is (or may be) 
// valid.  This is only to help Godot's shader editor out, so it's
// not full of error messages about undeclared variables.  This is 
// the only place this should be defined at and its not optional.
// _________________________________
// ** INCLUDE the prototype non-standard utility functions ( todo: 
// perhaps only include these if defines are detected that require it.  
// For now it's so light weight, it hardly matters. )
//
#include "res://addons/terrain_3d/shader/proto/t3d_utility.gdshaderinc"
// _________________________________
// ** FEATURE function definition includes, as needed.  These includes
// only define functions, not produce output directly.  Then later, in
// the fragment function, each has a corresponding "..._inline.gdshaderinc"
// file and that gets included in the fragment at the end, and it calls
// the function(s) defined in these files.
//
#if defined(CARTOGRAPHY_OVERLAYS)
#include "res://addons/terrain_3d/shader/mods/t3d_carto.gdshaderinc"
#endif
#if defined(STRATA_GRADIENT_ENABLED) || defined(VEGETATION_ENABLED)
#include "res://addons/terrain_3d/shader/mods/t3d_gradients.gdshaderinc"
#endif
#if defined(RAIN_ENABLED)
#include "res://addons/terrain_3d/shader/mods/t3d_rain_spec_mod.gdshaderinc"
#endif
#if defined(ADJUST_AORMS_ENABLED)
#include "res://addons/terrain_3d/shader/mods/t3d_adjust_aorms_mod.gdshaderinc"
#endif
#if defined(UV_DISTORTION_ENABLED)
#include "res://addons/terrain_3d/shader/mods/t3d_uv_distort_funcs.gdshaderinc"
#endif
//INSERT: HEADER_END_MARK_NOTICE
// -------------------------------------------------------------------------
// * Note, any code above this line will be removed the next time any change
// is made to the shader parameters, or it reloads for whatever reason.  Do
// not remove or alter the line below or anything above.
// ----------------------------------------------------
//INSERT: HEADER_END_MARK
//MARK:__END_HEADER__
)"