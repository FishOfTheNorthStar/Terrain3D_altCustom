#if !defined(__T3D_UTILS__)
#define __T3D_UTILS__

uniform float debug_testval_1 : hint_range(-0.5, 0.5, 0.001) = 0.;
uniform float debug_testval_2 : hint_range(-10.0, 10.0, 0.01) = 0.;
uniform float debug_veg_density : hint_range(0., 2., 0.001) = 0.5;
uniform float debug_sealevel : hint_range(-256., 256., 0.001) = 0.;
uniform float debug_seafloor : hint_range(-512., 128., 0.001) = 0.;
uniform float debug_shoreheight : hint_range(-20., 20., 0.001) = 5.;
uniform float debug_world_noise_octaves_falloff_exp : hint_range(0., 2., 0.001) = 0.85;

#include "res://addons/terrain_3d/shader/ext/psrddnoise3.gdshaderinc"
//#include "res://addons/terrain_3d/shader/mods/t3d_gradients.gdshaderinc"


const vec4 STANDARD_CONTOUR_BREAKING_SET = vec4(0.52, 0.585, 0.96, 0.985);

	
// A couple utility functions, should be moved into their respective namespaces


mat4 mix_mat4(mat4 _from, mat4 _to, float _blend) {
	return (_from * (1.-_blend)) + (_to * _blend); }

vec4 get_elevmark_metrics(float world_y) {
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		float SPLITGRAD_SEALEVEL = debug_sealevel;
		float SPLITGRAD_COASTHEIGHT = debug_shoreheight;
		float SPLITGRAD_SEAFLOOR = debug_seafloor;
	#else 
		float SPLITGRAD_SEALEVEL = 60.;
		float SPLITGRAD_SEAFLOOR = 10.;
		float SPLITGRAD_COASTHEIGHT = 5.;
	#endif
	float _relSeaLevel = world_y - SPLITGRAD_SEALEVEL;
	float _coastalResponse = clamp(-(_relSeaLevel + SPLITGRAD_COASTHEIGHT)/ SPLITGRAD_COASTHEIGHT, 0., 1.);
	float _seaFloorResponse = clamp(-_relSeaLevel/( SPLITGRAD_SEALEVEL - SPLITGRAD_SEAFLOOR), 0., 0.999);
	float _underWater = floor(_coastalResponse);
	float _aboveWater = 1.-_underWater;
	_coastalResponse *= _aboveWater;
	return vec4( 
		_coastalResponse, 
		_seaFloorResponse, 
		_relSeaLevel, 
		_aboveWater ); }


float edge_isolate_region(float _region_response_, float _edge_portion) {
	float _t = clamp( ( abs(_region_response_ * 2. - 1.) - (1.-_edge_portion) ) * ( 1. / _edge_portion ), 0., 1.);
	return 1.-max(_t, 1.-_t); }

float __EDGE(float _region_, float _edge_portion){
	return edge_isolate_region(_region_, _edge_portion); }

// Given an input (elevation, world x, world z, etc), and a span gap, and a width of that gap to treat as within the line,
// returns a normal value of 1 = not at all within line and 0 = center line
float mod_step(float _in_val, float _in_gap, float _in_line_width) {
	float _instep = 1.0 - max(0.0, (fract(_in_val / _in_gap) * _in_gap) - (_in_gap-_in_line_width) ) / _in_line_width;
	float _outstep = 1.0 + min(0.0, (fract(_in_val / _in_gap) * _in_gap) - (_in_line_width) ) / _in_line_width;
	return 1.0-min(_instep, _outstep); }

vec3 mod_step_x3(float _in_val, vec3 _spans, vec3 _step_widths) {
	vec3 _ofs_spans = _spans - _step_widths;
	vec3 _fr_div_mult = fract( _in_val / _spans ) * _spans;
	return 1.- min( 1.0 - max(vec3(0.),_fr_div_mult - _ofs_spans) / _step_widths, 
					1.0 + min(vec3(0.), _fr_div_mult - _step_widths ) / _step_widths ); }

vec3 sharpen_step_x3(vec3 _norm_steps) {
	const vec3 __SS_ZERO = vec3(0.);
	const vec3 __SS_ONE = vec3(1.);
	return clamp((pow(clamp(_norm_steps, __SS_ZERO, __SS_ONE), vec3(2.2))-0.5)*4.0, __SS_ZERO, __SS_ONE) ; }

vec2 get_dot_similarity(vec3 __for_normal, vec3 __against_normal, float __bias, float __valid_range, float __line_width_mult) {
	float __vs_dot__ = dot(__against_normal, __for_normal);
	float _temp_range_offset = __valid_range;
	float _windowed_vs = 1.-abs( clamp((pow(__vs_dot__,2.25+_temp_range_offset)+ __bias)*__line_width_mult, -1., 1.));
 	return vec2( 
		pow(clamp(pow(_windowed_vs+0.0001, 3.125),0.,1.), 11.),
		clamp(pow(_windowed_vs, 1.025),0.,1.) ); }

vec3 priority_cancel_x3(vec3 __samples){
	__samples.y = clamp(__samples.y-__samples.x, 0., 1.);
	__samples.z = clamp(__samples.z-__samples.x-__samples.y, 0., 1.);
	return __samples; }

vec4 priority_cancel_x4(vec4 __samples){
	__samples.y = clamp(__samples.y-__samples.x, 0., 1.);
	__samples.z = clamp(__samples.z-__samples.x-__samples.y, 0., 1.);
	__samples.w = clamp(__samples.w-__samples.x-__samples.y-__samples.z, 0., 1.);
	return __samples; }

vec4 get_features_by_normal(vec3 __for_normal ) {
	// externally supplied vec4 roughly equal to vec4(0.5, 0.65, 0.85, 0.985);
	#if defined(T3D_PROVIDE_MATS_BY_ROLE)
	vec4 __breaks_at = GET_FEATURE_BREAKS();
	#else
	const vec4 __breaks_at = STANDARD_CONTOUR_BREAKING_SET;
	#endif
	return 	min( vec4(1.), max( vec4(0.), vec4( 
			clamp( dot( __for_normal, vec3(0.,1.,0.) ), 0., 1. ) ) 
			- __breaks_at ) / ( vec4( __breaks_at.yzw, 1.0 ) - __breaks_at ) ); }

float get_role_from_world_normal( vec3 __world_norm ) {
	vec4 __contours_ = get_features_by_normal(__world_norm );
	float __sumparts = (__contours_.x + __contours_.y + __contours_.z + __contours_.w);
	//__sumparts += clamp((1.-__sumparts), 0., 1.);
	return __sumparts; }

mat3 get_role_varyings_from_world_normal(vec3 __world_norm){
	vec4 __contours_ = get_features_by_normal(__world_norm );
	float __normWhole = 0.;
	__normWhole = (__contours_.x + __contours_.y + __contours_.z + __contours_.w);// / 4.0;
	float __inner_flat = clamp(1.- __contours_.x- __contours_.y- __contours_.z- __contours_.w, 0., 1.);
	vec2 __puddle = get_dot_similarity(__world_norm, vec3(0.,1.,0.), -0.9522 , -1.2*0.28, 5.86*2.25);
	__puddle.y = clamp(__puddle.y-__contours_.x-__contours_.y-__contours_.z-__contours_.w, 0., 1.);
	mat3 _ret = mat3(0.);
	_ret[0] = __contours_.xyz;
	_ret[1] = vec3(
		__contours_.w,
		__inner_flat,
		__puddle.y );
	return _ret; }

#if defined(FEATURE_SHADER_ENABLED)
vec3 get_best_mat_by_role(){
	//vec3 out_grad, out_dgrad, out_dgrad2; 
	//float t_noise = psrddnoise(vec3(4.0,2.0,0.0), vec3(5.), 0.0, out_grad, out_dgrad, out_dgrad2);
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		float _whole_role = v_role;
		float _localNoise = v_noise.x;
		int[] _troles = GET_MAT_ROLE_INDEX();
		int[] _troles_alts = GET_MAT_ALTS_INDEX();
	#else
		float _whole_role = 0.;
		int[] _troles =  { 0, 1, 2, 3, 4, 5 };
		int[] _troles_alts = { 0, 1, 2, 3, 4, 5 };
		float _localNoise = 0.;
	#endif
	
	int _baseInt = int(floor(_whole_role));
	float _bestMat = float(_troles[_baseInt]);
	float _nextBestMat = float(_troles[_baseInt+1]);
	float _bestMatAlt = float(_troles_alts[_baseInt]);
	float _nextBestMatAlt = float(_troles_alts[_baseInt+1]);
	float _blend_fact = clamp(_whole_role - floor(_whole_role), 0., 1.);
	//float _is_inner_flat = 0.;//max(0., _whole_role - 5.);
	
	float _cen_blend = max(0., 1. - (pow ( abs(_blend_fact * 2.0 - 1.00), 1.)*2.51));
	int _offsi = clamp(int(_localNoise*4.), 0, 1);
	float _offsf = clamp(_localNoise*4., 0., 1.)*1.;
	float _on_zero = max(0.,float(max(0,1-_baseInt)));//-_blend_fact);
	float _on_last =0.;// float(1-clamp(abs(_baseInt+int(_blend_fact*1.01) - 4), 0, 1));
	float _can_mod = min(1., _cen_blend + _on_zero+ _on_last);
	float _bcan_mod = min(1., _can_mod *10000.);
	_offsi *= int(_can_mod*2.);

	_bestMat = max(0., mix(
		_bestMat,
		mix(  _bestMat,_nextBestMat, _on_last),
		_bcan_mod));
		
	_nextBestMat = max(0., mix(
		_nextBestMat,
		mix(_bestMatAlt,  _nextBestMatAlt, _on_last), _bcan_mod));
	_blend_fact = mix( 
		_blend_fact,
		clamp( (pow(_localNoise*0.5+0.5, abs(debug_testval_2))+debug_testval_1), 0., 1.),
		_can_mod*_bcan_mod);
	
	return vec3(
		float( _bestMat),
		float( _nextBestMat),
		_blend_fact  ); }

#endif
#endif
