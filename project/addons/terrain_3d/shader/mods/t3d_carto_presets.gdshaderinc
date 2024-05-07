#if !defined(CARTOGRAPHY_PRESETS_DEFINED)
#define CARTOGRAPHY_PRESETS_DEFINED

const mat4 __CARTO_PRESET_DISABLED = 
	mat4(
		vec4( 0.000, 1.000, 0.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.000, 0.000, 0.000, 0.000),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.000, 0.000, 0.000, 0.000),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 0.000, 0.000, 0.000, 0.000)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_PRESET_DEERDAVEL = 
	mat4(
		vec4( 0.025, 0.070, 0.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.380, 0.475, 0.350, 0.900),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.445, 0.550, 0.410, 0.455),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 3.350, 4.000, 2.250, 3.000)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_PRESET_MAJORTOM = 
	mat4(
		vec4( 0.025, 0.070, 0.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.480, 0.575, 0.750, 0.900),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.445, 0.750, 0.610, 0.155),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 0.650, 0.800, 0.250, 0.500)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_PRESET_HOSTILE_TAKEOVER = 
	mat4(
		vec4( 1.000, 0.000, 0.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.148, 0.457, 0.350, 0.300),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.245, 0.450, 0.380, 0.255),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 0.450, 0.800, 0.250, 0.500)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_PRESET_SHARPIE_TOWN = 
	mat4(
		vec4( 1.000, 1.000, 0.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.348, 0.657, 0.550, 0.500),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.445, 0.650, 0.480, 0.355),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 0.450, 0.800, 0.250, 0.500)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_PRESET_CELLSHADE = 
	mat4(
		vec4( 1.000, 0.000, 1.000, 0.000),		// Darkmode/Lightmode Mix, Masking, Reserved, Reserved
		vec4( 0.125, 0.125, 0.125, 0.300),		// xyz = Elevation Phase Opacities, w = Feature Vertical Opacity
		vec4( 0.000, 0.000, 0.000, 0.300),		// xyz = Grid Phase Opacities, w = Feature Horizontal Opacity
		vec4( 0.350, 0.700, 0.250, 0.500)); 	// Feature Line Width Multipliers (Vertical, Hazard, Obstacle, Flat)

const mat4 __CARTO_COLORSET_1_CELLSHADED = 
mat4(
	vec4(vec3(0.112,0.097,0.052)*4., 0.1),  	// SHEER_VERT
	vec4(vec3(0.063,0.058,0.035)*3., 0.19),  	// VERT
	vec4(vec3(0.065,0.090,0.060)*1., 0.08), 	// MID
	vec4(vec3(0.058,0.047,0.034)*3., 0.) ); 	// FLAT && FLATTER in w's of 0,1,2

const mat4 __CARTO_COLORSET_2_DAREDEVIL = 
mat4(
	vec4(vec3(0.122,0.097,0.042), 0.1),  	// SHEER_VERT
	vec4(vec3(2.5,0.25,0.125)/3., 0.19),  	// VERT
	vec4(vec3(2.5,0.3,2.7)/6., 0.08), 	// MID
	vec4(vec3(0.2,1.25,0.125)/4., 1.) ); 	// FLAT && FLATTER in w's of 0,1,2

const int iMAX_CARTO_PRESETS = 6;
const float MAX_CARTO_PRESETS = float (iMAX_CARTO_PRESETS-1);

const mat4 CARTO_PRESETS[iMAX_CARTO_PRESETS] = {
	__CARTO_PRESET_DISABLED,
	__CARTO_PRESET_SHARPIE_TOWN,
	__CARTO_PRESET_HOSTILE_TAKEOVER,
	__CARTO_PRESET_CELLSHADE,
	__CARTO_PRESET_MAJORTOM,
	__CARTO_PRESET_DEERDAVEL
	};
const mat4 CARTO_FEATURE_COLORSETS[iMAX_CARTO_PRESETS] = {
	__CARTO_COLORSET_1_CELLSHADED,
	__CARTO_COLORSET_1_CELLSHADED,
	__CARTO_COLORSET_1_CELLSHADED,
	__CARTO_COLORSET_1_CELLSHADED,
	__CARTO_COLORSET_2_DAREDEVIL,
	__CARTO_COLORSET_2_DAREDEVIL
	};

#endif