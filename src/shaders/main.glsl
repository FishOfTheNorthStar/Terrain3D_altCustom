// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

R"(

////////////////////////
// Vertex
////////////////////////


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

	v_uvdistort = UV_DISTORT_IF_ENABLED(fUV);

	UV = round(fUV);
	v_norm_region.xy = mod(UV, _region_size) * _region_texel_size;

	v_noise = vec3(1.0);

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
#ifdef WORLD_NOISE_ENABLED
	#if defined(WORLD_NOISE_MODE_1)
		float _tch; 
		_tch=noise_mod(ngh.w,UV2)-ngh.w;ngh.w+=_tch;vgh.w+=_tch;
		_tch=noise_mod(ngh.z,UV2+_step.xz)-ngh.z;ngh.z+=_tch;vgh.z+=_tch;
		_tch=noise_mod(ngh.x,UV2+_step.zy)-ngh.x;ngh.x+=_tch;vgh.x+=_tch;
	#elif defined(WORLD_NOISE_MODE_2)
		fnl_state t_noise = __INIT_FNL();
		//v_noise = __SAMPLE_FNL3(t_noise, v_vertex.xz, vec3(0.25, 0.82, 2.41));
		vec4 nz4 = __SAMPLE_FNL2x2(t_noise, v_vertex.xz + _world_noise_offset.xz, vec2(1.), 2.41 * _world_noise_scale );
	    nz4 = (nz4 *_world_noise_height*25.);
		ngh += nz4;
	    nz4 += _world_noise_offset.y*100.;
		vgh += nz4;
	#endif
#endif
		v_normal = normalize(vec3(ngh.w - ngh.z, _mesh_vertex_spacing, ngh.w - ngh.x));
		v_tangent = cross(v_normal, vec3(0, 0, 1));
		v_binormal = cross(v_normal, v_tangent);

		// Get final vertex location and save it
		VERTEX.y = vgh.w;

		v_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		v_vertex_dist = length(v_vertex - v_camera_pos);

		// Get the region and control map ID for the vertices
		ivec3 i00, i01, i10, i11; ivec2 iUV=ivec2(UV); 
		i00=get_region_uv(UV);
		i01=get_region_uv(vec2(iUV+ivec2(0,1)));
		i10=get_region_uv(vec2(iUV+ivec2(1,0)));
		i11=get_region_uv(vec2(iUV+ivec2(1,1)));

		// Lookup adjacent vertices. 4 lookups
		//uint4 con = textureGather(_control_maps, v_region, 0);
		v_control = uvec4(
			texelFetch(_control_maps,i00,0).r,
			texelFetch(_control_maps,i01,0).r,
			texelFetch(_control_maps,i10,0).r,
			texelFetch(_control_maps,i11,0).r);
		v_neighbors=ivec4(i00.z,i01.z,i10.z,i11.z);
		v_rangles=TAU * (vec4(random(i00.xy), random(i01.xy), random(i10.xy), random(i11.xy))-0.5); 
#ifdef MULTI_SCALING_ENABLED
	v_far_factor = clamp(smoothstep(_multi_scale_near, _multi_scale_far, v_vertex_dist), 0.0, 1.0);
#endif
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

vec2 rotate(vec2 v, float cosa, float sina) {
	return vec2(cosa * v.x - sina * v.y, sina * v.x + cosa * v.y); }

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

const vec4 EMPTY = vec4(0.);
const vec4 NEUTRAL = vec4(0.5f, 0.5f, 1.0f, 1.0f);
// 2-4 lookups
void get_material(vec2 base_uv, vec4 _grad, uint control, int region, float random_angle, out Material out_mat) {
	out_mat = Material(vec4(0.), vec4(0.), 0, 0, 0.0);
	vec3 normal = v_normal;
	//vec2 uv_center = vec2(iuv_center.xy);
	//vec2 uv_distorted = uv_center + v_uvdistort;

	float _blend = 0.;
	ivec2 _ids = GET_MAT_IDS_AND_BLEND(control, region, v_normal, _blend);
	out_mat.blend = _blend;
	out_mat.base = _ids.x; 
	out_mat.over = _ids.y;

	//float random_value = random(uv_center);
	//float random_angle = (random_value - 0.5) * TAU; // -180deg to 180deg
	base_uv *= .5; // Allow larger numbers on uv scale array - move to C++

	const float UVD_BASE_TEX_SCALE = 0.05;
	vec2 uv_scales = vec2(
		0.5 * _texture_uv_scale_array[out_mat.base],
		_texture_uv_scale_array[out_mat.over]);
	vec2 uvd_scales = uv_scales / UVD_BASE_TEX_SCALE;

	vec2 uv1 = fma(base_uv,vec2(uv_scales.xx),(v_uvdistort * uvd_scales.x));
	vec2 matUV = rotate_around(uv1, uv1 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.base]);
	vec4 uv1_grad = vec4(dFdx(matUV), dFdy(matUV));// _grad * uv2_scale; 

	vec4 albedo_ht, normal_rg, albedo_far, normal_far;
	albedo_ht = EMPTY; albedo_far = EMPTY;
	normal_rg = NEUTRAL; normal_far = NEUTRAL;
	
#ifdef MULTI_SCALING_ENABLED
//INSERT: MULTI_SCALING_BASE
#else
//INSERT: UNI_SCALING_BASE
#endif

	// Apply color to base
	albedo_ht.rgb *= _texture_color_array[out_mat.base].rgb;

	// Unpack base normal for blending
	normal_rg.xz = unpack_normal(normal_rg).xz;

	// Setup overlay texture to blend
	vec2 uv2 = fma(base_uv,vec2(uv_scales.yy),(v_uvdistort * uvd_scales.y));
	vec2 matUV2 = rotate_around(uv2, uv2 - 0.5, random_angle * _texture_uv_rotation_array[out_mat.over]);
	vec4 uv2_grad = vec4(dFdx(matUV2), dFdy(matUV2));// _grad * uv2_scale; 

	vec4 albedo_ht2 = textureGrad(_texture_array_albedo, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);
	vec4 normal_rg2 = textureGrad(_texture_array_normal, vec3(matUV2, float(out_mat.over)), uv2_grad.xy, uv2_grad.zw);

	// Though it would seem having the above lookups in this block, or removing the branch would
	// be more optimal, the first introduces artifacts #276, and the second is noticably slower. 
	// It seems the branching off dual scaling and the color array lookup is more optimal.
	if (out_mat.blend > 0.f) {

#ifdef MULTI_SCALING_ENABLED
//INSERT: MULTI_SCALING_OVERLAY
#endif

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

	// Calculate Terrain Normals.
	mat3 mVM = mat3(VIEW_MATRIX);
	NORMAL = mVM * v_normal;
	TANGENT = mVM * v_tangent;
	BINORMAL = mVM * v_binormal;

	// Identify 4 vertices surrounding this pixel
	vec2 texel_pos = uv;
	highp vec2 texel_pos_floor = floor(uv);

	// Create a cross hatch grid of alternating 0/1 horizontal and vertical stripes 1 unit wide in XY 
	vec4 mirror = vec4(fract(texel_pos_floor * 0.5) * 2.0, 1.0, 1.0);
	// And the opposite grid in ZW
	mirror.zw = vec2(1.0) - mirror.xy;

	// highp vec2 tpf=texel_pos_floor 
	// Get the region and control map ID for the vertices into ivec3s
	//i00 = get_region_uv(tpf + mirror.xy);
	//i01 = "(tpf + mirror.xw);
	//i10 = "(tpf + mirror.zy);
	//i11 = "(tpf + mirror.zw);

	// Get the textures for each vertex. 8-16 lookups (2-4 ea)
	Material mat[4];
	get_material(uv, RTX_GRAD, v_control.x, v_neighbors.x, v_rangles.x, mat[0]);
	get_material(uv, RTX_GRAD, v_control.y, v_neighbors.y, v_rangles.y, mat[1]);
	get_material(uv, RTX_GRAD, v_control.z, v_neighbors.z, v_rangles.z, mat[2]);
	get_material(uv, RTX_GRAD, v_control.w, v_neighbors.w, v_rangles.w, mat[3]);

	// Calculate weight for the pixel position between the vertices
	// Bilinear interpolation of difference of uv and floor(uv)
	vec2 weights1 = clamp(texel_pos - texel_pos_floor, 0, 1);
	weights1 = mix(weights1, vec2(1.0) - weights1, mirror.xy);
	vec2 weights0 = vec2(1.0) - weights1;
	// Adjust final weights by texture's height/depth + noise. 1 lookup
	vec4 n3grad = RTX_GRAD * _noise_tint_noise3_scale;
	float noise3 = textureGrad(noise_texture, uv*_noise_tint_noise3_scale, n3grad.xy, n3grad.zw).r;
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
	vec4 noise1_grad = RTX_GRAD * _noise_tint_noise1_scale * .1;
	vec4 noise2_grad = RTX_GRAD * _noise_tint_noise2_scale * .1;
	float noise1 = textureGrad(noise_texture, rotate(uv*_noise_tint_noise1_scale*.1, cos(_noise_tint_noise1_angle), sin(_noise_tint_noise1_angle)) + _noise_tint_noise1_offset, noise1_grad.xy, noise1_grad.zw).r;
	float noise2 = textureGrad(noise_texture, uv*_noise_tint_noise2_scale*.1, noise2_grad.xy, noise2_grad.zw).r;
	vec3 macrov = mix(_noise_tint_macro_variation1, vec3(1.), clamp(noise1 + v_vertex_dist*.0002, 0., 1.));
	macrov *= mix(_noise_tint_macro_variation2, vec3(1.), clamp(noise2 + v_vertex_dist*.0002, 0., 1.));
	
	//vec3 macrov = (v_noise.x * vec3(1.0, 0.0, 0.0) ) + (v_noise.y * vec3(0.0, 1.0, 0.0) )+ ( v_noise.z * vec3(0.0, 0.0, 1.0) );
	// Wetness/roughness modifier, converting 0-1 range to -1 to 1 range
	float roughness = fma(color_map.a-0.5, 2.0, normal_rough.a);

	// Apply PBR
	ALBEDO = albedo_height.rgb * color_map.rgb * macrov;
	ROUGHNESS = roughness;
	SPECULAR = 1.-normal_rough.a;
	NORMAL_MAP = normal_rough.rgb;
	NORMAL_MAP_DEPTH = 1.0;
	
	#include "res://addons/terrain_3d/tools/debug_view.gdshaderinc"

}
)"