// READS FROM AND DELIVERS:
//	vec4 albedo_ht2 //  normal_rg2;
// *****************************************************************************
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// #define MULTI_SCALING_ENABLED;  // For testing purposes this can be uncommented
//
// REQUIRED EXTERNAL TYPES:
// "Material" (struct): Provided by
#include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"
// *****************************************************************************
// REQUIRED EXTERNAL FUNCTIONS:
// "get_materials"
Material[4] get_materials( vec2 _uv, vec4 _g, uvec4 _c, ivec4 _n, vec4 _a) { Material _m[4]; return _m; }	//defined within "res://addons/terrain_3d/shader/core/t3d_deliver_mixed_mat_funcs.gdshaderinc"
// *****************************************************************************
void __null_wrapper() {
	Material out_mat;
	const float v_far_factor = 0.;
	const int _multi_scale_texture = 0;
	const vec4 albedo_far 	= vec4(0.);
	const vec4 normal_far 	= vec4(0.);
// READS FROM AND MAKES LOCALCHANGES TO:
	vec4 albedo_ht2;
	vec4 normal_rg2;
// *****************************************************************************
#endif
#ifdef MULTI_SCALING_ENABLED
	// If multi scaling, apply to overlay texture
	float _vff = v_far_factor * float(1-abs(min(1,out_mat.over - _multi_scale_texture)));
	albedo_ht2 = mix(albedo_ht2, albedo_far, _vff);
	normal_rg2 = mix(normal_rg2, normal_far, _vff);
#endif
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) 
}
#endif