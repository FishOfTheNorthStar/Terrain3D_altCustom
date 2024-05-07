// *****************************************************************************
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// REQUIRED EXTERNAL TYPES:
// "Material" (struct): Provided by
#include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"
// *****************************************************************************
// REQUIRED EXTERNAL FUNCTIONS:
//
// "get_materials"
Material[4] get_materials( vec2 _uv, vec4 _g, uvec4 _c, ivec4 _n, vec4 _a) { Material _m[4]; return _m; }	//defined within "res://addons/terrain_3d/shader/core/t3d_deliver_mixed_mat_funcs.gdshaderinc"
//
// "P_TINT_NZ_SCL" -> vec3
vec3 P_TINT_NZ_SCL() { return vec3(0.); } 	// Provides the tint noise scales.  This code uses the Z index for tint noise 3
//
// "blend_weights_x4" -> vec4 : Defined with t3d_standard_functions
vec4 blend_weights_x4(vec4 _p1, vec4 _p2) { return vec4(0.); }
// *****************************************************************************
// REQUIRED EXTERNAL SAMPLERS:
uniform sampler2D noise_texture;
// *****************************************************************************
// REQUIRED EXTERNAL LOCAL/INLINE INPUTS:
// "uv" (vec2)
// "RTX_GRAD" (vec4): The world space texture derivatives, xy is dFdX() and zw is dFdY()
// *****************************************************************************
// REQUIRED EXTERNAL VARYINGS:
// "v_control" flat uvec4: The control data for this texel and it's Right/Down and Right+Down neighbors
// "v_neighbors" flat ivec4
// "v_rangles" flat vec4: The random texture angle of this texl and it's neighbors
// *****************************************************************************
void __null_wrapper() {
	const vec2 uv 			= vec2(0.);
	const vec4 RTX_GRAD 	= vec4(0.);
	
	const uvec4	v_control 	= uvec4(0);
	const ivec4	v_neighbors	= ivec4(0);
	const vec4 	v_rangles 	= vec4(0.);
// *****************************************************************************
#endif

	const uint MXD_ALBEDO	= 0u;
	const uint MXD_NORMAL	= 1u;
	const uint MXD_ADJUST	= 2u;
	const uint MXD_TINT		= 3u;	// Note: This mixed_mat entry is not supplied in this code block

	// Identify 4 vertices surrounding this pixel
	vec2 texel_pos = uv;
	highp vec2 texel_pos_floor = floor(uv);

	// Create a cross hatch grid of alternating 0/1 horizontal and vertical stripes 1 unit wide in XY 
	vec4 mirror = vec4(fract(texel_pos_floor * 0.5) * 2.0, 1.0, 1.0);
	// And the opposite grid in ZW
	mirror.zw = vec2(1.0) - mirror.xy;

	// Get the textures for each vertex. 16-24 lookups (4-6 ea)
	// (!!!) "mat[]" EXTERNAL REF -> Debug View: DEBUG_CONTROL_TEXTURE
	Material mat[4];// = get_materials(uv, RTX_GRAD, v_control, v_neighbors, v_rangles);
	get_material(uv, RTX_GRAD, v_control.x, v_neighbors.x, v_rangles.x, mat[0]);
	get_material(uv, RTX_GRAD, v_control.y, v_neighbors.y, v_rangles.y, mat[1]);
	get_material(uv, RTX_GRAD, v_control.z, v_neighbors.z, v_rangles.z, mat[2]);
	get_material(uv, RTX_GRAD, v_control.w, v_neighbors.w, v_rangles.w, mat[3]);

	// Calculate weight for the pixel position between the vertices
	// Bilinear interpolation of difference of uv and floor(uv)
	vec2 weights1 = clamp(texel_pos - texel_pos_floor, 0, 1);
	weights1 = mix(weights1, vec2(1.0) - weights1, mirror.xy);
	vec2 weights0 = vec2(1.0) - weights1;
	
	// Adjust final weights by texture's height/depth + noise. 1 lookup
	float __nz3_sc = P_TINT_NZ_SCL().z;
	vec4 n3grad = RTX_GRAD * __nz3_sc;
	float noise3 = textureGrad(noise_texture, uv*__nz3_sc, n3grad.xy, n3grad.zw).r;

	vec2 _w01y = vec2(weights0.y, weights1.y);
	// (!!!) "weights" EXTERNAL REF -> Debug View: DEBUG_CONTROL_TEXTURE
	vec4 weights = blend_weights_x4(
		vec4( (weights0.x * _w01y), (weights1.x * _w01y) ), 
		clamp ( vec4 ( 
			mat[0].alb_ht.a, 
			mat[1].alb_ht.a, 
			mat[2].alb_ht.a, 
			mat[3].alb_ht.a ) + noise3, vec4(0.), vec4(1.)) );

	// (!!!) "weight_inv" EXTERNAL REF -> Debug View: DEBUG_CONTROL_TEXTURE
	float weight_inv = 1.0 / (weights.x + weights.y + weights.z + weights.w);
	
	const vec4 _Z4 = vec4(0.);
	vec4 _W = weights;

	vec4 _mixed_alb = mat4(mat[0].alb_ht, mat[1].alb_ht, mat[2].alb_ht, mat[3].alb_ht)* _W;
	vec4 _mixed_nrm = mat4(mat[0].nrm_rg, mat[1].nrm_rg, mat[2].nrm_rg, mat[3].nrm_rg)* _W;
#if !defined(ADJUST_AORMS_ENABLED)
	mat4 mixed_mat = mat4 ( _mixed_alb, _mixed_nrm, _Z4, _Z4 );
#else 
	vec4 _mixed_adj = mat4(mat[0].mod_aorms, mat[1].mod_aorms, mat[2].mod_aorms, mat[3].mod_aorms)* _W;
	mat4 mixed_mat = mat4 ( _mixed_alb, _mixed_nrm, _mixed_adj, _Z4 );
#endif

	mixed_mat = weight_inv * mixed_mat;

	// Weighted average of albedo & height  // Depreciated, just access mixed_mat directly
	//vec4 albedo_height =  mixed_mat[MXD_ALBEDO];

	// Weighted average of normal & rough   // Depreciated, just access mixed_mat directly
	//vec4 normal_rough = mixed_mat[MXD_NORMAL];


	
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) 
}
#endif