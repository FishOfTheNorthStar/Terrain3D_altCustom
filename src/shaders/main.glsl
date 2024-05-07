// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

R"(

#include "res://addons/terrain_3d/shader/mods/t3d_world_noise_funcs.gdshaderinc"


const vec4 EMPTY = vec4(0.);
const vec4 NEUTRAL = vec4(0.5f, 0.5f, 1.0f, 1.0f);

vec3 get_local_noise(vec3 world_pos) {
	vec2 _uv = world_pos.xz;
	vec3 out_grad, out_dgrad, out_dgrad2;
	float __tint_noise1 = texture(noise_texture, rotate(_uv*_noise_tint_noise1_scale*.1, cos(_noise_tint_noise1_angle), sin(_noise_tint_noise1_angle)) + _noise_tint_noise1_offset).r;
	float __tint_noise2 = texture(noise_texture, _uv*_noise_tint_noise2_scale*.1 ).r;
	return vec3(
		psrddnoise(world_pos*0.025, vec3(5.) , 0.0, out_grad, out_dgrad, out_dgrad2),
		__tint_noise1,
		__tint_noise2); }

//                                                                             #
//                                                                             #
//                                                                             #
// #############################################################################
//                                                                             #
//  _____________                                                              #
//_/   VERTEX    \____________________________________________________         #
//                                                                    :        #
void vertex() {	

// *** INIT STANDARD VARYINGS
#include "res://addons/terrain_3d/shader/vertex/t3d_vertex_init_varyings.gdshaderinc"
// ---
// *** EARLY DISCARD TEST 
// This tests for terrain holes, or 'no background' setting in empty tiles, and something 
// about mouse layers I don't fully understand yet.  Note that file has an intentionally 
// unmatched else condition. The marked '!!!' curly brace set below finish that condition
// within this file.
// ---
#include "res://addons/terrain_3d/shader/vertex/t3d_vertex_early_discard_test.gdshaderinc"
{	// <- (!!!)
	// ---------------------------------------------------
	// [ BEGIN ] PRIMARY PRE-TESTED TERRAIN VERTEX CODE
	// ---
	// *** CALC_NORMAL (PER_VERTEX MODE)
	#include "res://addons/terrain_3d/shader/vertex/t3d_vertex_calc_normal.gdshaderinc"
	// ---------------------------------------------------

	// Get final vertex location and save it
	VERTEX.y = _vertH.w;

	// ---------------------------------------------------
	// *** APPLY STANDARD VARYINGS
	#include "res://addons/terrain_3d/shader/vertex/t3d_vertex_apply_standard_varyings.gdshaderinc"
	// ---
	// *** VERTEX VEGETATION
	#include "res://addons/terrain_3d/shader/vertex/t3d_vertex_vegetation.gdshaderinc"
	// ---
	// [ END ] PRIMARY PRE-TESTED TERRAIN VERTEX CODE
	// ---------------------------------------------------
}	// <- (!!!)
// ---

	// Transform UVs to local to avoid poor precision during varying interpolation.
	v_uv_offset = MODEL_MATRIX[3].xz * _mesh_vertex_density;
	v_uv2_offset = v_uv_offset * _region_texel_size;
	UV -= v_uv_offset;
	UV2 -= v_uv2_offset; 
}
//                                                                    :        #
//\___________________________________________________________________:        #
//                                                                             #
//                                                                             #
// #############################################################################
//                                                                             #
//                                                                             #

// 2-4 lookups
void get_material(vec2 base_uv, vec4 _grad, uint control, int region, float random_angle, out Material out_mat) {
	out_mat = Material(
		vec4(0.), 
		vec4(0.),
#if defined(ADJUST_AORMS_ENABLED)
		vec4(0.),
#endif
		0, 0, 0.0);
	vec3 normal = v_normal;
	//vec2 uv_center = vec2(iuv_center.xy);
	//vec2 uv_distorted = uv_center + v_uvdistort;

//	vec3 _role_mats = get_best_mat_by_role();
//	float _blend = 0.;
//	ivec2 _ids = GET_MAT_IDS_AND_BLEND(control, region, v_normal, _blend);
	out_mat.blend = 0.0;//_blend;
	out_mat.base = 0;//_ids.x; 
	out_mat.over = 1;//_ids.y;

	#if defined(FEATURE_SHADER_ENABLED)
		vec3 _role_mats = get_best_mat_by_role();
		out_mat.blend = _role_mats.z;
		out_mat.base = int(_role_mats.x);
		out_mat.over = int(_role_mats.y);
	#else 
		float _blend = 0.;
		ivec2 _ids = GET_MAT_IDS_AND_BLEND(control, region, v_normal, _blend);
		out_mat.blend = _blend;
		out_mat.base = _ids.x; 
		out_mat.over = _ids.y;
	#endif

	base_uv *= .5; // Allow larger numbers on uv scale array - move to C++

	#if defined(ADJUST_AORMS_ENABLED)
		vec2 spec_adjusts = vec2(
			_texture_specadjust_array[out_mat.base],
			_texture_specadjust_array[out_mat.over]);
		vec2 _sped_adjust_to_less = min(vec2(1.), spec_adjusts*2.0);
		vec2 _sped_adjust_to_more = max(vec2(0.), spec_adjusts*2.0-1.0);
		vec2 _ao_adjusts = vec2(1.0 + _texture_userdata_array[out_mat.base].y, 1.0 + _texture_userdata_array[out_mat.over].y);
	#endif

	vec2 _norm_adjusts = vec2(1.0 + _texture_userdata_array[out_mat.base].x, 1.0 + _texture_userdata_array[out_mat.over].x);
	
	
	const float UVD_BASE_TEX_SCALE = 0.05;
	vec2 uv_scales = vec2(
		_texture_uv_scale_array[out_mat.base],		// trying this same size for feature shader, was:	//0.5 * _texture_uv_scale_array[out_mat.base],
		_texture_uv_scale_array[out_mat.over]);
	vec2 uvd_scales = uv_scales / UVD_BASE_TEX_SCALE;

#if defined(UV_DISTORTION_ENABLED)
	vec2 uv1 = fma(base_uv,vec2(uv_scales.xx),(v_uvdistort * uvd_scales.x));
#else
	vec2 uv1 = base_uv * uv_scales.x;
#endif

	vec2 matUV = rotate_around(uv1, uv1 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.base]);
	vec4 uv1_grad = vec4(dFdx(matUV), dFdy(matUV));// _grad * uv2_scale; 

	vec4 albedo_ht, normal_rg, albedo_far, normal_far;
	albedo_ht = EMPTY; albedo_far = EMPTY;
	normal_rg = NEUTRAL; normal_far = NEUTRAL;
	
#include "res://addons/terrain_3d/shader/core/t3d_deliver_scaled_base_inline.gdshaderinc"

	// Temp Spec adjust mod
	//normal_rg.a = mix(1., mix(normal_rg.a,0.0,_sped_adjust_to_more.x), _sped_adjust_to_less.x);

	// Apply color to base
	albedo_ht.rgb *= _texture_color_array[out_mat.base].rgb;

	// Unpack base normal for blending
	normal_rg.xz = unpack_normal(normal_rg).xz * _norm_adjusts.x;

	// Setup overlay texture to blend
#if defined(UV_DISTORTION_ENABLED)
	vec2 uv2 = fma(base_uv,vec2(uv_scales.yy),(v_uvdistort * uvd_scales.y));
#else
	vec2 uv2 = base_uv * uv_scales.y;
#endif
	vec2 matUV2 = rotate_around(uv2, uv2 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.over]);
	vec4 uv2_grad = vec4(dFdx(matUV2), dFdy(matUV2));// _grad * uv2_scale; 

	vec4 albedo_ht2 = textureGrad(_texture_array_albedo, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);
	vec4 normal_rg2 = textureGrad(_texture_array_normal, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);
	//normal_rg2.a = mix(1.0, mix(normal_rg2.a,0.0,_sped_adjust_to_more.y), _sped_adjust_to_less.y);

	// Though it would seem having the above lookups in this block, or removing the branch would
	// be more optimal, the first introduces artifacts #276, and the second is noticably slower. 
	// It seems the branching off dual scaling and the color array lookup is more optimal.
	if (out_mat.blend > 0.f) {

#include "res://addons/terrain_3d/shader/core/t3d_deliver_scaled_base_inline.gdshaderinc"

		// Apply color to overlay
		albedo_ht2.rgb *= _texture_color_array[out_mat.over].rgb;


		// Unpack overlay normal for blending
		normal_rg2.xz = unpack_normal(normal_rg2).xz * _norm_adjusts.y;

		// Blend overlay and base
		albedo_ht = height_blend(albedo_ht, albedo_ht.a, albedo_ht2, albedo_ht2.a, out_mat.blend);
		normal_rg = height_blend(normal_rg, albedo_ht.a, normal_rg2, albedo_ht2.a, out_mat.blend); }
	
	// Repack normals and return material
	normal_rg = pack_normal(normal_rg.xyz, normal_rg.a);
	out_mat.alb_ht = albedo_ht;
	out_mat.nrm_rg = normal_rg;
#if defined(ADJUST_AORMS_ENABLED)
	out_mat.mod_aorms = vec4(
		mix(_ao_adjusts.x, _ao_adjusts.y, out_mat.blend),
		mix(spec_adjusts.x, spec_adjusts.y, out_mat.blend),
		0.,
		0. );
#endif
	return; }

#if defined(__T3D_STANDARD_TEXTURING__)
	#include "res://addons/terrain_3d/shader/core/t3d_deliver_mixed_mat_funcs.gdshaderinc"
#endif
//
// ########################################################################################
//
//  _____________
//_/  FRAGMENT   \____________________________________________________
//                                                                    :
void fragment() {
//
// ** STANDARD INIT **
// Unpacks UVs, calculate pixel world pos, and initialize the "__best" outputs
#include "res://addons/terrain_3d/shader/fragment/t3d_fragment_init.gdshaderinc"
//
// -------------------------------------------
//
// ** GET MIXED MATERIALS **
// Mixes the base and over layer materials and provides the output in a mat4 named "mixed_mat"
#if defined(__T3D_STANDARD_TEXTURING__)
	#include "res://addons/terrain_3d/shader/core/t3d_deliver_mixed_mat_inline.gdshaderinc"
#else
	// Do nothing?  Solid color fills?
#endif
//
// -------------------------------------------
//


	// Determine if we're in a region or not (region_uv.z>0)
	vec3 region_uv = get_region_uv2(uv2);
	
	// Colormap. 1 lookup
	vec4 color_map = vec4(1., 1., 1., .5);
	if (region_uv.z >= 0.) {
		float lod = textureQueryLod(_color_maps, uv2.xy).y;
		color_map = textureLod(_color_maps, region_uv, lod); }

	// Macro variation. 2 Lookups

	#if defined(FRAG_SAMPLE_TINT_NOISE)
	vec3 _PS = P_TINT_NZ_SCL ();
	vec3 _PO = P_TINT_NZ_OFFS ();
		vec4 _ng1 = RTX_GRAD * _noise_tint_noise1_scale * .1;
		float __tint_noise1 = textureGrad(noise_texture, rotate(uv*_PS.x*.1, cos(_PO.z), sin(_PO.z)) + _PO.xy, _ng1.xy, _ng1.zw).r;
		vec4 _ng2 = RTX_GRAD * _noise_tint_noise2_scale * .1;
		float __tint_noise2 = textureGrad(noise_texture, uv*_PS.y*.1, _ng2.xy, _ng2.zw).r;
		__best_noise.yz = vec2(__tint_noise1, __tint_noise2);
	#else
		float __tint_noise1 = v_noise.y;
		float __tint_noise2 = v_noise.z;
	#endif
	#if defined(FRAG_SAMPLE_GRADIENTS) || defined(FRAG_SAMPLE_VEGETATION)
		#if !defined(ALREADY_CALCULATED_PIXELPOS)
			#define ALREADY_CALCULATED_PIXELPOS
			__best_pixelpos = ( INV_VIEW_MATRIX * vec4(VERTEX,1.0) ).xyz;
		#endif
		__best_elevmarks = get_elevmark_metrics(__best_pixelpos.y);
		vec4 __pixel_gradients = vec4( get_local_gradient_periods( __best_elevmarks, __best_noise), 0.);
	#endif
	#if defined(FRAG_SAMPLE_VEGETATION)
		float _veg_mix = clamp((v_role -2.0)/2.0,0., 1.); 
		__best_veg = get_veg_response(v_role, __best_elevmarks.z, __pixel_gradients.z, __best_noise.z);//clamp(( _gradSamp_h.a * _veg_mix ) * 2.0, 0., 1.);
		float _visible_veg_response = mix ( 0.5, max(0., __best_veg*2.), _veg_mix)*2.;
		__pixel_gradients.w = _visible_veg_response;
	#endif
	#define __T3D_TINT_NOISE_AVAILABLE__
	vec2 clampedTints = clamp(vec2(__tint_noise1, __tint_noise2) + (__best_camdist*0.0002), vec2(0.), vec2(1.));
	vec3 macrov = mix(_noise_tint_macro_variation1, vec3(1.), clampedTints.x);
	macrov *= mix(_noise_tint_macro_variation2, vec3(1.), clampedTints.y);

	mixed_mat[MXD_TINT].rgb = color_map.rgb * macrov;
	
	// Wetness/roughness modifier, converting 0-1 range to -1 to 1 range
	float roughness = fma(color_map.a-0.5, 2.0, mixed_mat[MXD_NORMAL].a);

	// Apply PBR
	ALBEDO = mixed_mat[MXD_ALBEDO].rgb * mixed_mat[MXD_TINT].rgb;
	ROUGHNESS = roughness;
	SPECULAR = 1.-mixed_mat[MXD_NORMAL].a;
	NORMAL_MAP = mixed_mat[MXD_NORMAL].rgb;
	NORMAL_MAP_DEPTH = 1.0;

// --------------------
// ** APPLY OVERLAYS **
	#include "res://addons/terrain_3d/shader/fragment/t3d_fragment_apply_mods.gdshaderinc"
// --------------------

}

)"