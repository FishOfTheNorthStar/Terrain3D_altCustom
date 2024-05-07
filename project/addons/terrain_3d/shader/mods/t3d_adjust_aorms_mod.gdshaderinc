#if !defined(__T3D_ADJUST_AORMS_MOD__)
#define __T3D_ADJUST_AORMS_MOD__


void get_adjust_aorms_mod_effects( mat4 _mixed_mat_, inout mat4 _OI_ ) {

//	_OI_ (Overlay Input) Key:
//	vec3 __albedo			= _OI_[0].rgb;
//	vec3 __normal_map		= _OI_[1].rgb;
//	vec3 __emission			= _OI_[2].rgb;
//	vec3 __r_m_s 			= _OI_[3].xyz; // roughness/metallic/specular components
//	float __ao_light_affect	= _OI_[3].w;
//	float __ao				= _OI_[2].w;

	const float MAX_EFFECT_LIMIT = 0.4; // Lower number is higher effect, here.
	const float PRESCALE_CLAMP_RATIO = 1.015;
	const float __AO_LIGHT_AFFECT = 0.8;// Higher number is higher effect, but this should stay mostly constant.  Probably leave it alone here, change set that value one time in the main fragment function.

	vec4 _adjusts = _mixed_mat_[2];

	float _ao_pow_ifavail = 1.;
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		_ao_pow_ifavail = _adjust_aorms_ao_exp;
	#endif

	//vec4 _adjust_to_less = min(vec4(1.), _adjusts*2.0);
	//vec4 _adjust_to_more = max(vec4(0.), _adjusts*2.0-1.0);

	vec3 _alb_rgb = _mixed_mat_[0].rgb;
	float _avg_lum = clamp((_alb_rgb.r + _alb_rgb.g + _alb_rgb.b) / 3.,0.,1.);
	_avg_lum = clamp( ( (_avg_lum - 0.5) * PRESCALE_CLAMP_RATIO) + 0.5, 0., 1.);
	float _ex_AO = pow(_avg_lum, _ao_pow_ifavail);

	_OI_[2].w *= mix(1., clamp(_ex_AO, MAX_EFFECT_LIMIT, 1.0), _adjusts.x);
	_OI_[3].w = __AO_LIGHT_AFFECT;
	return; }
#endif
