// --------------------------------------------------------------------------------------
// * Placeholder function / variable defs to appease syntax highlighter in Godot:
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// * External samplers:
uniform usampler2DArray _control_maps	: repeat_disable;
// * External calls:
vec2 UV_DISTORT_IF_ENABLED() {return vec2(0.);}
ivec3 get_region_uv(vec2 _param) {return ivec3(0u);}
//
void placeholder_func_INIT_VARYINGS() {
// * Godot supplied externals:
const mat4 INV_VIEW_MATRIX = mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.));
const mat4 MODEL_MATRIX = mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.));
// In this code portion, VERTEX should not be written to yet, so it's constant here.
const vec3 VERTEX = vec3(0.);

// * External parameters:
const float _mesh_vertex_density = 1.;
const float _region_size = 1.;
const float _region_texel_size = 1.;

// * Local changes to:
float	v_height;
vec2	UV, v_uvdistort;
ivec3	v_region;
vec3	v_camera_pos, v_vertex, v_norm_region, v_noise, v_normal;
#endif
// --------------------------------------------------------------------------------------
// BEGIN INIT STANDARD VARYINGS
// --------------------------------------------------------------------------------------
	// Get camera pos in world coords
    v_camera_pos = INV_VIEW_MATRIX[3].xyz;

	// Get vertex of flat plane in world coordinates and set world UV
	v_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_height = v_vertex.y;

	// UV coordinates in world space. Values are 0 to _region_size within regions
	vec2 _fUV = v_vertex.xz * _mesh_vertex_density;

	UV = round(_fUV);
	v_norm_region.xy = mod(UV, _region_size) * _region_texel_size;
	v_region = get_region_uv(UV);
	v_norm_region.z = float(v_region.z);

#if defined(UV_DISTORTION_ENABLED)
	v_uvdistort = UV_DISTORT_IF_ENABLED(_fUV);
#endif
	v_noise = vec3(1.0);
	v_normal = vec3(0.,1.,0.);

	// This lookup is re-used later during vertex normal calculation
	uint _CONTROL = texelFetch(_control_maps, v_region, 0).r;
	
// --------------------------------------------------------------------------------------
// END INIT STANDARD VARYINGS
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
}
#endif