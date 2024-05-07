// *****************************************************************************
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// REQUIRED EXTERNAL TYPES:
// "Material" (struct): Provided by
// #include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"
// *****************************************************************************
// REQUIRED EXTERNAL FUNCTIONS:
//
// "get_materials"
//Material[4] get_materials( vec2 _uv, vec4 _g, uvec4 _c, ivec4 _n, vec4 _a) { Material _m[4]; return _m; }	//defined within "res://addons/terrain_3d/shader/core/t3d_deliver_mixed_mat_funcs.gdshaderinc"
//
// "P_TINT_NZ_SCL" -> vec3
//vec3 P_TINT_NZ_SCL() { return vec3(0.); } 	// Provides the tint noise scales.  This code uses the Z index for tint noise 3
//
// "blend_weights_x4" -> vec4 : Defined with t3d_standard_functions
//vec4 blend_weights_x4(vec4 _p1, vec4 _p2) { return vec4(0.); }
// *****************************************************************************
// REQUIRED EXTERNAL SAMPLERS:
//uniform sampler2D noise_texture;
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
//	const vec2 uv 			= vec2(0.);
//	const vec4 RTX_GRAD 	= vec4(0.);
//	
//	const uvec4	v_control 	= uvec4(0);
//	const ivec4	v_neighbors	= ivec4(0);
//	const vec4 	v_rangles 	= vec4(0.);
// *****************************************************************************
#endif

#ifdef AUTO_SHADER_ENABLED
// AUTO_SHADER_TEXTURE_ID
ivec2 GET_MAT_IDS_AND_BLEND(uint control, int region, vec3 normal, out float _blend) { 
	// Enable Autoshader if outside regions or painted in regions, otherwise manual painted
	bool auto_shader = region<0 || bool(control & 0x1u);
	_blend = float(auto_shader)*clamp(
			dot(vec3(0., 1., 0.), normal * _auto_shader_slope*2. - (_auto_shader_slope*2.-1.)) 
			- _auto_shader_height_reduction*.01*v_vertex.y // Reduce as vertices get higher
			, 0., 1.) + 
			 float(!auto_shader)*float(control >>14u & 0xFFu) * 0.003921568627450; // 1./255.0		
	return ivec2(
		int(auto_shader)*_auto_shader_base_texture + int(!auto_shader)*int(control >>27u & 0x1Fu),			// out_mat.base
		int(auto_shader)*_auto_shader_overlay_texture + int(!auto_shader)*int(control >> 22u & 0x1Fu) ); }	// out_mat.over 
#else
// TEXTURE_ID
ivec2 GET_MAT_IDS_AND_BLEND(uint control, int region, vec3 normal, out float _blend) { 
	_blend = float(control >>14u & 0xFFu) * 0.003921568627450; // 1./255.0
	return ivec2(
		int(control >>27u & 0x1Fu),		// out_mat.base 
		int(control >>22u & 0x1Fu) ); }	// out_mat.over  
#endif
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) 
}
#endif