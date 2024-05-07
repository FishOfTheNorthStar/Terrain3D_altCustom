#if !defined(__T3D_GRADIENTS__)
#define __T3D_GRADIENTS__
#define STRATA_GRADIENT_ENABLED_SUPPORT

const int _GRAD_DATA_LEN = 43;

const int TEST_GRAD_WINDOW_OFFSET = 0;
const int TEST_GRAD_WINDOW_COUNT = 8;
const int TEST_NORM_WINDOW_OFFSET = 8;
const int TEST_NORM_WINDOW_COUNT = 1;
const int COASTAL_WINDOW_OFFSET = 9;
const int COASTAL_WINDOW_COUNT = 1;

const vec4[_GRAD_DATA_LEN] TEST_GRAD_COLORS = {
vec4( 0.2854815, 0.2786366, 0.2557304, 0.0165 ),
vec4( 0.52393, 0.554962, 0.431105, 0.55 ),
vec4( 0.52393, 0.554962, 0.431105, 0.85 ),
vec4( 0.72, 0.60192, 0.4248, 0.25 ),
vec4( 1., 0.985, 0.7, 0.35 ),
vec4( 0.6, 0.6848, 0.568, 0.625 ),
vec4( 0.449237, 0.472517, 0.409896, 0.75 ),
vec4( 0.501828, 0.492807, 0.347508, 0.85 ),
vec4( 0.1312416, 0.1340626, 0.133792, 0.01 ),
vec4( 0.30297, 0.321987, 0.273123, 0.9 ),
vec4( 0.646057, 0.569328, 0.491916, 1. ),
vec4( 0.3217443, 0.2482282, 0.2073914, 0.57 ),
vec4( 0.0596259, 0.0416335, 0.0218797, 0.90137 ),
vec4( 0.678981, 0.516589, 0.431332, 0.34 ),
vec4( 0.83843, 0.63584, 0.476065, 1. ),
vec4( 1.0, 0.8567344, 0.92304, 0.15 ),
vec4( 0.82, 0.70192, 0.5248, 0.9 ),
vec4( 0.2564323, 0.19531793, 0.12385168, 0.17 ),
vec4( 0.830987, 0.615895, 0.438144, 0.8 ),
vec4( 0.856008, 0.713562, 0.589941, 1. ),
vec4( 0.196, 0.17872, 0.10528, 0.135 ),
vec4( 0.540448, 0.524066, 0.434087, 0.75 ),
vec4( 0.792157, 0.670588, 0.498039, 1. ),
vec4( 0.54369, 0.43421, 0.282027, 0.73 ),
vec4( 0.443975, 0.2609797, 0.0441082, 1. ),
vec4( 0.800305, 0.65918, 0.485817, 1. ),
vec4( 0.831373, 0.615686, 0.439216, 0.8 ),
vec4( 0.802576, 0.656002, 0.482411, 1. ),
vec4( 0.898039, 0.784314, 0.466667, 1. ),
vec4( 0.805077, 0.690615, 0.435805, 0.71 ),
vec4( 0.668368, 0.552822, 0.39042, 1. ),

vec4(   0.501828, 0.692807, 0.347508, 1.0 ),
vec4(  0.501828, 0.692807, 0.347508, 0.9 ),
vec4( 0.564323, 20.9531793, 0.2385168, 0.6),
vec4( 0.312416, 0.340626, 0.33792,0.2 ),
vec4( 0.312416, 0.540626, 0.33792, 0.0 ),
vec4( 0.21, 0., 0.26, 0.0 ),

vec4( vec3(0.501828, 0.692807, 0.347508)*0.25, 1.0 ),
vec4( vec3(238./255., 233./255., 98./255.)*0.5, 1.0 ),
vec4( vec3(238./255., 233./255., 98./255.)*0.75, 1.0 ),
vec4( vec3(0.342416, 0.320626, 0.23792)*1.,0.8 ),
vec4( vec3(0.312416, 0.340626, 0.33792)*0.015, 0.4 ),
vec4( 0.07, 0.09, 0.21, 0.0 )
};
const ivec2[] TEST_GRAD_WINDOWS = {
	ivec2(0,3),
	ivec2(2,8),
	ivec2(7,11),
	ivec2(10,17),
	ivec2(16,22),
	ivec2(21,25),
	ivec2(24,29),
	ivec2(28,30),
	ivec2(31,36),
	ivec2(37,42)
	};
	
const float[_GRAD_DATA_LEN] TEST_GRAD_OFFSETS = {
	0.0, 
	0.0594262, 
	0.0819672, 
	0.135295, 
	0.137295, 
	0.162651, 
	0.212851, 
	0.237705, 
	0.266393, 
	0.293033, 
	0.327869, 
	0.381148, 
	0.391393, 
	0.407787, 
	0.453815, 
	0.467213, 
	0.485656, 
	0.55123, 
	0.561475, 
	0.586066, 
	0.60041, 
	0.614943, 
	0.645594, 
	0.67418, 
	0.680328, 
	0.756148, 
	0.770492, 
	0.85041, 
	0.866803, 
	0.938525, 
	1. ,
	
	0.0, 
	0.25, 
	0.52, 
	0.53, 
	0.92, 
	1. ,
	
	0.0, 
	0.42, 
	0.5, 
	0.67, 
	0.88, 
	1. 
	
	};

const vec2 __GRAD_DOT5 = vec2(0.5);
vec4 SAMPLE_GRAD(int _grad_offset, int _grad_len, float _u) {
	vec4 resp = vec4(0.);
	ivec2 _window = TEST_GRAD_WINDOWS[_grad_offset + clamp(int(_u*float(_grad_len)),0, _grad_len-1)];
	vec2 _offs;
	ivec2 _valid;
	
	for (int _i = _window.x; _i <_window.y; _i++) {
		_offs = vec2(TEST_GRAD_OFFSETS[_i], TEST_GRAD_OFFSETS[_i+1]);
		_valid = ivec2(fma(sign( vec2(_u-_offs.x, _offs.y-_u) ), __GRAD_DOT5, __GRAD_DOT5) );
		resp += mix( TEST_GRAD_COLORS[_i], TEST_GRAD_COLORS[_i+1], 
			( _u - _offs.x ) / ( _offs.y - _offs.x ) ) 
			* float(_valid.x * _valid.y); }
	return resp; }
	

vec3 get_local_gradient_periods(vec4 _elevmarks, vec3 _noise) {
	float _heightU = fract( (_elevmarks.z / 100.0)- clamp(_noise.x * 0.14, -0.05, 0.05) );
	vec3 _scaleNoise = abs(_noise).yyz * vec3(0.35, 0.2,0.1);//vec3(1.15, 0.15, 0.05);
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) && defined(STRATA_GRADIENT_ENABLED)
		return fract(fma(vec3(_heightU), vec3(
			_strata_gradient_vertical_surface_scale,
			_strata_gradient_flat_surface_scale,
			_strata_gradient_flat_surface_scale), vec3( _scaleNoise.y + _scaleNoise.z, _scaleNoise.x, _scaleNoise.x ) ) ); 
	#else 
		return vec3(0.);
	#endif
	}


float get_veg_response(float _role, float _height_from_sealevel, float _veg_grad_cycle, float _noise_mod) {
	float _noise_submod = 1.-abs((fract(_noise_mod * 1.0)-0.5)*2.0);
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)  && defined(VEGETATION_ENABLED)
		float _crop_submod =pow(clamp(_noise_submod*2.0-(_vegetation_size), 0., 1.), 0.2);
	#else
		const float _crop_submod = 0.6;
	#endif
	float _shoreline_cancel = 1.-clamp(-((_height_from_sealevel  - 10.)/10.), 0., 1.);
	float _shoreline_shadow_inv_pow = 1.- (clamp((_height_from_sealevel / 10. ), 0., 1.) * 1.);
	_shoreline_shadow_inv_pow *= 1. - _shoreline_cancel;
	_shoreline_cancel = min(1., _shoreline_cancel + _shoreline_shadow_inv_pow);
	//_shoreline_cancel *= _shoreline_shadow_inv_pow;
	vec4 _gradSamp_h	= SAMPLE_GRAD(TEST_NORM_WINDOW_OFFSET, TEST_NORM_WINDOW_COUNT, _veg_grad_cycle);
	float _veg_mix = clamp((_role -2.0)/2.0,0., 1.); 
	return ( _gradSamp_h.a * _veg_mix * _crop_submod * _shoreline_cancel); }

float get_veg_height_from_response(float __veg_response) {
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__) && defined(VEGETATION_ENABLED) && defined(VEGETATION_RAISE_HEIGHT)
//		float _inset_effect_hump = -clamp((1.-abs(__veg_response-0.5 * 2.0))*2.0, -1., 0.);
//		return _inset_effect_hump * __veg_response * debug_veg_height; 
		return _vegetation_height * ( clamp(__veg_response-0.51 * (1.0/0.49), 0.,1.));
//		return clamp(__veg_response, 0.,1.) * debug_veg_height; 
	#else
		return 0.;
	#endif
	}

void get_strata_tint_effects( vec4 __periods, vec4 __elevmarks, float _veg_response, vec3 __vertex, float __nm_flatness, float __role, vec3 exnoise, inout mat4 _OI_ ) {

//	_OI_ (Overlay Input) Key:
//	vec3 __albedo			= _OI_[0].rgb;
//	vec3 __normal_map		= _OI_[1].rgb;
//	vec3 __emission			= _OI_[2].rgb;
//	vec3 __r_m_s 			= _OI_[3].xyz; // roughness/metallic/specular components
//	float __ao_light_affect	= _OI_[3].w;
//	float __ao				= _OI_[2].w;

	// These represent cycles-per-hundred units of elevation change
	float SPLITGRAD_SEALEVEL = 60.;
	float SPLITGRAD_SEAFLOOR = 10.;
	float SPLITGRAD_COASTHEIGHT = 5.;
	vec2 _hU_VH = __periods.xy;//vec2(0.);
	float _relSeaLevel;// = __vertex.y - SPLITGRAD_SEALEVEL;
	float _coastalResponse = __elevmarks.x;// = clamp(-(_relSeaLevel + SPLITGRAD_COASTHEIGHT)/ SPLITGRAD_COASTHEIGHT, 0., 1.);
	float _seaFloorResponse = __elevmarks.y;// = clamp(-_relSeaLevel/( SPLITGRAD_SEALEVEL - SPLITGRAD_SEAFLOOR), 0., 0.999);
	float _aboveWater = __elevmarks.w;
	float _underWater = 1. - _aboveWater;
//	_coastalResponse *= _aboveWater;
	//float _veg_response = 0.;
	float _pow_ifavail = 1.0;

	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		SPLITGRAD_SEALEVEL = debug_sealevel;
		SPLITGRAD_COASTHEIGHT = debug_shoreheight;
		SPLITGRAD_SEAFLOOR = debug_seafloor;
		float SPLITGRAD_VERT_POWER = _strata_gradient_vertical_power;
		float SPLITGRAD_FLAT_POWER = _strata_gradient_flat_power;
		float VEGETATION_SIZE = _vegetation_size;
	#else
		const float SPLITGRAD_VERT_POWER = 1.0;
		const float SPLITGRAD_FLAT_POWER = 1.0;
		const float VEGETATION_SIZE = 1.0;
	#endif

	float _hU_C = (_coastalResponse + _underWater + _seaFloorResponse)/2.0;
	float _scaleNoise = abs(exnoise).y * 0.15;

	vec4 _gradSamp_v	= SAMPLE_GRAD(TEST_GRAD_WINDOW_OFFSET, TEST_GRAD_WINDOW_COUNT, _hU_VH.x);
	vec4 _gradSamp_c	= SAMPLE_GRAD(COASTAL_WINDOW_OFFSET, COASTAL_WINDOW_COUNT, _hU_C);
	_gradSamp_v = mix(vec4(1.), _gradSamp_v, SPLITGRAD_VERT_POWER);
	//_gradSamp_c = mix(vec4(1.), _gradSamp_c, SPLITGRAD_FLAT_POWER);
	float _strataShine = clamp( 1.-_gradSamp_v.a,0.,1.); 
	_strataShine *= pow(__nm_flatness,1.5);
	_strataShine *= pow(_strataShine, 0.015 + _scaleNoise);

	float _gradmix_flat = clamp((__role/4.0), 0.,1.);
	float _horizontal_cancel = clamp((0.915 -_gradmix_flat)*100., 0., 1.);
	
	float _gradmix = pow(_gradmix_flat,1.5);
	float _i_gradmix = 1. - pow(_gradmix_flat, 0.9225);
	_strataShine = ( _i_gradmix) * _strataShine;
	_OI_[3].y = mix(_OI_[3].y, 1.0, _strataShine); 
	_OI_[3].x = mix(_OI_[3].x, _OI_[3].x*0.1, _strataShine); 

	float _vis_veg = min(1., __periods.w);
	float _veg_mix = clamp((__role -2.0)/2.0, 0., 1.); 
	//float _vertex_veg_response = _veg_response;
	//float _vis_veg_response = _vertex_veg_response;
	float _veg_shadow = (1.-pow(min(1.,_veg_response*2.0), 0.55))*0.75;
	_veg_shadow = clamp(_veg_shadow + (0.25*( 1.-clamp((_veg_response-0.5) * 3., 0., 1.))), 0., 1.);
	float _darken = pow(_veg_shadow * _veg_mix, 1.25);
	float _darken_scale = clamp(1.-(_darken*0.95), 0., 1.);
	float _veg_edge_glow = pow(clamp(4.0*(_veg_response - 0.75),0.,1.)*max(0., (_veg_response*2.0)-1.0), 0.75); 
	//_darken_scale = mix(_darken_scale*0.5, _darken_scale,  _horizontal_cancel);
	//_OI_[0].rgb *= _darken_scale;
	_OI_[2].w *= _darken_scale;
	//_OI_[3].w *= _darken_scale;
	vec3 _hdirt_color = 0.95 * mix ( 
		(vec3(215.,114.,49.) / 255.),
		(vec3(102.,86.,52.) / 255.), 0.5 );
	vec3 _veg_color = 0.75 * mix ( 
		(vec3(115.,214.,9.) / 255.),
		(vec3(82.,96.,52.) / 255.), 0.45 );
		//_veg_color.g = 0.;
		//_veg_color.r = 1.;
		//_gradSamp_v.rgb = vec3(1., 0., 1.);
	_OI_[2].rgb = mix(_OI_[2].rgb ,_OI_[2].rgb  + ( 0.125 * _veg_edge_glow * (vec3(115.,214.,9.) / 255.) ), _veg_edge_glow);//_veg_color;
	_OI_[3].x *=(1.-(_veg_edge_glow*0.30));
	_OI_[3].y = min(_OI_[3].y + (_veg_edge_glow*0.40), 1.);

	float _totalCoastal = min(1., _coastalResponse+_underWater);
	float _solidVeg = clamp(((_veg_response-0.01495)*8.0), 0., 1.);
	float _totalVeg = ( _vis_veg * _veg_mix );
	float _totalVert = 1.-_totalVeg;
	float _maxRevealDirtPow = 1. - clamp( (__role - 3.5)*2.0, 0., 1.);
	float _revealedUnderDirt = clamp(1. - _totalVeg - _totalCoastal - _totalVert, 0., 1.);
	_OI_[1].rgb = mix(_OI_[1].rgb, vec3(0.,0.,1.), _totalVeg); 
	_OI_[0].rgb = mix (_hdirt_color, _OI_[0].rgb,  clamp(_maxRevealDirtPow + _solidVeg ,0., 1.));//_revealedUnderDirt);
	_OI_[0].rgb = mix(
			//mix( _gradSamp_h.rgb, _gradSamp_v.rgb, min(1., _i_gradmix + (1.-_veg_response))) * _darken_scale,
			mix(  
				_OI_[0].rgb *  _gradSamp_v.rgb * _darken_scale, 
				_OI_[0].rgb * _veg_color * _darken_scale, 
				_totalVeg),//* _darken_scale,
			_gradSamp_c.rgb, // vec3(20.,0.,0.),
			 _totalCoastal);
	//_OI_[0].rgb = vec3(0., _veg_response, 0.);
	
	//float _temp_path = 20. * -(abs((v_noise.x - 0.5)*2.0)-0.05);  // center blob outlines
//	float _temp_path = 20. * (abs((v_noise.x - 0.5)*2.0)-0.95);  // decent irregular surface approx 60%
	float _temp_path = clamp( 10. *  ((1.0 - abs(v_noise.x + (v_noise.y*0.4)))-0.885), 0., 1.);  // thin irregular lines like ivy/vines
	_temp_path *= clamp(2. - v_role, 0., 1.);
	_temp_path = pow(_temp_path, 0.2);
	_OI_[0].rgb = mix (_OI_[0].rgb , vec3(0.3, 0.2, 0.03)*.025, _temp_path);
	
//	float _hacky_lum = (_OI_[0].r + _OI_[0].g + _OI_[0].b ) / 3.;
//	float _hacky_lumAO = clamp(pow(_hacky_lum, _pow_ifavail), 0., 1.);
//	_OI_[2].w *= (1. - _hacky_lumAO);
	return; }

#endif
