#if defined(WORLD_NOISE_ENABLED)
// ***********************************************************************************************
#if defined(WORLD_NOISE_MODE_1)

// WORLD_NOISE_FUNCS_MODE_1

int get_noise_octaves_by_distance(float _camdist) {
    return int( 
			pow(1. - clamp( _camdist / (_world_noise_lod_distance), 0., 1.) , debug_world_noise_octaves_falloff_exp )
			* float(_world_noise_max_octaves - _world_noise_min_octaves) )
		+ _world_noise_min_octaves; }

float hashf(float f) {
	return fract(sin(f) * 1e4); }

float hashv2(vec2 v) {
	return fract(1e4 * sin(17.0 * v.x + v.y * 0.1) * (0.1 + abs(sin(v.y * 13.0 + v.x)))); }

// https://iquilezles.org/articles/morenoise/
vec3 noise2D(vec2 x) {
    vec2 f = fract(x);
    // Quintic Hermine Curve.  Similar to SmoothStep()
    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);
    vec2 du = 30.0*f*f*(f*(f-2.0)+1.0);

    vec2 p = floor(x);

	// Four corners in 2D of a tile
	float a = hashv2( p+vec2(0,0) );
    float b = hashv2( p+vec2(1,0) );
    float c = hashv2( p+vec2(0,1) );
    float d = hashv2( p+vec2(1,1) );

    // Mix 4 corner percentages
    float k0 =   a;
    float k1 =   b - a;
    float k2 =   c - a;
    float k3 =   a - b - c + d;
    return vec3( k0 + k1 * u.x + k2 * u.y + k3 * u.x * u.y,
                du * ( vec2(k1, k2) + k3 * u.yx) );
}

float world_noise(int _octaves, vec2 p) {
    float a = 0.0;
    float b = 1.0;
    vec2  d = vec2(0.0);
	
    for( int i=0; i < _octaves; i++ ) {
        vec3 n = noise2D(p);
        d += n.yz;
        a += b * n.x / (1.0 + dot(d,d));
        b *= 0.5;
        p = mat2( vec2(0.8, -0.6), vec2(0.6, 0.8) ) * p * 2.0;
    }
    return a;
}


float noise_mod(int _octaves, float _orig_height, vec2 _at_uv) {
	float _weight = texture(_region_blend_map, (_at_uv/float(_region_map_size))+0.5).r;
	float _rmap_half_size = float(_region_map_size)*.5;
    vec2 _abs_at_uv = abs(_at_uv);
    vec2 _minus_half_map_up = max(vec2(0.),_abs_at_uv - (_rmap_half_size+.5));
    vec2 _minus_half_map_down = max(vec2(0.),_abs_at_uv - (_rmap_half_size-.5));
    //_weight *= min(1., _minus_half_map_down.x * _minus_half_map_down.y * _minus_half_map_up.x * _minus_half_map_up.y);

	_weight = mix(_weight, 0., _minus_half_map_down.x);
	_weight = mix(_weight, 0., _minus_half_map_down.y);
    _weight = mix(_weight, 0., _minus_half_map_up.x);
    _weight = mix(_weight, 0., _minus_half_map_up.y);

    float _scale = 8.0 / max(0.50, _world_noise_scale);
	float _new_height = mix(_orig_height, world_noise(_octaves, (_at_uv+_world_noise_offset.xz) * _scale ) * 
        _world_noise_height*5. + _world_noise_offset.y*100.,
		clamp(smoothstep(_world_noise_blend_near, _world_noise_blend_far, 1.0 - _weight), 0.0, 1.0));
    return _new_height; }

// World Noise 1 end
#endif
// ***********************************************************************************************
#if defined(WORLD_NOISE_MODE_2)
// WORLD_NOISE_FUNCS_MODE_2
#include "res://addons/terrain_3d/shader/ext/fastnoiselite.gdshaderinc"

int get_noise_octaves_by_distance(float _camdist) {
    return int( 
			pow(1. - clamp( _camdist / (_world_noise_lod_distance), 0., 1.) , debug_world_noise_octaves_falloff_exp )
			* float(_world_noise_max_octaves - _world_noise_min_octaves) )
		+ _world_noise_min_octaves; }

const int   _T3D_FNL_SEED = 420;
const float _T3D_FNL_SCALE_MAX = 1.0;
fnl_state __INIT_FNL(int _octaves) {
//fnl_state __INIT_FNL() { int _octaves = 4;
    fnl_state noise = fnlCreateState(_T3D_FNL_SEED);
	//noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
	//noise.noise_type = FNL_NOISE_OPENSIMPLEX2S;
	//noise.noise_type = FNL_NOISE_CELLULAR;
	noise.noise_type = FNL_NOISE_PERLIN;
	//noise.noise_type = FNL_NOISE_VALUE_CUBIC;
	//noise.noise_type = FNL_NOISE_VALUE;
	
	//noise.fractal_type =FNL_FRACTAL_NONE;
	//noise.fractal_type =FNL_FRACTAL_FBM;
	//noise.fractal_type =FNL_FRACTAL_RIDGED;
	noise.fractal_type =FNL_FRACTAL_PINGPONG;
	//noise.fractal_type =FNL_FRACTAL_DOMAIN_WARP_PROGRESSIVE;
	//noise.fractal_type =FNL_FRACTAL_DOMAIN_WARP_INDEPENDENT;
    
	noise.octaves=_octaves;
    return noise;
}

float __SAMPLE_FNL(fnl_state noise, vec2 _uv, float _scale) {
    _uv *= (_T3D_FNL_SCALE_MAX / max(0.50, _scale));
	return fnlGetNoise2D(noise, _uv.x, _uv.y) * 0.5 + 0.5;
}

vec2 __SAMPLE_FNL2(fnl_state noise, vec2 _uv, vec2 _scales) {
    
    vec2 _uv_x = _uv * (_T3D_FNL_SCALE_MAX / max(0.50, _scales.x));
    vec2 _uv_y = _uv * (_T3D_FNL_SCALE_MAX / max(0.50, _scales.y));
	return vec2( 
        fnlGetNoise2D(noise, _uv_x.x, _uv_x.y),
        fnlGetNoise2D(noise, _uv_y.x, _uv_y.y) ) * 0.5 + 0.5;
}

vec3 __SAMPLE_FNL3(fnl_state noise, vec2 _uv, vec3 _scales) {
    
    vec2 _uv_x = _uv * (_T3D_FNL_SCALE_MAX / max(0.50, _scales.x));
    vec2 _uv_y = _uv * (_T3D_FNL_SCALE_MAX / max(0.50, _scales.y));
    vec2 _uv_z = _uv * (_T3D_FNL_SCALE_MAX / max(0.50, _scales.z));
	return vec3( 
        fnlGetNoise2D(noise, _uv_x.x, _uv_x.y),
        fnlGetNoise2D(noise, _uv_y.x, _uv_y.y),
        fnlGetNoise2D(noise, _uv_z.x, _uv_z.y) ) * 0.5 + 0.5;
}

vec4 __SAMPLE_FNL2x2(fnl_state noise, vec2 _uv, vec2 _uvStep, float _scale) {
    _scale = (_T3D_FNL_SCALE_MAX / max(0.50, _scale));
    _uv *= _scale;
    _uvStep *= _scale;
    vec3 _stepXYZ = vec3(_uvStep.x, _uvStep.y, 0.);
    vec2 _uv00 = _uv + _stepXYZ.zz;
    vec2 _uv01 = _uv + _stepXYZ.zy;
    vec2 _uv10 = _uv + _stepXYZ.xz;
    vec2 _uv11 = _uv + _stepXYZ.xy;
	return vec4( 
        fnlGetNoise2D(noise, _uv01.x, _uv01.y),
        fnlGetNoise2D(noise, _uv11.x, _uv11.y),
        fnlGetNoise2D(noise, _uv10.x, _uv10.y),
        fnlGetNoise2D(noise, _uv00.x, _uv00.y) ) * 0.5 + 0.5;
}


float hashf(float f) {
	return fract(sin(f) * 1e4); }

float hashv2(vec2 v) {
	return fract(1e4 * sin(17.0 * v.x + v.y * 0.1) * (0.1 + abs(sin(v.y * 13.0 + v.x)))); }

// World Noise Mode 2 (FNL v1) end
#endif
// ***********************************************************************************************
#endif
// ***********************************************************************************************
#if !defined(WORLD_NOISE_ENABLED) || ( !defined(WORLD_NOISE_MODE_1) && !defined(WORLD_NOISE_MODE_2) )
// WORLD_NOISE_DISABLED
float noise_mod(float _orig_height, vec2 _at_uv) {
    return _orig_height; }
#endif
// ***********************************************************************************************
