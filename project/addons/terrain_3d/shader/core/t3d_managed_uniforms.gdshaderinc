// Copyright (c) 2023 Cory Petkovsek, Roope Palmroos, and Contributors.
//
#if !defined(__T3D_MANAGED_UNIFORMS_AVAILABLE__)
#define __T3D_MANAGED_UNIFORMS_AVAILABLE__
// -----------------------------------------------------------------------------
// This file serves two purposes, declare required uniforms if defines are
// established that signify they're needed, and declare interface functions 
// that deliver some of those uniforms as return values to the requested
// modules.
//
// ** About registering feature parameter value provider functions:
//
// [ IMPORTANT: Do this before including the feature core functions! ]
//
// Each feature typically has one or more parameters, which the internals
// require access to.  By using these short defined functions, we can
// isolate implementation specific stuff like "my_fancy_uniform", and
// keep it out of the feature driver functions. Then those core functions 
// can remain agnostic and interoperable between Terrain3d repo branches.
// *****************************************************************************

// Private uniforms (Core internals)

// Region Samplers:
uniform usampler2DArray _control_maps	: repeat_disable;
uniform sampler2DArray	_height_maps	: repeat_disable;
uniform sampler2DArray	_normal_maps	: repeat_disable;

// Note: this next one could potentially be omitted in instances where world noise generation 
// is not enabled but the material resource would need to know not to try to set this uniform 
// in those instances.
uniform sampler2D	_region_blend_map	: hint_default_black, filter_linear, repeat_disable;

// Region Data Arrays:
uniform int		_region_map[256];
uniform vec2	_region_offsets[256];

uniform int		_region_map_size = 16;
uniform float	_region_size = 1024.0;
uniform float	_region_texel_size = 0.0009765625;	// = 1/1024

// Texture Samplers:
#if defined(TEXTURE_SAMPLERS_LINEAR)
uniform sampler2DArray _color_maps : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2DArray _texture_array_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2DArray _texture_array_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D noise_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
#else
// TEXTURE_SAMPLERS_NEAREST
uniform sampler2DArray _color_maps : source_color, filter_nearest_mipmap_anisotropic, repeat_disable;
uniform sampler2DArray _texture_array_albedo : source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform sampler2DArray _texture_array_normal : hint_normal, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform sampler2D noise_texture : source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
#endif

// Texture Data Arrays:
uniform float _texture_uv_scale_array[32];
uniform float _texture_uv_rotation_array[32];
uniform float _texture_specadjust_array[32];
uniform vec4 _texture_color_array[32];
uniform vec4 _texture_solidcolor_array[32];
uniform vec4 _texture_userdata_array[32];

// Mesh Settings (for this material instance):
uniform float _mesh_vertex_spacing = 1.0;
uniform float _mesh_vertex_density = 1.0;			// = 1/_mesh_vertex_spacing

uniform uint _background_mode = 1u;					// NONE = 0, FLAT = 1, NOISE = 2
uniform uint _mouse_layer = 0x80000000u;			// Layer 32

// *****************************************************************************
// END: CORE INTERNALS
// -----------------------------------------------------------------------------
// BEGIN: MOD UNIFORMS
// *****************************************************************************
#if defined(AUTO_SHADER_ENABLED)
// [_Auto_Shader_Uniforms_Begin_]
uniform float _auto_shader_slope;
uniform float _auto_shader_height_reduction;
uniform int _auto_shader_base_texture;
uniform int _auto_shader_overlay_texture;
// [_Auto_Shader_Uniforms_End_]
#endif

// *****************************************************************************

#if defined(FEATURE_SHADER_ENABLED)
// [_Feature_Shader_Uniforms_Begin_]
uniform vec4 _feature_shader_slopes;
uniform float _feature_shader_height_bias;
uniform int _feature_shader_vertical_texture;
uniform int _feature_shader_hazard_texture;
uniform int _feature_shader_obstruction_texture;
uniform int _feature_shader_flat_texture;
uniform int _feature_shader_flat_inner_texture;
uniform int _feature_shader_puddle_texture;

uniform int _feature_shader_vertical_alt_texture;
uniform int _feature_shader_hazard_alt_texture;
uniform int _feature_shader_obstruction_alt_texture;
uniform int _feature_shader_flat_alt_texture;
uniform int _feature_shader_flat_alt_inner_texture;
uniform int _feature_shader_puddle_alt_texture;

#if !defined(T3D_PROVIDE_MATS_BY_ROLE)
#define T3D_PROVIDE_MATS_BY_ROLE
vec4 GET_FEATURE_BREAKS() { 
	return _feature_shader_slopes; }
int[6] GET_MAT_ROLE_INDEX() {
	return { 
		_feature_shader_vertical_texture, 
		_feature_shader_hazard_texture, 
		_feature_shader_obstruction_texture, 
		_feature_shader_flat_texture, 
		_feature_shader_flat_inner_texture, 
		_feature_shader_puddle_texture }; }
int[6] GET_MAT_ALTS_INDEX() {
	return { 
		_feature_shader_vertical_alt_texture, 
		_feature_shader_hazard_alt_texture, 
		_feature_shader_obstruction_alt_texture, 
		_feature_shader_flat_alt_texture, 
		_feature_shader_flat_alt_inner_texture, 
		_feature_shader_puddle_alt_texture }; }
#endif
// [_Feature_Shader_Uniforms_End_]
#endif

// *****************************************************************************

#if defined(CARTOGRAPHY_OVERLAYS)
	uniform float _debug_view_cartographer_darkmode;
	uniform float _debug_view_cartographer_masking;
	uniform vec3 _debug_view_cartographer_elevation_opacity_per_phase;
	uniform vec3 _debug_view_cartographer_grid_opacity_per_phase;
	uniform vec3 _debug_view_cartographer_features_opacity_per_phase;

	#if !defined(__CARTO_PROVIDE_PARAMS)
		#define __CARTO_PROVIDE_PARAMS
//
// Provide current preset index value to the carto overlay functions.
// It doesn't have to be a uniform adjustable setting, if someone wanted to 
// use the overlays in-game they could return a constant value.
//
		float CARTO_PREFERRED_INDEX() { return _debug_view_cartographer_darkmode; }		
		float CARTO_PREFERRED_RANGE() { return _debug_view_cartographer_masking; }		
	#endif
#endif

// *****************************************************************************

#if defined(MULTI_SCALING_ENABLED)
	uniform int _multi_scale_texture;
	uniform float _multi_scale_micro_size;
	uniform float _multi_scale_macro_size;
	uniform float _multi_scale_far;
	uniform float _multi_scale_near;
#endif

// *****************************************************************************

#if defined(UV_DISTORTION_ENABLED)
	uniform float _uv_distortion_size;
	uniform float _uv_distortion_power;
#endif

// *****************************************************************************

#if defined(ADJUST_AORMS_ENABLED)
	uniform float _adjust_aorms_ao_exp;
#endif

// *****************************************************************************

#if defined(RAIN_ENABLED)
	uniform float _rain_current_level;
	uniform float _rain_puddles_size;
#endif

// *****************************************************************************

#if defined(STRATA_GRADIENT_ENABLED)
	uniform float _rain_current_level;
	uniform float _strata_gradient_vertical_surface_scale;
	uniform float _strata_gradient_vertical_power;
	uniform float _strata_gradient_flat_surface_scale;
	uniform float _strata_gradient_flat_power;
#endif

// *****************************************************************************

#if defined(VEGETATION_ENABLED)
	uniform float _vegetation_size;
	uniform float _vegetation_height;
#endif

// *****************************************************************************
// END: MOD UNIFORMS
// -----------------------------------------------------------------------------

#endif
