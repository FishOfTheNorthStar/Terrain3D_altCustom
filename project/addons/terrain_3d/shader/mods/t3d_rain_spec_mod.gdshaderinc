#if !defined(__T3D_RAIN_SPEC_MOD__)
#define __T3D_RAIN_SPEC_MOD__

void get_rain_spec_mod_effects( vec3 __vertex, float __nm_flatness, float __role, vec3 exnoise, inout mat4 _OI_ ) {

//	_OI_ (Overlay Input) Key:
//	vec3 __albedo			= _OI_[0].rgb;
//	vec3 __normal_map		= _OI_[1].rgb;
//	vec3 __emission			= _OI_[2].rgb;
//	vec3 __r_m_s 			= _OI_[3].xyz; // roughness/metallic/specular components
//	float __ao_light_affect	= _OI_[3].w;
//	float __ao				= _OI_[2].w;

	float _rain = 0.;
		#if defined(RAIN_PUDDLES_ENABLED)
			float _puddle_size = 0.015;
		#endif
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		_rain = _rain_current_level;
		_rain *= v_noise.x*0.25+0.75;
		#if defined(RAIN_PUDDLES_ENABLED)
			_puddle_size = _rain_puddles_size;
		#endif
	#endif

	_rain = pow(_rain,0.35);
	float _flatness	= clamp( (__role/4.0), 0.2, 1. );
	float _flatten_normal_map = max( pow(clamp(_flatness - _OI_[2].w + _rain, 0., 1.), 1.3), pow(1.0-__nm_flatness, 1.3) ) * _rain;

	float _var_goal_flatten_normal = _flatten_normal_map * 0.65;
	vec3 _var_goal_albedo = _OI_[0].rgb * 0.75;
	vec3 _var_goal_rms = 
		vec3(	0.05+(_OI_[3].x*0.15),
				(_OI_[3].y*0.75)+0.25,
				clamp( pow( _OI_[3].z, 2.20 ),0.,1.) );

	#if defined(RAIN_PUDDLES_ENABLED)
		float _puddle_flat_check_rain_offset = (_puddle_size * pow(_rain,1.5))+0.0001;
		float _puddle_flatness_test_pass = clamp((_flatness - 1. + _puddle_flat_check_rain_offset ) * 100.0, 0., 1.);
		float _puddle_noise_test_pass = abs(exnoise.x ) * clamp( pow(abs(fract(exnoise.x*2.5* exnoise.y)*2.0-1.0), 0.5), 0., 1.);
		float _expuddle_amp = clamp(3.0 * _puddle_noise_test_pass * _puddle_flatness_test_pass, 0., 1.);
		_flatten_normal_map = clamp(_flatten_normal_map + _expuddle_amp, 0., 1.);
		_var_goal_flatten_normal	= mix(_var_goal_flatten_normal, _flatten_normal_map, _expuddle_amp);
		_var_goal_albedo			= mix(_var_goal_albedo, clamp(_OI_[0].rgb*0.2,vec3(0.), vec3(1.)), _expuddle_amp);
		_var_goal_rms				= mix( _var_goal_rms,
			vec3(	0.01+(_OI_[3].x*0.01),
					(_OI_[3].y*0.05)+0.95,
					clamp( pow( _OI_[3].z+0.01, 0.120 ),0.,1.) ),_expuddle_amp );
	#endif
			
	_OI_[0].rgb	= mix(_OI_[0].rgb,	_var_goal_albedo,			_rain);						// Albedo
	_OI_[1].rgb	= mix(_OI_[1].rgb,	vec3( 0.5, 0.5, 1.0 ),		_var_goal_flatten_normal);	// Texture Normal
	_OI_[3].xyz	= mix(_OI_[3].xyz,	_var_goal_rms, 				_flatten_normal_map ); 		// Roughness/Metallic/Specular
	return; }
#endif
