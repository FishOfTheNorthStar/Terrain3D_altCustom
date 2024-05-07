#if defined(CARTOGRAPHY_OVERLAYS) && !defined(CARTOGRAPHY_SUPPORT)
#define CARTOGRAPHY_SUPPORT

#include "res://addons/terrain_3d/shader/proto/t3d_utility.gdshaderinc"
#include "res://addons/terrain_3d/shader/mods/t3d_carto_presets.gdshaderinc"

const vec3 __CARTO_TOWARDS_CAMERA = vec3( 0.,0.,1. );
const vec3 __CARTO_ZERO = vec3( 0.,0.,0. );
const vec3 __CARTO_UP = vec3(0.,1.,0.); 
const float __CARTO_MAX_RANGE = 15000.;

//___________________________________________________________________________________
// This is here as a failsafe and to allow Godot's shader editor to run code analysis
// without failing on undefined functions and references.  These functions are currently
// defined within the header, in the "REGISTER feature parameter value provider 
// functions" section.  Because this defines a failsafe if one does not already exist,
// it's important to define this elsewhere, before including this file.
//
#if !defined(__CARTO_PROVIDE_PARAMS)
#define __CARTO_PROVIDE_PARAMS
float CARTO_PREFERRED_INDEX() { return 2.; }
float CARTO_PREFERRED_RANGE() { return 1000.; }
#endif
//___________________________________________________________________________________

//___________________________________________________________________________________
// ######## PRESET TEMPLATE SUPPORT ######## 
// Required utility functions: mix_mat4
//
void get_carto_preset(out mat4 preset_settings, out mat4 feature_colors) {
	float _indexWhole = clamp(CARTO_PREFERRED_INDEX(), 0., MAX_CARTO_PRESETS - 0.001);
	float _blend = fract(_indexWhole);
	int _lower = int(_indexWhole);
	int _upper = _lower + 1;
	preset_settings = mix_mat4(CARTO_PRESETS[_lower], CARTO_PRESETS[_upper], _blend);
	feature_colors =  mix_mat4(CARTO_FEATURE_COLORSETS[_lower], CARTO_FEATURE_COLORSETS[_upper], _blend);  }
	
//___________________________________________________________________________________
// ######## ELEVATION LINES ######## 
// Required utility functions: sharpen_step_x3, mod_step_x3
//
vec4 get_carto_elev_lines(
	vec3 __per_phase_opacity,
	vec3 __pixel_pos, float _norm_max_dist, float dotNormVsTowardsCam) {
	
	__per_phase_opacity = clamp(__per_phase_opacity, vec3(0.), vec3(1));
	float ELEV_OPACITY = max(max(__per_phase_opacity.x, __per_phase_opacity.y), __per_phase_opacity.z);
	const vec3 __PHASE_ABC_ELEV_COLOR = vec3(0.325,2.2,0.75)/3.;
	
	// This metrics could be constant, or they could be uint uniforms
	float _span_gap = 4.0;		// Distance between Phase A (Micro) Elevation lines.  Phase B and C are multiples of this
	vec3 _elev_dist_fact = 1.0 - min( vec3(1.), vec3(6., 4., 2.) * _norm_max_dist );	

	float __ex_dist_width_mult	= mix( 0.5, 40., ( 1.-pow(abs( dotNormVsTowardsCam ),0.16) ) * _norm_max_dist);
	float __elev_line			= min( _span_gap, 0.8 * __ex_dist_width_mult);

	// An irreglar 3x5 dashing pattern (for micro elevation lines (phase A)).
	// :: A pseudo-random offset for each vertical dash line, so the dashes don't line up when seen along the side of a steep hill
	float _voffset_dashed = fract(__pixel_pos.z * 0.08312) * 4.0;
	float _dashed = pow(clamp( abs(
		mod_step(__pixel_pos.x + _voffset_dashed, 8.2375,3.) + 
		mod_step(__pixel_pos.z + _voffset_dashed, 8.1852,3.)), 0., 1.), 6.25);
		
	vec3 _mod_elevs =
		vec3( 0.85 * (1.-_dashed), 0.6, 0.8 )			// Per-Phase Weights		Elevation ( Micro / Normal / Macro )
		* _elev_dist_fact								// Distance-Range Bands
		* sharpen_step_x3(								// Slight Pow on results of
			mod_step_x3(								// norm portion within steps
				__pixel_pos.y,							// keyed upon the current elevation
				_span_gap * vec3(1., 4., 16.),			// and split into 3 gap ranges, each a multiple of _span_gap
				__elev_line * vec3( 1., 1.5, 2.) ) );	// using step widths (line thickness) of 3 multiples of __elev_line

	// Cancel response on disabled channels
	_mod_elevs *= __per_phase_opacity;

	// Cancel early phase response from late phase response (so micro lines don't draw on top of macro lines, etc)
	_mod_elevs.y = clamp(_mod_elevs.y - _mod_elevs.z, 0., 1.);
	_mod_elevs.x = clamp(_mod_elevs.x - _mod_elevs.y - _mod_elevs.z, 0., 1.);

	vec4 _retval;
	_retval.a =  mix( 
		ELEV_OPACITY * clamp( 
			_mod_elevs.x + _mod_elevs.y + _mod_elevs.z, 
			0., 1. ), 
		.0, 1.0-_elev_dist_fact.x );
	_retval.rgb = mix (__CARTO_ZERO, __PHASE_ABC_ELEV_COLOR,  _retval.a );
	return _retval;
}

//___________________________________________________________________________________
// ######## GRID LINES ######## 
// Required utility functions: sharpen_step_x3, mod_step_x3
//
vec4 get_carto_grid_lines( vec3 __per_phase_opacity, vec3 __pixel_pos, float _norm_max_dist, float dotNormVsTowardsCam) {
	__per_phase_opacity = clamp(__per_phase_opacity, vec3(0.), vec3(1));
	float GRID_OPACITY = max(max(__per_phase_opacity.x, __per_phase_opacity.y), __per_phase_opacity.z);

	const vec3 __PHASE_A_GRID_COLOR = vec3(1.,2.,3.)/3.;
	const vec3 __PHASE_B_GRID_COLOR = vec3(2.,1.,3.)/3.;
	const vec3 __PHASE_C_GRID_COLOR = vec3(3.,2.,1.)/3.;

	// This metric could be constant, or it could be uint uniforms
	const float _grid_gap = 64.0;		// Distance between Phase A (Micro) Grid Square lines. Phase B and C are multiples of this

	// Negotiate a line width from current normalized view distance over max, and the normal dot (towards camera)
	vec3 _grid_dist_fact = 1.0 - min( vec3(1.), vec3(3., 2., 1.5) * _norm_max_dist );
	float _iex_dist_width_mult	= mix( 2.0, 23.1, ( abs( dotNormVsTowardsCam ) ) * _norm_max_dist);
	float __region_line			= min( _grid_gap, 0.6 * _iex_dist_width_mult);		// Region line thickness

	// An 8x8-unit dashed pattern (for micro grid lines (phase A)).
	float _dashed_reg = abs(
		step(8.,mod(__pixel_pos.x+4.,16.)) - 
		step(8.,mod(__pixel_pos.z+4.,16.)));

	// These are used twice for the x/z mod_steps below, so cache them to local variables for clarity and speed
	vec3 _grid_line_widths			= __region_line * vec3( 0.65, 1.0, 1.35);				// using step widths (line thickness) of 3 multiples of __region_line
	vec3 _grid_line_phase_weight	= vec3( 1.0 * (1.-_dashed_reg), 0.8, 0.8 );			// Per-Phase Weights
	vec3 _grid_line_gap_ranges		= _grid_gap * vec3(1., 4., 16.);					// The space between grid lines, as multiples of _grid_gap

	vec3 _mod_latlong = max(								 // Grid-Squares(X,Z) ( Micro / Normal / Macro )
			_grid_line_phase_weight							 // Per-Phase Weights		
			* _grid_dist_fact								 // Distance-Range Bands
			* sharpen_step_x3(								 // Slight Pow on results of
				mod_step_x3(								 // norm portion within steps
					__pixel_pos.x,							 // keyed upon the current x-position
					_grid_line_gap_ranges,					 // and split into 3 gap ranges, each a multiple of _grid_gap
					_grid_line_widths ) ),					 // using step widths (line thickness) of 3 multiples of __region_line
															 //
			_grid_line_phase_weight							 // Per-Phase Weights 
			* _grid_dist_fact								 // Distance-Range Bands
			* sharpen_step_x3(								 // Slight Pow on results of
				mod_step_x3(								 // norm portion within steps
					__pixel_pos.z,							 // keyed upon the current z-position
					_grid_line_gap_ranges,					 // and split into 3 gap ranges, each a multiple of _grid_gap
					_grid_line_widths ) ) ); 				 // using step widths (line thickness) of 3 multiples of __region_line
	
	// Cancel response on disabled channels		
	_mod_latlong *= __per_phase_opacity;

	// Cancel early phase response from late phase response (so micro lines don't draw on top of macro lines, etc)
	_mod_latlong.y = clamp(_mod_latlong.y - _mod_latlong.z, 0., 1.);
	_mod_latlong.x = clamp(_mod_latlong.x - _mod_latlong.y - _mod_latlong.z, 0., 1.);
	
	vec4 _retval;
	_retval.a = GRID_OPACITY * clamp( _mod_latlong.x + _mod_latlong.y + _mod_latlong.z, 0., 1. );
	_retval.rgb = ( (_mod_latlong.x) * __PHASE_A_GRID_COLOR )
				+ ( (_mod_latlong.y) * __PHASE_B_GRID_COLOR ) 
				+ ( (_mod_latlong.z) * __PHASE_C_GRID_COLOR );
	return _retval; }

//___________________________________________________________________________________
// ######## FEATURE LINES ######## 
// Required utility functions: get_features_by_normal, get_dot_similarity
//
vec4 get_carto_feat_lines(
	vec3 __per_group_opacity,  vec4 __per_phase_line_mult, mat4 __colorset,
	vec3 __pixel_norm, float _norm_max_dist, float dotNormVsTowardsCam, out vec4 _fillColor) {

	__per_group_opacity = clamp(__per_group_opacity, vec3(0.), vec3(1.));
	float CONTOUR_EDGE_OPACITY = max(__per_group_opacity.x, __per_group_opacity.y);
	float CONTOUR_EDGE_VERT_OPACITY = __per_group_opacity.x;	//_debug_view_cartographer_features_opacity_per_phase.x;
	float CONTOUR_EDGE_HORZ_OPACITY = __per_group_opacity.y;	//_debug_view_cartographer_features_opacity_per_phase.y;
	
	vec3 __CONTOUR_DETECTED_COLOR_SHEER_VERT	= __colorset[0].rgb;
	vec3 __CONTOUR_DETECTED_COLOR_VERT 			= __colorset[1].rgb;
	vec3 __CONTOUR_DETECTED_COLOR_MID 			= __colorset[2].rgb;
	vec3 __CONTOUR_DETECTED_COLOR_FLAT 			= __colorset[3].rgb;
	vec3 __CONTOUR_DETECTED_COLOR_FLATTER		= vec3(__colorset[0].w, __colorset[1].w, __colorset[2].w);

	const float CONTOUR_FILL_OPACITY = 0.125;
	
	float _contour_edge_range = -1.2 ;
	float _contour_edge_width = mix(5.86, 1., pow(_norm_max_dist,0.75 )) ; // Higher value is thinner edge
	float _contour_edge_widthnew = mix(0.15, 0.8, pow(_norm_max_dist,0.35 )) ;
	
	vec4 _contours_ = get_features_by_normal(__pixel_norm );
	
	vec2 _contour_flatter_to_puddle = get_dot_similarity(__pixel_norm, __CARTO_UP, -0.9522 , _contour_edge_range*0.28, _contour_edge_width*2.25);
	_contour_flatter_to_puddle = clamp(_contour_flatter_to_puddle-_contours_.x-_contours_.y-_contours_.z-_contours_.w, vec2(0.), vec2(1.));

	float _fill_pow = __per_group_opacity.z;
	float _vce_pow = CONTOUR_EDGE_VERT_OPACITY * CONTOUR_EDGE_OPACITY;
	float _hce_pow = CONTOUR_EDGE_HORZ_OPACITY * CONTOUR_EDGE_OPACITY;
	float __contour_any = clamp(((_contours_.x + _contours_.y) * _vce_pow) + ( ( _contours_.z + _contours_.w ) * _hce_pow ) + _contour_flatter_to_puddle.y, 0., 1.);
	vec4 __edged_con = vec4(
		__EDGE(_contours_.x, _contour_edge_widthnew * __per_phase_line_mult.x),
		__EDGE(_contours_.y, _contour_edge_widthnew * __per_phase_line_mult.y),
		__EDGE(_contours_.z, _contour_edge_widthnew * __per_phase_line_mult.z),
		__EDGE(_contours_.w, _contour_edge_widthnew * __per_phase_line_mult.w) );

	float __edge_any = clamp(((__edged_con.x + __edged_con.y) * _vce_pow) + ( ( __edged_con.z + __edged_con.w ) * _hce_pow ) + _contour_flatter_to_puddle.y, 0., 1.);
	vec3 _contourCol =    ( __edged_con.x * _vce_pow * __CONTOUR_DETECTED_COLOR_VERT)
						+ ( __edged_con.y * _vce_pow * __CONTOUR_DETECTED_COLOR_MID) 
						+ ( __edged_con.z * _hce_pow * __CONTOUR_DETECTED_COLOR_FLAT) 
						+ ( __edged_con.w * _hce_pow * __CONTOUR_DETECTED_COLOR_FLATTER );

	vec4 _fills_ = clamp((1.0 - abs(_contours_ * 2.0 - 1.0))*3333.0, vec4(0.), vec4(1.));
	float _fillAny =  clamp((_fills_.x + _fills_.y + _fills_.z + _fills_.w) * _fill_pow, 0., 1.);
	float _fills_sheer_vert = 1.0 - _fillAny;
	_fillAny = clamp(_fillAny + _fills_sheer_vert, 0., 1.);
	
	vec3 _contourFillCol = ( _fills_.x * __CONTOUR_DETECTED_COLOR_VERT)
						+ ( _fills_.y * __CONTOUR_DETECTED_COLOR_MID) 
						+ ( _fills_.z * __CONTOUR_DETECTED_COLOR_FLAT) 
						+ ( _fills_.w * __CONTOUR_DETECTED_COLOR_FLATTER )
						+ ( _fills_sheer_vert * __CONTOUR_DETECTED_COLOR_SHEER_VERT );
	_fillColor = vec4(_fillAny);
	_fillColor.xyz = _contourFillCol;

	vec4 _retval = vec4(clamp(__edge_any,0.,1.));
	_retval.rgb = _contourCol;
	return _retval;
}

//___________________________________________________________________________________
// ######## PRIMARY EFFECT FUNCTION ######## 
// Required utility functions: mix_mat4 (and indirectly: sharpen_step_x3, mod_step_x3, get_features_by_normal, get_dot_similarity )
//
mat4 get_carto_effects(
	vec3 __vertex, 
	vec3 __mesh_normal, 
	mat4 _OI_ ) {

	mat4 _orig_input_ = _OI_;

	vec3 __albedo			= _OI_[0].rgb;
	vec3 __normal_map		= _OI_[1].rgb;
	vec3 __emission			= _OI_[2].rgb;
	vec3 _r_m_s_ 			= _OI_[3].xyz; // convienence accessor for roughness/metallic/specular components (as supplied), compiles away
	float __ao_light_affect	= _OI_[3].w;
	float __ao				= _OI_[2].w;

	const float __EMISSION_POWER =  4.;

	// ___________________________________________________________
	// --- MODE TEMPLATE NEGOTIATION ---
	mat4 _template, _feat_colors;
	get_carto_preset(_template, _feat_colors);

	float _dark_light_mode_mix	= _template[0].x;
	float _mix_existing_surface = _template[0].y;
	vec3 _elevLineWeights		= _template[1].xyz;
	vec3 _gridLineWeights		= _template[2].xyz;
	vec4 _featureLineMults		= _template[3];
	vec3 _featureGroupWeights	= vec3(_template[1].w, _template[2].w, _template[0].z);

	// ___________________________________________________________
	// --- DARK / LIGHT MODE ADJUSTMENT ---
	// Negotiate dark/light mode material property settings and cache the results as 'goal' values used later within lerps
	vec3  _dl_goal_norm 	= mix( mix( mix( __normal_map, vec3(0.5, 0.5, 1.0), 0.15), vec3(0.5, 0.5, 1.0),  _dark_light_mode_mix), __normal_map, _mix_existing_surface);
	vec3  _dl_goal_col 		= mix( mix( 0.010 *__albedo, 		vec3(0.51),	_dark_light_mode_mix), __albedo, _mix_existing_surface);

	vec3 _dl_goal_r_m_s = mix( mix( 
		vec3( 0.325, 0.175, 0.100 ) * _r_m_s_, 	// The dark modes scale the shine factors but even with no masking, still utilize some of the existing surface qualities. 
		vec3( 0.800, 0.000, 0.001 ), 			// None of the light modes utilize the existing roughness/metallic/specular components, they always over-ride them
		_dark_light_mode_mix), _r_m_s_, _mix_existing_surface);
	
	float _dl_goal_emit 	= mix( __EMISSION_POWER, 	0., 	_dark_light_mode_mix);
	float _dl_goal_ao 		= mix(  0.01 * __ao, 		0.0, 	_dark_light_mode_mix);;
	float _dl_goal_ao_light_affect = 1.0;

	// ___________________________________________________________
	// --- CALC CARTO SHARED VIEW METRICS ---
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
	float __camera_dist = length(v_camera_pos - __vertex);
	#else
	float __camera_dist = 1.0;
	#endif

	// These variables are used by the primary work functions called below.
	float _norm_max_dist = pow(clamp(__camera_dist/__CARTO_MAX_RANGE, 0.0, 1.0), 0.75);
	float dotNormVsTowardsCam = dot( __mesh_normal, __CARTO_TOWARDS_CAMERA );

	float _pref_range = CARTO_PREFERRED_RANGE();
	float _range_dir_mix = fma(sign(_pref_range), 0.5, 0.5);
	_pref_range = max(0.01, abs(_pref_range));
	vec2 rangeMinMax = vec2( _pref_range, _pref_range * 1.1 );

	// This variable acts as an effect modulator based on distance from a point, the camera position by default.
	float __effect_distance_mod = 1.-min(1., max(0., __camera_dist - rangeMinMax.x) / (rangeMinMax.y - rangeMinMax.x) );
	//float __effect_distance_mod = 1.-min(1., max(0., __camera_dist - rangeMinMax.x) / max(0.001, rangeMinMax.y - rangeMinMax.x) );
	__effect_distance_mod = mix(__effect_distance_mod, 1.-__effect_distance_mod, _range_dir_mix);
	// ___________________________________________________________
	// --- MAIN WORK ---
	vec4 _feat_fills;  // Populated by get_carto_feat_lines() as an out param
	vec4 _elev_resp = get_carto_elev_lines(_elevLineWeights, __vertex, _norm_max_dist, dotNormVsTowardsCam);
	vec4 _grid_resp = get_carto_grid_lines(_gridLineWeights, __vertex, _norm_max_dist, dotNormVsTowardsCam);
	vec4 _feat_resp = get_carto_feat_lines(_featureGroupWeights, _featureLineMults, _feat_colors, __mesh_normal, _norm_max_dist, dotNormVsTowardsCam, _feat_fills);
	float _vis_resp = clamp(_elev_resp.w + _grid_resp.w + _feat_resp.w, 0., 1.);
	
	// ___________________________________________________________
	// --- BLEND AND APPLY RESULTS ---
	float _outer_resp = pow(clamp((_vis_resp-0.)*4.4, 0.,1.),0.21);
	float _inner_resp = pow(clamp((_vis_resp-0.3)*1.4, 0.,1.),0.21);
	float _fillpow = clamp((_feat_fills.w+ _outer_resp) * _template[0].z,0.,1.);

	float _glim_pow		= 1. - pow(_norm_max_dist, 0.125);  // a little extra shimmer added into dark-mode display 

	vec3 _emit =   mix (__CARTO_ZERO, _grid_resp.rgb, _grid_resp.w)
	 			 + mix (__CARTO_ZERO, _feat_resp.rgb, _feat_resp.w) 
	 			 + mix (__CARTO_ZERO, _elev_resp.rgb,  _elev_resp.w );

	
	_OI_[0].rgb	=	// Albedo
		mix( mix( _dl_goal_col, __CARTO_ZERO, _inner_resp ), _feat_fills.rgb, _fillpow );

	_OI_[1].rgb =	// Normal Map
		_dl_goal_norm; 

	_OI_[2].rgb = 	// Emission
		mix( __emission, __emission+_emit, _dl_goal_emit * (1.-_template[0].z));

	_OI_[3].xyz = 	// Roughness / Metallic / Specular
		vec3( mix( _dl_goal_r_m_s.x, 0.95 * _r_m_s_.x,  _glim_pow),
			mix( _dl_goal_r_m_s.y, 0., _glim_pow * _outer_resp),
			mix( mix(_r_m_s_.z*0.2,_r_m_s_.z,_mix_existing_surface), _dl_goal_r_m_s.z,_outer_resp) );

	_OI_[2].w =		// Ambient Occlusion (AO)
		mix( __ao,  _dl_goal_ao,_outer_resp);

	_OI_[3].w =		// AO Light Affect
		mix( __ao_light_affect, _dl_goal_ao_light_affect, _outer_resp);

	return mix_mat4(_OI_, _orig_input_, __effect_distance_mod); }

	//vec3 _ALBEDO				= mix( mix( _dl_goal_col, __CARTO_ZERO, _inner_resp ), _feat_fills.rgb, _fillpow );	
	//vec3 _NORMAL_MAP			= _dl_goal_norm; 
	//vec3 _EMISSION			= mix( __emission, __emission+_emit, _dl_goal_emit * (1.-_template[0].z));
	//float _ROUGHNESS			= mix( _dl_goal_r_m_s.x, 0.95 * _r_m_s_.x,  _glim_pow);
	//float _METALLIC			= mix( _dl_goal_r_m_s.y, 0., _glim_pow * _outer_resp);
	//float _SPECULAR			= mix( mix(_r_m_s_.z*0.2,_r_m_s_.z,_mix_existing_surface), _dl_goal_r_m_s.z,_outer_resp);
	//float _AO					= mix( __ao,  _dl_goal_ao,_outer_resp);
	//float _AO_LIGHT_AFFECT	= mix( __ao_light_affect, _dl_goal_ao_light_affect, _outer_resp);

	// ___________________________________________________________
	// --- MODULATE RESULTS BY DISTANCE FACTOR ---
	//_ALBEDO				= mix(__albedo,				_ALBEDO,			__effect_distance_mod);
	//_EMISSION				= mix(__emission,			_EMISSION,			__effect_distance_mod);
	//_NORMAL_MAP			= mix(__normal_map,			_NORMAL_MAP,		__effect_distance_mod);
	//_ROUGHNESS			= mix(_r_m_s_.x,			_ROUGHNESS,			__effect_distance_mod);
	//_METALLIC				= mix(_r_m_s_.y,			_METALLIC,			__effect_distance_mod);
	//_SPECULAR				= mix(_r_m_s_.z,			_SPECULAR,			__effect_distance_mod);
	//_AO					= mix(__ao,					_AO,				__effect_distance_mod);
	//_AO_LIGHT_AFFECT		= mix(__ao_light_affect,	_AO_LIGHT_AFFECT,	__effect_distance_mod);

	// ___________________________________________________________
	// --- PACKAGE RESULTS ---	
	//_OI_[0].rgb = _ALBEDO.rgb;
	//_OI_[1].rgb = _NORMAL_MAP.rgb;
	//_OI_[2].rgb = _EMISSION.rgb;
	//_OI_[3].x = _ROUGHNESS;
	//_OI_[3].y = _METALLIC;
	//_OI_[3].z = _SPECULAR;
	//_OI_[2].w = _AO;
	//_OI_[3].w = _AO_LIGHT_AFFECT;
	//return _OI_; }

#endif