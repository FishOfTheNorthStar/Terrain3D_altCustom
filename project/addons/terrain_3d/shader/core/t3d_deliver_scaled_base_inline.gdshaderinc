// *****************************************************************************
// DELIVERS:
// vec4 albedo_ht / normal_rg;
// *****************************************************************************
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// #define MULTI_SCALING_ENABLED;  // For testing purposes this can be uncommented
// EXTERNAL SAMPLERS:
uniform sampler2DArray _texture_array_albedo : source_color, filter_nearest_mipmap_anisotropic, repeat_enable;
uniform sampler2DArray _texture_array_normal : hint_normal, filter_nearest_mipmap_anisotropic, repeat_enable;
// REQUIRED EXTERNAL TYPES:
// "Material" (struct): Provided by
#include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"
// *****************************************************************************
void __null_wrapper() {
	Material out_mat;
	const int region = 0;
	const float _multi_scale_macro_size = 0.;
	const float _multi_scale_micro_size = 0.;
	const int _multi_scale_texture = 0;
	const float v_far_factor = 0.;
	
// MAKES LOCALCHANGES TO:
	vec2 matUV;
	vec4 uv1_grad;
	vec4 albedo_ht;
	vec4 normal_rg;
	vec4 albedo_far;
	vec4 normal_far;
#endif
// *****************************************************************************
#ifdef MULTI_SCALING_ENABLED
	// MULTI_SCALING_BASE
	// If dual scaling, apply to base texture
	if(region < 0) {
		matUV *= _multi_scale_macro_size;
		uv1_grad *= _multi_scale_macro_size; }
	vec3 matUVW1 = vec3(matUV, float(out_mat.base));
	albedo_ht = textureGrad(_texture_array_albedo, matUVW1, uv1_grad.xy, uv1_grad.zw);
	normal_rg = textureGrad(_texture_array_normal, matUVW1, uv1_grad.xy, uv1_grad.zw);
	if(out_mat.base == _multi_scale_texture || out_mat.over == _multi_scale_texture) {
		vec3 dmatUVW1 = vec3(matUV*_multi_scale_micro_size, float(_multi_scale_texture));
		vec4 duv1_grad = uv1_grad *_multi_scale_micro_size;
		albedo_far = textureGrad(_texture_array_albedo, dmatUVW1, duv1_grad.xy, duv1_grad.zw);
		normal_far = textureGrad(_texture_array_normal, dmatUVW1, duv1_grad.xy, duv1_grad.zw);  }
	if(out_mat.base == _multi_scale_texture) {
		albedo_ht = mix(albedo_ht, albedo_far, v_far_factor);
		normal_rg = mix(normal_rg, normal_far, v_far_factor); } 
#else
// UNI_SCALING_BASE
	albedo_ht = textureGrad(_texture_array_albedo, vec3(matUV, float(out_mat.base)), uv1_grad.xy, uv1_grad.zw);
	normal_rg = textureGrad(_texture_array_normal, vec3(matUV, float(out_mat.base)), uv1_grad.xy, uv1_grad.zw);
#endif
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) 
}
#endif