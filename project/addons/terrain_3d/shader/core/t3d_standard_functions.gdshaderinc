
// Takes in UV world space coordinates, returns ivec3 with:
// XY: (0 to _region_size) coordinates within a region
// Z: layer index used for texturearrays, -1 if not in a region
ivec3 get_region_uv(vec2 uv) {
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		uv *= _region_texel_size;
		ivec2 pos = ivec2(floor(uv)) + (_region_map_size / 2);
		int bounds = int(pos.x>=0 && pos.x<_region_map_size && pos.y>=0 && pos.y<_region_map_size);
		int layer_index = _region_map[ pos.y * _region_map_size + pos.x ] * bounds - 1;
		return ivec3(ivec2((uv - _region_offsets[layer_index]) * _region_size), layer_index); 
	#else
		return ivec3(0);
	#endif
	}

// Takes in UV2 region space coordinates, returns vec3 with:
// XY: (0 to 1) coordinates within a region
// Z: layer index used for texturearrays, -1 if not in a region
vec3 get_region_uv2(vec2 uv) {
	#if defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
		ivec2 pos = ivec2(floor( uv ) ) + (_region_map_size / 2);
		int bounds = int(pos.x>=0 && pos.x<_region_map_size && pos.y>=0 && pos.y<_region_map_size);
		int layer_index = _region_map[ pos.y * _region_map_size + pos.x ] * bounds - 1;
		return vec3(uv - _region_offsets[layer_index], float(layer_index));
	#else
		return vec3(0.);
	#endif
	}

// Moves a point around a pivot point.
vec2 rotate_around(vec2 p,vec2 pv,float a){
	vec2 cs,dy; p-=pv;cs=vec2(cos(a),sin(a));pv+=cs.xy*p.x;dy=cs.yx*p.y;dy.x*=-1.;pv+=dy; return pv; }
	
float random(in ivec2 xy) {
	return fract(sin(dot(vec2(xy), vec2(12.9898, 78.233))) * 43758.5453); }

vec4 get_grad(vec2 world_uv) {
	return vec4( dFdx(world_uv), dFdy(world_uv) ); }

vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return n; }

vec4 pack_normal(vec3 n, float a) {
	n.z *= -1.0;
	return vec4((n.xzy + vec3(1.0)) * 0.5, a); }

// 1 lookup (depreciated)
float get_height_grad(vec2 uv, vec4 _grad) {
	highp float height = 0.0;
	vec3 region = get_region_uv2(uv);
	if (region.z >= 0.) {
		height = textureGrad(_height_maps, region, _grad.xy, _grad.zw).r; }
 	return height; }
	
vec2 rotate(vec2 v, float cosa, float sina) {
	return vec2(cosa * v.x - sina * v.y, sina * v.x + cosa * v.y); }	
	
// Depreciated, use x4 below
float blend_weights(float weight, float detail) {
	weight = sqrt(weight * 0.5);
	float result = max(0.1 * weight, 10.0 * (weight + detail) + 1.0f - (detail + 10.0));
	return result; }

vec4 blend_weights_x4(vec4 weights, vec4 details) {
	weights = sqrt(weights * 0.5);
	vec4 result = max(0.1 * weights, 10.0 * (weights + details) + 1.0f - (details + 10.0));
	return result; }

	
vec4 height_blend(vec4 a_value, float a_height, vec4 b_value, float b_height, float blend) {
	if(height_blending) {
		float ma = max(a_height + (1.0 - blend), b_height + blend) - (1.001 - blend_sharpness);
	    float b1 = max(a_height + (1.0 - blend) - ma, 0.0);
	    float b2 = max(b_height + blend - ma, 0.0);
	    return (a_value * b1 + b_value * b2) / (b1 + b2); } 
	else {
		float contrast = 1.0 - blend_sharpness;
		float factor = (blend - contrast) / contrast;
		return mix(a_value, b_value, clamp(factor, 0.0, 1.0)); } }