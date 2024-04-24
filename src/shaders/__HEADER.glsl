R"(
//INSERT: HEADER_START_MARK
// MARK:__START_HEADER__

//INSERT: HEADER
shader_type spatial;
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

 
#include "res://addons/terrain_3d/tools/fastnoiselite.gdshaderinc"

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
uniform float _texture_uv_scale_array[32];
uniform float _texture_uv_rotation_array[32];
uniform vec4 _texture_color_array[32];
uniform uint _background_mode = 1u;  // NONE = 0, FLAT = 1, NOISE = 2
uniform uint _mouse_layer = 0x80000000u; // Layer 32

// Public uniforms
uniform bool height_blending = true;
uniform float blend_sharpness : hint_range(0, 1) = 0.87;

// [_Auto_Shader_Uniforms_Begin_]
uniform float _auto_shader_slope;
uniform float _auto_shader_height_reduction;
uniform int _auto_shader_base_texture;
uniform int _auto_shader_overlay_texture;
// [_Auto_Shader_Uniforms_End_]

// [_Multi_Scale_Uniforms_Begin_]
uniform int _multi_scale_texture;
uniform float _multi_scale_micro_size;
uniform float _multi_scale_macro_size;
uniform float _multi_scale_far;
uniform float _multi_scale_near;
// [_Multi_Scale_Uniforms_End_]

// [_World_Noise_Uniforms_Begin_]
uniform sampler2D _region_blend_map : hint_default_black, filter_linear, repeat_disable;
uniform int _world_noise_max_octaves;
uniform int _world_noise_min_octaves;
uniform float _world_noise_lod_distance;
uniform float _world_noise_scale;
uniform float _world_noise_height;
uniform vec3 _world_noise_offset;
uniform float _world_noise_blend_near;
uniform float _world_noise_blend_far;
// [_World_Noise_Uniforms_End_]

// [_UV_Distortion_Uniforms_Begin_]
uniform float _uv_distortion_size;
uniform float _uv_distortion_power;
// [_UV_Distortion_Uniforms_End_]

// [_Noise_Tint_Uniforms_Begin_]
uniform vec3 _noise_tint_macro_variation1;
uniform vec3 _noise_tint_macro_variation2;
// Generic noise at 3 scales, which can be used for anything 
uniform float _noise_tint_noise1_scale;
uniform float _noise_tint_noise1_angle;
uniform vec2 _noise_tint_noise1_offset = vec2(0.5);
uniform float _noise_tint_noise2_scale;
uniform float _noise_tint_noise3_scale;
// [_Noise_Tint_Uniforms_End_]

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
varying flat uvec4 v_control;
varying flat ivec4 v_neighbors;
varying flat vec4 v_rangles;
varying float v_far_factor;

varying vec3 v_noise;
varying vec3 v_normal;
varying vec3 v_tangent;
varying vec3 v_binormal;
varying vec2 v_uvdistort;

// A couple utility functions, should be moved into their respective namespaces

// Moves a point around a pivot point.
vec2 rotate_around(vec2 p,vec2 pv,float a){
	vec2 cs,dy; p-=pv;cs=vec2(cos(a),sin(a));pv+=cs.xy*p.x;dy=cs.yx*p.y;dy.x*=-1.;pv+=dy; return pv; }
	
float random(in ivec2 xy) {
	return fract(sin(dot(vec2(xy), vec2(12.9898, 78.233))) * 43758.5453); }

	
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

//INSERT: HEADER_END_MARK_NOTICE
// -------------------------------------------------------------------------
// * Note, any code above this line will be removed the next time any change
// is made to the shader parameters, or it reloads for whatever reason.  Do
// not remove or alter the line below or anything above.
// ----------------------------------------------------
//INSERT: HEADER_END_MARK
//MARK:__END_HEADER__
)"