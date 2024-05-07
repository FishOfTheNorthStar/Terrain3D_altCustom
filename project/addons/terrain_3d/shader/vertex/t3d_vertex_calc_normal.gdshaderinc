// --------------------------------------------------------------------------------------
// * Placeholder function / variable defs to appease syntax highlighter in Godot:
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// * External samplers:
// uniform usampler2DArray _control_maps	: repeat_disable;
// * External calls:
// vec2 UV_DISTORT_IF_ENABLED() {return vec2(0.);}
// ivec3 get_region_uv(vec2 _param) {return ivec3(0u);}
//
void placeholder_func_CALC_NORMALS() {
// * Godot supplied externals:
// const mat4 INV_VIEW_MATRIX = mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.));
// const mat4 MODEL_MATRIX = mat4(vec4(0.),vec4(0.),vec4(0.),vec4(0.));
// In this code portion, VERTEX should not be written to yet, so it's constant here.
//const vec3 VERTEX = vec3(0.);

// * External parameters:
//const float _mesh_vertex_density = 1.;
//const float _region_size = 1.;
//const float _region_texel_size = 1.;

// * Local changes to:
//float	v_height;
//vec2	UV, v_uvdistort;
//ivec3	v_region;
//vec3	v_camera_pos, v_vertex, v_norm_region, v_noise, v_normal;
#endif
// --------------------------------------------------------------------------------------
// *** BEGIN: CALC_NORMAL_IN_VERTEX 
// --------------------------------------------------------------------------------------
	const vec4 zro = vec4(0);

	// By caching this value into the x and y but not z values of this vec3, _step.xz is a left right movement, and _step.yz is an up down movement, and more of the operations involved can be done in vector sized batchs.
	vec3 _step = vec3(1.,1.,0.) * _region_texel_size;  

	// The half texel step is used to offset the samples below to be center pixel
	vec3 half_step = _step *.5;

	// The total valid range for this (and all) regions is the full width / height minus one texel
	float _valid = 1. - _step.x;

	// This temp variable holds that slightly inset UV that increments up to "_valid" range above, 
	// as opposed to incrementing up to 1.0 as the standard v_norm_region does.
	vec3 t_norm = v_norm_region;
	t_norm.xy *= _valid;

	// UV coordinates in region space + texel offset. Values are 0 to 1 within regions
	UV2 = UV * _step.x;
	// ----
	// The vertex is sampled against the actual unmodified position

	vec4 _vertH = mix(zro, textureGather(_height_maps, v_norm_region + half_step, 0), _FRV);
	// * Temp variable name '_vertH' is short for "VertexGatherHeight" here.
	// ----
	// ... however the normal is sampled against a very slighly modified version that stetches 
	// the UV just enough to 'lose' one pixel from each region, to hide the normal error line 
	// at the edge between regions.

	vec4 _normH = mix(zro, textureGather(_height_maps, t_norm + half_step, 0), _FRV);
	// * Temp variable name '_normH' is short for "NormalGatherHeight" here.

#if defined(WORLD_NOISE_ENABLED)
	// If world noise is available, apply it to this vertex height and calc it's 3 textureGather 
	// neighbors noise height offsets too for normal calculation.

	// Either noise type uses the same octaves setting
	int _octaves = get_noise_octaves_by_distance(length(v_vertex.xz - v_camera_pos.xz));

	// World Noise 1 = Standard Terrain3D noise
	#if defined(WORLD_NOISE_MODE_1)
		float _tch; 
		//v_noise = vec3(noise_mod(_octaves, 1.0,UV2*200.)-1.0);
		_tch=noise_mod(_octaves, _normH.w,UV2)-_normH.w;_normH.w+=_tch;_vertH.w+=_tch;
		_tch=noise_mod(_octaves, _normH.z,UV2+_step.xz)-_normH.z;_normH.z+=_tch;_vertH.z+=_tch;
		_tch=noise_mod(_octaves, _normH.x,UV2+_step.zy)-_normH.x;_normH.x+=_tch;_vertH.x+=_tch;

	// World Noise 2 = FastNoiseLite
	#elif defined(WORLD_NOISE_MODE_2)
		fnl_state t_noise = __INIT_FNL(_octaves);
		//v_noise = __SAMPLE_FNL3(t_noise, v_vertex.xz, vec3(0.25, 0.82, 2.41));
		vec4 nz4 = __SAMPLE_FNL2x2(t_noise, v_vertex.xz + _world_noise_offset.xz, vec2(1.), 2.41 * _world_noise_scale );
	    nz4 = (nz4 *_world_noise_height*25.);
		_normH += nz4;
	    nz4 += _world_noise_offset.y*100.;
		_vertH += nz4;
	#endif
#endif

	v_normal = normalize(vec3(_normH.w - _normH.z, _mesh_vertex_spacing, _normH.w - _normH.x));
	v_tangent = cross(v_normal, vec3(0, 0, 1));
	v_binormal = cross(v_normal, v_tangent);

	v_role = get_role_from_world_normal( v_normal );

// --------------------------------------------------------------------------------------
// *** END: CALC_NORMAL_IN_VERTEX 
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
}
#endif