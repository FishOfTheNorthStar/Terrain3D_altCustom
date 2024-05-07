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
// BEGIN FRAGMENT INIT 
// --------------------------------------------------------------------------------------

	vec3 __best_noise = v_noise;
	vec4 __best_gradients = v_gradients;
	vec4 __best_elevmarks = v_elevmarks;
	vec3 __best_pixelpos = v_vertex;
	float __best_veg = v_veg;
	float __best_camdist = 100.;

	#if !defined(ALREADY_CALCULATED_PIXELPOS)
		#define ALREADY_CALCULATED_PIXELPOS
		__best_pixelpos = ( INV_VIEW_MATRIX * vec4(VERTEX,1.0) ).xyz;
		__best_camdist = length(__best_pixelpos - CAMERA_POSITION_WORLD);
	#endif

	// Recover UVs
	vec2 uv = UV + v_uv_offset;
	vec2 uv2 = UV2 + v_uv2_offset;
	
	// Calculate derivatives from UV2 (world space in normalized tile units)
	// Pass this along to samplers as the explicit derivative.
	const float TXLOD_SCALE = 2.0; // to-do: make this a material parameter
	vec4 WORLD_GRAD = get_grad(uv2) / TXLOD_SCALE;
	vec4 RTX_GRAD = get_grad(uv) / TXLOD_SCALE;

	// Calculate Terrain Normals.
	mat3 mVM = mat3(VIEW_MATRIX);
	NORMAL = mVM * v_normal;
	TANGENT = mVM * v_tangent;
	BINORMAL = mVM * v_binormal;

	
// --------------------------------------------------------------------------------------
// END FRAGMENT INIT 
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
}
#endif