// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

R"(shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;

/* This shader is generated based upon the debug views you have selected.
 * The terrain function depends on this shader. So don't change:
 * - vertex positioning in vertex()
 * - terrain normal calculation in fragment()
 * - the last function being fragment() as the editor injects code before the closing }
 *
 * Most will only want to customize the material calculation and PBR application in fragment()
 *
 * Uniforms that begin with _ are private and will not display in the inspector. However, 
 * you can set them via code. You are welcome to create more of your own hidden uniforms.
 *
 * This system only supports albedo, height, normal, roughness. Most textures don't need the other
 * PBR channels. Height can be used as an approximation for AO. For the rare textures do need
 * additional channels, you can add maps for that one texture. e.g. an emissive map for lava.
 *
 */

// Private uniforms

uniform float _region_size = 1024.0;
uniform float _region_texel_size = 0.0009765625; // = 1/1024
uniform float _mesh_vertex_spacing = 1.0;
uniform float _mesh_vertex_density = 1.0; // = 1/_mesh_vertex_spacing
uniform int _region_map_size = 16;
uniform int _region_map[256];
uniform vec2 _region_offsets[256];
uniform sampler2DArray _height_maps : repeat_disable;
uniform usampler2DArray _control_maps : repeat_disable;
//INSERT: TEXTURE_SAMPLERS_NEAREST
//INSERT: TEXTURE_SAMPLERS_LINEAR
uniform float _texture_uv_scale_array[32];
uniform float _texture_uv_rotation_array[32];
uniform vec4 _texture_color_array[32];
uniform uint _background_mode = 1u;  // NONE = 0, FLAT = 1, NOISE = 2
uniform uint _mouse_layer = 0x80000000u; // Layer 32

// Public uniforms
uniform bool height_blending = true;
uniform float blend_sharpness : hint_range(0, 1) = 0.87;
//INSERT: AUTO_SHADER_UNIFORMS
//INSERT: DUAL_SCALING_UNIFORMS
uniform vec3 macro_variation1 : source_color = vec3(1.);
uniform vec3 macro_variation2 : source_color = vec3(1.);
// Generic noise at 3 scales, which can be used for anything 
uniform float noise1_scale : hint_range(0.001, 1.) = 0.04;	// Used for macro variation 1. Scaled up 10x
uniform float noise1_angle : hint_range(0, 6.283) = 0.;
uniform vec2 noise1_offset = vec2(0.5);
uniform float noise2_scale : hint_range(0.001, 1.) = 0.076;	// Used for macro variation 2. Scaled up 10x
uniform float noise3_scale : hint_range(0.001, 1.) = 0.225;  // Used for texture blending edge.

// Varyings & Types

struct Material {
	vec4 alb_ht;
	vec4 nrm_rg;
	int base;
	int over;
	float blend;
};

varying flat vec3 v_vertex;	// World coordinate vertex location
varying flat vec3 v_camera_pos;
varying flat float v_vertex_dist;
varying flat ivec3 v_region;
varying flat vec3 v_norm_region;
varying flat vec2 v_uv_offset;
varying flat vec2 v_uv2_offset;

varying vec3 v_normal;
varying vec3 v_tangent;
varying vec3 v_binormal;

////////////////////////
// Vertex
////////////////////////

// Takes in UV world space coordinates, returns ivec3 with:
// XY: (0 to _region_size) coordinates within a region
// Z: layer index used for texturearrays, -1 if not in a region
ivec3 get_region_uv(vec2 uv) {
	uv *= _region_texel_size;
	ivec2 pos = ivec2(floor(uv)) + (_region_map_size / 2);
	int bounds = int(pos.x>=0 && pos.x<_region_map_size && pos.y>=0 && pos.y<_region_map_size);
	int layer_index = _region_map[ pos.y * _region_map_size + pos.x ] * bounds - 1;
	return ivec3(ivec2((uv - _region_offsets[layer_index]) * _region_size), layer_index); }

// Takes in UV2 region space coordinates, returns vec3 with:
// XY: (0 to 1) coordinates within a region
// Z: layer index used for texturearrays, -1 if not in a region
vec3 get_region_uv2(vec2 uv) {
	ivec2 pos = ivec2(floor( uv ) ) + (_region_map_size / 2);
	int bounds = int(pos.x>=0 && pos.x<_region_map_size && pos.y>=0 && pos.y<_region_map_size);
	int layer_index = _region_map[ pos.y * _region_map_size + pos.x ] * bounds - 1;
	return vec3(uv - _region_offsets[layer_index], float(layer_index)); }

// 1 lookup (depreciated)
float get_height_grad(vec2 uv, vec4 _grad) {
	highp float height = 0.0;
	vec3 region = get_region_uv2(uv);
	if (region.z >= 0.) {
		height = textureGrad(_height_maps, region, _grad.xy, _grad.zw).r; }
 	return height; }

void vertex() {
	// Get camera pos in world vertex coords
    v_camera_pos = INV_VIEW_MATRIX[3].xyz;

	// Get vertex of flat plane in world coordinates and set world UV
	v_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// UV coordinates in world space. Values are 0 to _region_size within regions
	vec2 fUV = v_vertex.xz * _mesh_vertex_density;
	UV = round(fUV);
	v_norm_region.xy = mod(UV, _region_size) * _region_texel_size;

	// Discard vertices for Holes. 1 lookup
	v_region = get_region_uv(UV);
	v_norm_region.z = float(v_region.z);
	uint _rv=uint(clamp(v_region.z+1,0,1));
	float _frv=float(_rv);
	uint control = texelFetch(_control_maps, v_region, 0).r;
	bool hole = bool(control >>2u & 0x1u);
	// Show holes to all cameras except mouse camera (on exactly 1 layer)
	if (  !(CAMERA_VISIBLE_LAYERS == _mouse_layer) 
		&& (hole || (_background_mode + _rv == 0u)) ) {
		VERTEX.x = 0./0.; } 
	else {
		vec3 _step = vec3(1.,1.,0.) * _region_texel_size;
		vec3 half_step = _step *.5;
		float _valid = 1. - _step.x;
		vec3 t_norm = v_norm_region;
		t_norm.xy *= _valid;
		const vec4 zro = vec4(0);
		// UV coordinates in region space + texel offset. Values are 0 to 1 within regions
		UV2 = UV * _step.x;
		vec4 vgh = mix(zro, textureGather(_height_maps, v_norm_region + half_step, 0), _frv);
		vec4 ngh = mix(zro, textureGather(_height_maps, t_norm + half_step, 0), _frv);
		if(_background_mode == 2u) {
	       float _tch; 
		   _tch=noise_mod(ngh.w,UV2)-ngh.w;ngh.w+=_tch;vgh.w+=_tch;
		   _tch=noise_mod(ngh.z,UV2+_step.xz)-ngh.z;ngh.z+=_tch;vgh.z+=_tch;
		   _tch=noise_mod(ngh.x,UV2+_step.zy)-ngh.x;ngh.x+=_tch;vgh.x+=_tch; }
		v_normal = normalize(vec3(ngh.w - ngh.z, _mesh_vertex_spacing, ngh.w - ngh.x));
		v_tangent = cross(v_normal, vec3(0, 0, 1));
		v_binormal = cross(v_normal, v_tangent);

		// Get final vertex location and save it
		VERTEX.y = vgh.w;

		v_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		v_vertex_dist = length(v_vertex - v_camera_pos);
//INSERT: DUAL_SCALING_VERTEX
	}

	// Transform UVs to local to avoid poor precision during varying interpolation.
	v_uv_offset = MODEL_MATRIX[3].xz * _mesh_vertex_density;
	UV -= v_uv_offset;
	v_uv2_offset = v_uv_offset * _region_texel_size;
	UV2 -= v_uv2_offset; }

////////////////////////
// Fragment
////////////////////////

vec4 get_grad(vec2 world_uv) {
	return vec4( dFdx(world_uv), dFdy(world_uv) ); }

vec3 unpack_normal(vec4 rgba) {
	vec3 n = rgba.xzy * 2.0 - vec3(1.0);
	n.z *= -1.0;
	return n; }

vec4 pack_normal(vec3 n, float a) {
	n.z *= -1.0;
	return vec4((n.xzy + vec3(1.0)) * 0.5, a); }

float random(in vec2 xy) {
	return fract(sin(dot(xy, vec2(12.9898, 78.233))) * 43758.5453); }

vec2 rotate(vec2 v, float cosa, float sina) {
	return vec2(cosa * v.x - sina * v.y, sina * v.x + cosa * v.y); }

// Moves a point around a pivot point.
vec2 rotate_around(vec2 point, vec2 pivot, float angle){
	float x = pivot.x + (point.x - pivot.x) * cos(angle) - (point.y - pivot.y) * sin(angle);
	float y = pivot.y + (point.x - pivot.x) * sin(angle) + (point.y - pivot.y) * cos(angle);
	return vec2(x, y); }

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

// 2-4 lookups
void get_material(vec2 base_uv, vec4 _grad, uint control, ivec3 iuv_center, vec3 normal, out Material out_mat) {
	out_mat = Material(vec4(0.), vec4(0.), 0, 0, 0.0);
	vec2 uv_center = vec2(iuv_center.xy);
	int region = iuv_center.z;

//INSERT: AUTO_SHADER_TEXTURE_ID
//INSERT: TEXTURE_ID
	float random_value = random(uv_center);
	float random_angle = (random_value - 0.5) * TAU; // -180deg to 180deg
	base_uv *= .5; // Allow larger numbers on uv scale array - move to C++

	float uv1_scale = 0.5 * _texture_uv_scale_array[out_mat.base];

	vec2 uv1 = base_uv * uv1_scale;
	vec4 uv1_grad = _grad * uv1_scale; 
	vec2 matUV = rotate_around(uv1, uv1 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.base]);

	vec4 albedo_ht = vec4(0.);
	vec4 normal_rg = vec4(0.5f, 0.5f, 1.0f, 1.0f);
	vec4 albedo_far = vec4(0.);
	vec4 normal_far = vec4(0.5f, 0.5f, 1.0f, 1.0f);
	
//INSERT: UNI_SCALING_BASE
//INSERT: DUAL_SCALING_BASE
	// Apply color to base
	albedo_ht.rgb *= _texture_color_array[out_mat.base].rgb;

	// Unpack base normal for blending
	normal_rg.xz = unpack_normal(normal_rg).xz;

	// Setup overlay texture to blend
	float uv2_scale = _texture_uv_scale_array[out_mat.over];
	vec2 uv2 = base_uv * uv2_scale;
	vec4 uv2_grad = _grad * uv2_scale; 
	vec2 matUV2 = rotate_around(uv2, uv2 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.over]);

	vec4 albedo_ht2 = textureGrad(_texture_array_albedo, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);
	vec4 normal_rg2 = textureGrad(_texture_array_normal, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);

	// Though it would seem having the above lookups in this block, or removing the branch would
	// be more optimal, the first introduces artifacts #276, and the second is noticably slower. 
	// It seems the branching off dual scaling and the color array lookup is more optimal.
	if (out_mat.blend > 0.f) {
//INSERT: DUAL_SCALING_OVERLAY
		// Apply color to overlay
		albedo_ht2.rgb *= _texture_color_array[out_mat.over].rgb;
		
		// Unpack overlay normal for blending
		normal_rg2.xz = unpack_normal(normal_rg2).xz;

		// Blend overlay and base
		albedo_ht = height_blend(albedo_ht, albedo_ht.a, albedo_ht2, albedo_ht2.a, out_mat.blend);
		normal_rg = height_blend(normal_rg, albedo_ht.a, normal_rg2, albedo_ht2.a, out_mat.blend); }
	
	// Repack normals and return material
	normal_rg = pack_normal(normal_rg.xyz, normal_rg.a);
	out_mat.alb_ht = albedo_ht;
	out_mat.nrm_rg = normal_rg;
	return; }

float blend_weights(float weight, float detail) {
	weight = sqrt(weight * 0.5);
	float result = max(0.1 * weight, 10.0 * (weight + detail) + 1.0f - (detail + 10.0));
	return result; }

void fragment() {
	// Recover UVs
	vec2 uv = UV + v_uv_offset;
	vec2 uv2 = UV2 + v_uv2_offset;
	
	// Calculate derivatives from UV2 (world space in normalized tile units)
	// Pass this along to samplers as the explicit derivative.
	const float TXLOD_SCALE = 2.0; // to-do: make this a material parameter
	vec4 WORLD_GRAD = get_grad(uv2) / TXLOD_SCALE;
	vec4 RTX_GRAD = get_grad(uv) / TXLOD_SCALE;

	// Calculate Terrain Normals. 0 lookups
	NORMAL = mat3(VIEW_MATRIX) * v_normal;
	TANGENT = mat3(VIEW_MATRIX) * v_tangent;
	BINORMAL = mat3(VIEW_MATRIX) * v_binormal;

	// Identify 4 vertices surrounding this pixel
	vec2 texel_pos = uv;
	highp vec2 texel_pos_floor = floor(uv);

	// Create a cross hatch grid of alternating 0/1 horizontal and vertical stripes 1 unit wide in XY 
	vec4 mirror = vec4(fract(texel_pos_floor * 0.5) * 2.0, 1.0, 1.0);
	// And the opposite grid in ZW
	mirror.zw = vec2(1.0) - mirror.xy;

	// Get the region and control map ID for the vertices
	ivec3 index00UV = get_region_uv(texel_pos_floor + mirror.xy);
	ivec3 index01UV = get_region_uv(texel_pos_floor + mirror.xw);
	ivec3 index10UV = get_region_uv(texel_pos_floor + mirror.zy);
	ivec3 index11UV = get_region_uv(texel_pos_floor + mirror.zw);

	// Lookup adjacent vertices. 4 lookups
	//uint4 con = textureGather(_control_maps, v_region, 0);
	uint control00 = texelFetch(_control_maps, index00UV, 0).r;
	uint control01 = texelFetch(_control_maps, index01UV, 0).r;
	uint control10 = texelFetch(_control_maps, index10UV, 0).r;
	uint control11 = texelFetch(_control_maps, index11UV, 0).r;

	// Get the textures for each vertex. 8-16 lookups (2-4 ea)
	Material mat[4];
	get_material(uv, RTX_GRAD, control00, index00UV, v_normal, mat[0]);
	get_material(uv, RTX_GRAD, control01, index01UV, v_normal, mat[1]);
	get_material(uv, RTX_GRAD, control10, index10UV, v_normal, mat[2]);
	get_material(uv, RTX_GRAD, control11, index11UV, v_normal, mat[3]);

	// Calculate weight for the pixel position between the vertices
	// Bilinear interpolation of difference of uv and floor(uv)
	vec2 weights1 = clamp(texel_pos - texel_pos_floor, 0, 1);
	weights1 = mix(weights1, vec2(1.0) - weights1, mirror.xy);
	vec2 weights0 = vec2(1.0) - weights1;
	// Adjust final weights by texture's height/depth + noise. 1 lookup
	float noise3 = textureGrad(noise_texture, uv*noise3_scale, RTX_GRAD.xy, RTX_GRAD.zw).r;
	vec4 weights;
	vec2 _w01y = vec2(weights0.y, weights1.y);
	weights.xy = weights0.x * _w01y;
	weights.zw = weights1.x * _w01y;
	weights.x = blend_weights(weights.x, clamp(mat[0].alb_ht.a + noise3, 0., 1.));
	weights.y = blend_weights(weights.y, clamp(mat[1].alb_ht.a + noise3, 0., 1.));
	weights.z = blend_weights(weights.z, clamp(mat[2].alb_ht.a + noise3, 0., 1.));
	weights.w = blend_weights(weights.w, clamp(mat[3].alb_ht.a + noise3, 0., 1.));
	float weight_sum = weights.x + weights.y + weights.z + weights.w;
	float weight_inv = 1.0/weight_sum;

	// Weighted average of albedo & height
	vec4 albedo_height = weight_inv * (
		mat[0].alb_ht * weights.x +
		mat[1].alb_ht * weights.y +
		mat[2].alb_ht * weights.z +
		mat[3].alb_ht * weights.w );

	// Weighted average of normal & rough
	vec4 normal_rough = weight_inv * (
		mat[0].nrm_rg * weights.x +
		mat[1].nrm_rg * weights.y +
		mat[2].nrm_rg * weights.z +
		mat[3].nrm_rg * weights.w );

	// Determine if we're in a region or not (region_uv.z>0)
	vec3 region_uv = get_region_uv2(uv2);

	// Colormap. 1 lookup
	vec4 color_map = vec4(1., 1., 1., .5);
	if (region_uv.z >= 0.) {
		float lod = textureQueryLod(_color_maps, uv2.xy).y;
		color_map = textureLod(_color_maps, region_uv, lod);
	}

	// Macro variation. 2 Lookups
	vec4 noise1_grad = RTX_GRAD * noise1_scale * .1;
	vec4 noise2_grad = RTX_GRAD * noise2_scale * .1;
	float noise1 = textureGrad(noise_texture, rotate(uv*noise1_scale*.1, cos(noise1_angle), sin(noise1_angle)) + noise1_offset, noise1_grad.xy, noise1_grad.zw).r;
	float noise2 = textureGrad(noise_texture, uv*noise2_scale*.1, noise2_grad.xy, noise2_grad.zw).r;
	vec3 macrov = mix(macro_variation1, vec3(1.), clamp(noise1 + v_vertex_dist*.0002, 0., 1.));
	macrov *= mix(macro_variation2, vec3(1.), clamp(noise2 + v_vertex_dist*.0002, 0., 1.));

	// Wetness/roughness modifier, converting 0-1 range to -1 to 1 range
	float roughness = fma(color_map.a-0.5, 2.0, normal_rough.a);

	// Apply PBR
	ALBEDO = albedo_height.rgb * color_map.rgb * macrov;
	ROUGHNESS = roughness;
	SPECULAR = 1.-normal_rough.a;
	NORMAL_MAP = normal_rough.rgb;
	NORMAL_MAP_DEPTH = 1.0;
}

)"