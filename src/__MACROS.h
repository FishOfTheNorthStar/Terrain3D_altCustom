#pragma once

#ifndef TERRAIN3D_MACROS_H
#define TERRAIN3D_MACROS_H

//Code Templates for Terrain3D Managed GLSL/Godot Properties

// ################################################################################
#pragma region _core_management_macros_
	#define PASS_NX(A, B) A ## B
	#define PASS(A, B) PASS_NX(A, B)
	#define TOKETOKE_NX(A) #A
	#define TOKETOKE(A) TOKETOKE_NX(A)

	#define BIND_HELP(m_help_id) \
		ClassDB::bind_method(D_METHOD(TOKETOKE(PASS(_get_help_with_, m_help_id))), &Terrain3DMaterial::_get_help_with_##m_help_id); \

	#define ADD_INLINE_HELP(m_help_id, m_path_prefix, m_heading_desc) \
		ClassDB::bind_method( D_METHOD( TOKETOKE(PASS(get_help_with_, m_help_id) ) ), &Terrain3DMaterial::_get_help_with_##m_help_id ); \
		ClassDB::add_property(get_class_static(), PropertyInfo(Variant::STRING, TOKETOKE(PASS(m_path_prefix##/Help/, m_heading_desc##:)), PROPERTY_HINT_MULTILINE_TEXT ), "set_help_no_op_temp", TOKETOKE(PASS(get_help_with_, m_help_id)));

	#define ADD_HELP_TOPIC_DECL(helpID, contents) \
		String _get_help_with_##helpID() const { return String(contents); }

	#define ADD_BIND(m_bind_id, m_param_label) \
		ClassDB::bind_method(D_METHOD((TOKETOKE(PASS(get_, m_bind_id)))), &Terrain3DMaterial::get_##m_bind_id); \
		ClassDB::bind_method(D_METHOD(TOKETOKE(PASS(set_, m_bind_id)), #m_param_label), &Terrain3DMaterial::set_##m_bind_id);

	#define ADD_PRIV_BIND(m_bind_id, m_param_label) \
		ClassDB::bind_method(D_METHOD((TOKETOKE(PASS(_get_, m_bind_id)))), &Terrain3DMaterial::_get_##m_bind_id); \
		ClassDB::bind_method(D_METHOD(TOKETOKE(PASS(_set_, m_bind_id)), #m_param_label), &Terrain3DMaterial::_set_##m_bind_id);

	#define ADD_METHOD(m_bind_id, ...) \
		ClassDB::bind_method(D_METHOD(TOKETOKE_NX(m_bind_id), #__VA_ARGS__), &Terrain3DMaterial::##m_bind_id);

	#define ADD_METHOD_NOP( m_bind_id ) \
		ClassDB::bind_method(D_METHOD(TOKETOKE_NX(m_bind_id) ), &Terrain3DMaterial::##m_bind_id);

	#define __PROP_GEN(m_member_id, m_var_type, ...) ADD_PROPERTY(PropertyInfo(Variant::m_var_type, #m_member_id, PROPERTY_HINT_##__VA_ARGS__##),TOKETOKE(PASS(set_, m_member_id)) ,TOKETOKE(PASS(get_, m_member_id)));
	#define __PROP_GENGRP(m_group_id, m_member_id, m_var_type, ...) __PROP_GEN(m_group_id##_##m_member_id, m_var_type,__VA_ARGS__)

	#define VARR(m_bind_id, m_type, m_value) m_type _##m_bind_id = m_value;
	#define SETR(m_bind_id, m_type) void set_##m_bind_id(m_type p_value)
	#define GETR(m_bind_id, m_type) m_type get_##m_bind_id() const { return _##m_bind_id; }

	#define GSTR(m_bind_id, m_type) \
	GETR(m_bind_id, m_type); \
	SETR(m_bind_id, m_type);

	#define GROUP_VARS(m_bind_id) void _update_##m_bind_id##_params();
	#define UPDATE_GROUP(m_bind_id) _update_##m_bind_id##_params();

	//	LOG(INFO, s_log_desc, p_value) 
	#define __SETC__(m_bind_id, m_type, s_log_desc, f_after) \
	void Terrain3DMaterial::set_##m_bind_id(m_type p_value) { \
		_##m_bind_id = p_value; \
		f_after; }

	#define SETUPD__GRP(m_group_id, m_member_id, m_type, s_log_desc) __SETC__(m_member_id, m_type, s_log_desc, _update_shader())
	#define __SETPR_GRP(m_group_id, m_member_id, m_type, s_log_desc) __SETC__(m_member_id, m_type, s_log_desc, _update_##m_group_id##_params())
	#define UPDATE_SHADER(mbind_id) _safe_material_set_param("_" #mbind_id, _##mbind_id);

	#define UPDATE_GRP_START(m_group_id) \
	void Terrain3DMaterial::_update_##m_group_id##_params() { \
		if (_##m_group_id##_enabled && _material != Variant::NIL) { 

	#define UPDATE_GRP_START_CON(m_group_id, m_condition) \
		void Terrain3DMaterial::_update_##m_group_id##_params() { \
			if (( m_condition ) && ( _material != Variant::NIL) ) {

	#define UPDATE_GRP_END() } }

#pragma endregion _core_management_macros_
// ################################################################################

// ################################################################################
#pragma region _ALL_SETS_FUNCTIONS_

// These macros are used to group clusters of related management functions into
// one call, for clarity and compartmentalization.

// This is called by PRIVATE_MANAGED_VARS() below, from the class .h files private 
// section. It defines the functions that will provide the values to the placeholder 
// in-line "help" textareas.
#define __MAKE_MANAGED_HELP()\
	HELP_MULTI()\
	HELP_AUTO_SHADER()\
	HELP_WORLD_NOISE()\
	HELP_NOISE_TINT()\
	HELP_UVDIST()\
	HELP_DEBUG()\
	HELP_SHADER_OVERRIDE()

// This generates all of the actual functions within the class .cpp file.
#define MAKE_MANAGED_FUNCTIONS()\
	MAKE_MULTI_SCALE_FUNCTIONS()\
	MAKE_AUTO_SHADER_FUNCTIONS()\
	MAKE_WORLD_NOISE_FUNCTIONS()\
	MAKE_NOISE_TINT_FUNCTIONS()\
	MAKE_UV_DISTORTION_FUNCTIONS()

// This binds the necessary get/set functions for each managed property group.
#define BIND_MANAGED_VARS()\
	BIND_MULTI_SCALE_TEXTURING_VARS()\
	BIND_AUTO_SHADER_VARS()\
	BIND_UV_DISTORTION_VARS()\
	BIND_WORLD_NOISE_VARS()\
	BIND_NOISE_TINT_VARS()\
	BIND_DEBUG_VIEW_VARS()

// This adds the managed properties to the Godot extension.  For sanity purposes, 
// it's probably best to call this after BIND_MANAGED_VARS, but I'm not sure 
// it really matters.
#define ADD_MANAGED_PROPS()\
	PROPS_MULTI_SCALE_TEXTURING()\
	PROPS_AUTO_SHADER()\
	PROPS_WORLD_NOISE()\
	PROPS_NOISE_TINT()\
	PROPS_UV_DISTORTION()\
	PROPS_DEBUG_VIEW()\

#define PRIVATE_MANAGED_VARS()\
	PRIV_AUTO_SHADER_VARS()\
	PRIV_MULTI_SCALE_TEXTURING_VARS()\
	PRIV_WORLD_NOISE_VARS()\
	PRIV_NOISE_TINT_VARS()\
	PRIV_UV_DISTORTION_VARS()\
	PRIV_DEBUG_VIEW_VARS()

#define PUBLIC_MANAGED_FUNCS()\
	__MAKE_MANAGED_HELP()\
	PUBLIC_AUTO_SHADER_FUNCS()\
	PUBLIC_MULTI_SCALE_TEXTURING_FUNCS()\
	PUBLIC_WORLD_NOISE_FUNCS()\
	PUBLIC_NOISE_TINT_FUNCS()\
	PUBLIC_UV_DISTORTION_FUNCS()\
	PUBLIC_DEBUG_VIEW_FUNCS()

#define UPDATE_MANAGED_VARS()\
	UPDATE_MULTI_SCALE_TEXTURING()\
	UPDATE_AUTO_SHADER()\
	UPDATE_WORLD_NOISE()\
	UPDATE_NOISE_TINT()\
	UPDATE_UV_DISTORTION()

#pragma endregion _ALL_SETS_FUNCTIONS_
// ################################################################################

// ################################################################################
#pragma region _MULTI_SCALING_
	
// ***************************
// ** MULTI_STAGE_TEXTURING **
// ***************************

#pragma region _HELP_
#define HELP_MULTI()\
	ADD_HELP_TOPIC_DECL(multi_scale, R"(Enables selecting one texture ID that will have multiple scales applied based upon camera distance. Use it for something like a rock texture so up close it will be nicely detailed, and far away mountains can be covered in the same rock texture. The two blend together at a specified distance.)" )
#pragma endregion _HELP_

#pragma region _multi_scale_helper_macros_
#define   GETR_MULTI(m_bind_id, m_type)						 GSTR( multi_scale_##m_bind_id, m_type )
#define    VAR_MULTI(m_bind_id, m_type, m_value)			 VARR( multi_scale_##m_bind_id, m_type##, m_value )
#define   PROP_MULTI(m_member_id, m_var_type, ...)	__PROP_GENGRP( multi_scale, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_MULTI(m_bind_id, m_param_label)           ADD_BIND( multi_scale_##m_bind_id, m_param_label )
#define SETUPD_MULTI(m_bind_id, m_type, s_log_desc)   SETUPD__GRP( multi_scale, multi_scale_##m_bind_id, m_type, s_log_desc )
#define _SETPR_MULTI(m_bind_id, m_type, s_log_desc)   __SETPR_GRP( multi_scale, multi_scale_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_MULTI(m_member_id)				    UPDATE_SHADER( multi_scale_##m_member_id )
#pragma endregion _multi_scale_helper_macros_

#define UPDATE_MULTI_SCALE_TEXTURING() UPDATE_GROUP(multi_scale)

#define PRIV_MULTI_SCALE_TEXTURING_VARS()\
	GROUP_VARS(multi_scale)\
	VAR_MULTI(texture,			int,	0)\
	VAR_MULTI(micro_size,		float,	0.3f)\
	VAR_MULTI(macro_size,		float,	0.3f)\
	VAR_MULTI(far,				float,	170.0f)\
	VAR_MULTI(near,				float,	100.0f)\
	VAR_MULTI(enabled,			bool,	false)

#define PUBLIC_MULTI_SCALE_TEXTURING_FUNCS()\
	GETR_MULTI(texture,			int)\
	GETR_MULTI(micro_size,		float)\
	GETR_MULTI(macro_size,		float)\
	GETR_MULTI(far,				float)\
	GETR_MULTI(near,			float)\
	GETR_MULTI(enabled,			bool)

#define BIND_MULTI_SCALE_TEXTURING_VARS() \
	BIND_MULTI(enabled,			enabled)\
	BIND_MULTI(texture,			layer)\
	BIND_MULTI(near,			range)\
	BIND_MULTI(far,				range)\
	BIND_MULTI(micro_size,		size)\
	BIND_MULTI(macro_size,		size)

#define PROPS_MULTI_SCALE_TEXTURING()\
	ADD_GROUP("Multi Stage Texturing Scaling","multi_scale_");\
	PROP_MULTI(enabled,				BOOL,	NONE)\
	PROP_MULTI(texture,				INT,	RANGE, "0, 31, 1")\
	PROP_MULTI(far,					FLOAT,	RANGE, "0.0, 1000.0, 0.1")\
	PROP_MULTI(near,				FLOAT,	RANGE, "0.0, 1000.0, 0.1")\
	PROP_MULTI(micro_size,			FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	PROP_MULTI(macro_size,			FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	ADD_INLINE_HELP(multi_scale, Multi Stage Texturing Scaling, About Multi Stage Texturing)

#define MAKE_MULTI_SCALE_FUNCTIONS()\
	UPDATE_GRP_START(multi_scale)\
		_UPDSH_MULTI(texture)\
		_UPDSH_MULTI(micro_size)\
		_UPDSH_MULTI(macro_size)\
		_UPDSH_MULTI(near)\
		_UPDSH_MULTI(far)\
	UPDATE_GRP_END()\
	SETUPD_MULTI(enabled,		bool,	"Enable dual/tri texture scaling: ")\
	_SETPR_MULTI(texture,		int,	"Multi Scale Texture: ")\
	_SETPR_MULTI(micro_size,	float,	"Multi Scale Micro Size: ")\
	_SETPR_MULTI(macro_size,	float,	"Multi Scale Macro Size: ")\
	_SETPR_MULTI(near,			float,	"Dual Scale Near Range: ")\
	_SETPR_MULTI(far,			float,	"Dual Scale Far Range: ")

#pragma endregion _MULTI_SCALING_
// ################################################################################
#pragma region _AUTO_SHADER_
// *****************
// ** AUTO_SHADER **
// *****************

#pragma region _HELP_
#define HELP_AUTO_SHADER()\
	ADD_HELP_TOPIC_DECL(auto_shader, R"(Enables selecting two texture IDs that will automatically be applied to the terrain based upon slope.)" )
#pragma endregion _HELP_

#pragma region _auto_shader_helper_macros_
#define GETR_AUTOS(m_bind_id, m_type) GSTR(auto_shader_##m_bind_id, m_type)
#define  VAR_AUTOS(m_bind_id, m_type, m_value) VARR(auto_shader_##m_bind_id, m_type##, m_value)
#define PROP_AUTOS(m_member_id, m_var_type, ...) __PROP_GENGRP( auto_shader, m_member_id, m_var_type, __VA_ARGS__ )
#define BIND_AUTOS(m_bind_id, m_param_label) ADD_BIND(auto_shader_##m_bind_id, m_param_label)
#define SETUPD_AUTOS(m_bind_id, m_type, s_log_desc) SETUPD__GRP(auto_shader, auto_shader_##m_bind_id, m_type, s_log_desc)
#define _SETPR_AUTOS(m_bind_id, m_type, s_log_desc) __SETPR_GRP(auto_shader, auto_shader_##m_bind_id, m_type, s_log_desc)
#define _UPDSH_AUTOS(m_member_id) UPDATE_SHADER(auto_shader_##m_member_id)
#pragma endregion _auto_shader_helper_macros_

#define UPDATE_AUTO_SHADER() UPDATE_GROUP(auto_shader)

#define PRIV_AUTO_SHADER_VARS()\
	GROUP_VARS(auto_shader)\
	VAR_AUTOS(enabled,			bool,	false)\
	VAR_AUTOS(slope,			float,	1.0f)\
	VAR_AUTOS(height_reduction,	float,	1.0f)\
	VAR_AUTOS(base_texture,		int,	0)\
	VAR_AUTOS(overlay_texture,	int,	0)

#define PUBLIC_AUTO_SHADER_FUNCS()\
	GETR_AUTOS(enabled,			bool)\
	GETR_AUTOS(slope,			float)\
	GETR_AUTOS(height_reduction,float)\
	GETR_AUTOS(base_texture,	int)\
	GETR_AUTOS(overlay_texture, int)

#define BIND_AUTO_SHADER_VARS() \
	BIND_AUTOS(enabled,				enabled)\
	BIND_AUTOS(base_texture,		layer)\
	BIND_AUTOS(overlay_texture,		layer)\
	BIND_AUTOS(height_reduction,	height)\
	BIND_AUTOS(slope,				slope)

#define PROPS_AUTO_SHADER()\
	ADD_GROUP("Auto Texture By Slope", "auto_shader_");\
	PROP_AUTOS(enabled,				BOOL,	NONE)\
	PROP_AUTOS(slope,				FLOAT,	RANGE, "0.01, 10.0, 0.01")\
	PROP_AUTOS(height_reduction,	FLOAT,	RANGE, "-0.50, 1.0, 0.01")\
	PROP_AUTOS(base_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_AUTOS(overlay_texture,		INT,	RANGE, "0, 31, 1")\
	ADD_INLINE_HELP(auto_shader, Auto Texture By Slope, About Auto Texturing)

#define MAKE_AUTO_SHADER_FUNCTIONS() \
	UPDATE_GRP_START(auto_shader)\
		_UPDSH_AUTOS(slope)\
		_UPDSH_AUTOS(height_reduction)\
		_UPDSH_AUTOS(base_texture)\
		_UPDSH_AUTOS(overlay_texture)\
	UPDATE_GRP_END()\
	SETUPD_AUTOS(enabled,			bool,	"Enable auto shader: ")\
	_SETPR_AUTOS(slope,				float,	"Auto Shader Slope: ")\
	_SETPR_AUTOS(height_reduction,	float,	"Auto Shader Height Reduction: ")\
	_SETPR_AUTOS(base_texture,		int,	"Auto Shader Base Texture: ")\
	_SETPR_AUTOS(overlay_texture,	int,	"Auto Shader Overlay Texture: ")
#pragma endregion _AUTO_SHADER_
// ################################################################################
#pragma region _WORLD_NOISE_
// *****************
// ** WORLD_NOISE **
// *****************

#pragma region _HELP_
#define HELP_WORLD_NOISE()\
	ADD_HELP_TOPIC_DECL(world_noise, R"(Terrain3D can automatically generate a background world of rolling hills, plains and mountains if you'd like.  You can adjust the overall size of the landforms, their maximum height, a height/position offset, and how detailed they are with min/max octaves.  Take care you don't raise octaves so much it impacts frame rate.)")
#pragma endregion _HELP_

#pragma region _world_noise_helper_macros_
#define   GETR_WORLD(m_bind_id, m_type)					     GSTR( world_noise_##m_bind_id, m_type )
#define    VAR_WORLD(m_bind_id, m_type, m_value)		     VARR( world_noise_##m_bind_id, m_type##, m_value )
#define   PROP_WORLD(m_member_id, m_var_type, ...)  __PROP_GENGRP( world_noise, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_WORLD(m_bind_id, m_param_label)		     ADD_BIND( world_noise_##m_bind_id, m_param_label )
#define SETUPD_WORLD(m_bind_id, m_type, s_log_desc)	  SETUPD__GRP( world_noise, world_noise_##m_bind_id, m_type, s_log_desc )
#define _SETPR_WORLD(m_bind_id, m_type, s_log_desc)	  __SETPR_GRP( world_noise, world_noise_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_WORLD(m_member_id)				    UPDATE_SHADER( world_noise_##m_member_id )
#pragma endregion _world_noise_helper_macros_

#define UPDATE_WORLD_NOISE() UPDATE_GROUP(world_noise)

#define PRIV_WORLD_NOISE_VARS()\
	GROUP_VARS(world_noise)\
	VAR_WORLD(max_octaves,		int,	4)\
	VAR_WORLD(min_octaves,		int,	2)\
	VAR_WORLD(lod_distance,		float,	7500.0f)\
	VAR_WORLD(scale,			float,	5.0f)\
	VAR_WORLD(height,			float,	64.0f)\
	VAR_WORLD(offset,			Vector3,Vector3())\
	VAR_WORLD(blend_near,		float,	0.5f)\
	VAR_WORLD(blend_far,		float,	1.0f)

#define PUBLIC_WORLD_NOISE_FUNCS()\
	GETR_WORLD(max_octaves,		int)\
	GETR_WORLD(min_octaves,		int)\
	GETR_WORLD(lod_distance,	float)\
	GETR_WORLD(scale,			float)\
	GETR_WORLD(height,			float)\
	GETR_WORLD(offset,			Vector3)\
	GETR_WORLD(blend_near,		float)\
	GETR_WORLD(blend_far,		float)

#define BIND_WORLD_NOISE_VARS() \
	BIND_WORLD(max_octaves,			octaves)\
	BIND_WORLD(min_octaves,			octaves)\
	BIND_WORLD(lod_distance,		distance)\
	BIND_WORLD(scale,				size)\
	BIND_WORLD(height,				height)\
	BIND_WORLD(offset,				offset)\
	BIND_WORLD(blend_near,			range)\
	BIND_WORLD(blend_far,			range)

#define PROPS_WORLD_NOISE()\
	ADD_GROUP("Noise Generated Background World", "world_noise_");\
	PROP_WORLD(max_octaves,			INT,	RANGE, "0, 15, 1")\
	PROP_WORLD(min_octaves,			INT,	RANGE, "0, 15, 1")\
	PROP_WORLD(lod_distance,		FLOAT,	RANGE, "0.0, 40000.0, 1.0")\
	PROP_WORLD(scale,				FLOAT,	RANGE, "0.25, 20.0, 0.01")\
	PROP_WORLD(height,				FLOAT,	RANGE, "0.0, 1000.0, 0.1")\
	PROP_WORLD(offset,				VECTOR3,NONE)\
	PROP_WORLD(blend_near,			FLOAT,	RANGE, "0.0, 0.95, 0.01")\
	PROP_WORLD(blend_far,			FLOAT,	RANGE, "0.05, 1.0, 0.01")\
	ADD_INLINE_HELP(world_noise, Noise Generated Background World, About Noise Generated Backgrounds)

#define MAKE_WORLD_NOISE_FUNCTIONS() \
	UPDATE_GRP_START_CON(world_noise, _world_background >= NOISE_1)\
		_UPDSH_WORLD(max_octaves)\
		_UPDSH_WORLD(min_octaves)\
		_UPDSH_WORLD(lod_distance)\
		_UPDSH_WORLD(scale)\
		_UPDSH_WORLD(height)\
		_UPDSH_WORLD(offset)\
		_UPDSH_WORLD(blend_near)\
		_UPDSH_WORLD(blend_far)\
	UPDATE_GRP_END()\
	_SETPR_WORLD(max_octaves,	int,	"World Noise Max Octaves: ")\
	_SETPR_WORLD(min_octaves,	int,	"World Noise Max Octaves: ")\
	_SETPR_WORLD(lod_distance,	float,	"World Noise LOD Distance: ")\
	_SETPR_WORLD(scale,			float,	"World Noise Scale: ")\
	_SETPR_WORLD(height,		float,	"World Noise Height: ")\
	_SETPR_WORLD(offset,		Vector3,"World Noise Offset: ")\
	_SETPR_WORLD(blend_near,	float,	"World Noise Blend Near: ")\
	_SETPR_WORLD(blend_far,		float,	"World Noise Blend Far: ")

#pragma endregion _WORLD_NOISE_
// ################################################################################
#pragma region _NOISE_TINT_
// ****************
// ** NOISE_TINT **
// ****************

#pragma region _HELP_
#define HELP_NOISE_TINT()\
	ADD_HELP_TOPIC_DECL(noise_tint, R"(Todo: Add Noise Tint Help)")
#pragma endregion _HELP_

#pragma region _noise_tint_helper_macros_
#define   GETR_NTINT(m_bind_id, m_type)					     GSTR( noise_tint_##m_bind_id, m_type )
#define    VAR_NTINT(m_bind_id, m_type, m_value)		     VARR( noise_tint_##m_bind_id, m_type##, m_value )
#define   PROP_NTINT(m_member_id, m_var_type, ...)  __PROP_GENGRP( noise_tint, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_NTINT(m_bind_id, m_param_label)		     ADD_BIND( noise_tint_##m_bind_id, m_param_label )
#define SETUPD_NTINT(m_bind_id, m_type, s_log_desc)	  SETUPD__GRP( noise_tint, noise_tint_##m_bind_id, m_type, s_log_desc )
#define _SETPR_NTINT(m_bind_id, m_type, s_log_desc)	  __SETPR_GRP( noise_tint, noise_tint_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_NTINT(m_member_id)				    UPDATE_SHADER( noise_tint_##m_member_id )
#pragma endregion _noise_tint_helper_macros_

#define UPDATE_NOISE_TINT() UPDATE_GROUP(noise_tint)

#define PRIV_NOISE_TINT_VARS()\
	GROUP_VARS(noise_tint)\
	VAR_NTINT(macro_variation1,	Color,	Color())\
	VAR_NTINT(macro_variation2,	Color,	Color())\
	VAR_NTINT(noise1_scale,		float,	0.04f)\
	VAR_NTINT(noise1_angle,		float,	0.0f)\
	VAR_NTINT(noise1_offset,	Vector2,Vector2())\
	VAR_NTINT(noise2_scale,		float,	0.04f)\
	VAR_NTINT(noise3_scale,		float,	0.04f)

#define PUBLIC_NOISE_TINT_FUNCS()\
	GETR_NTINT(macro_variation1,	Color)\
	GETR_NTINT(macro_variation2,	Color)\
	GETR_NTINT(noise1_scale,		float)\
	GETR_NTINT(noise1_angle,		float)\
	GETR_NTINT(noise1_offset,		Vector2)\
	GETR_NTINT(noise2_scale,		float)\
	GETR_NTINT(noise3_scale,		float)

#define BIND_NOISE_TINT_VARS() \
	BIND_NTINT(macro_variation1,	color)\
	BIND_NTINT(macro_variation2,	color)\
	BIND_NTINT(noise1_scale,		size)\
	BIND_NTINT(noise1_angle,		radians)\
	BIND_NTINT(noise1_offset,		offset)\
	BIND_NTINT(noise2_scale,		size)\
	BIND_NTINT(noise3_scale,		size)

#define PROPS_NOISE_TINT()\
	ADD_GROUP("Tint By Noise", "noise_tint_");\
	PROP_NTINT(macro_variation1,	COLOR,	NONE)\
	PROP_NTINT(macro_variation2,	COLOR,	NONE)\
	PROP_NTINT(noise1_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	PROP_NTINT(noise1_angle,		FLOAT,	RANGE, "0.25, 20.0, 0.01")\
	PROP_NTINT(noise1_offset,		VECTOR2,NONE)\
	PROP_NTINT(noise2_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	PROP_NTINT(noise3_scale,		FLOAT,	RANGE, "0.001, 1.0, 0.001")\
	ADD_INLINE_HELP(noise_tint, Tint By Noise, About Global Tint By Noise)

#define MAKE_NOISE_TINT_FUNCTIONS() \
	UPDATE_GRP_START_CON(noise_tint, true == true)\
		_UPDSH_NTINT(macro_variation1)\
		_UPDSH_NTINT(macro_variation2)\
		_UPDSH_NTINT(noise1_scale)\
		_UPDSH_NTINT(noise1_angle)\
		_UPDSH_NTINT(noise1_offset)\
		_UPDSH_NTINT(noise2_scale)\
		_UPDSH_NTINT(noise3_scale)\
	UPDATE_GRP_END()\
	_SETPR_NTINT(macro_variation1,	Color,	"Tint Noise Macro Variation Color #1: ")\
	_SETPR_NTINT(macro_variation2,	Color,	"Tint Noise Macro Variation Color #2: ")\
	_SETPR_NTINT(noise1_scale,		float,	"Tint Noise Phase 1 Scale: ")\
	_SETPR_NTINT(noise1_angle,		float,	"Tint Noise Phase 1 Angle: ")\
	_SETPR_NTINT(noise1_offset,		Vector2,"Tint Noise Phase 1 Offset: ")\
	_SETPR_NTINT(noise2_scale,		float,	"Tint Noise Phase 2 Scale: ")\
	_SETPR_NTINT(noise3_scale,		float,	"Tint Noise Phase 3 Scale: ")

#pragma endregion _NOISE_TINT_
// ################################################################################
#pragma region _UV_DISTORTION_

// *******************
// ** UV_DISTORTION **
// *******************

#pragma region _HELP_
#define HELP_UVDIST()\
	ADD_HELP_TOPIC_DECL(uv_distortion, R"(UV Distortion slightly (or drastically) shifts the textures around at a vertex level in a random way based on where that point in space is.  You can adjust the size and power of the effect.)")
#pragma endregion _HELP_

#pragma region _uv_distortion_helper_macros_
#define   GETR_UVDIST(m_bind_id, m_type)					  GSTR( uv_distortion_##m_bind_id, m_type )
#define    VAR_UVDIST(m_bind_id, m_type, m_value)			  VARR( uv_distortion_##m_bind_id, m_type##, m_value )
#define   PROP_UVDIST(m_member_id, m_var_type, ...)  __PROP_GENGRP( uv_distortion, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_UVDIST(m_bind_id, m_param_label)	 		  ADD_BIND( uv_distortion_##m_bind_id, m_param_label )
#define SETUPD_UVDIST(m_bind_id, m_type, s_log_desc)   SETUPD__GRP( uv_distortion, uv_distortion_##m_bind_id, m_type, s_log_desc )
#define _SETPR_UVDIST(m_bind_id, m_type, s_log_desc)   __SETPR_GRP( uv_distortion, uv_distortion_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_UVDIST(m_member_id)					 UPDATE_SHADER( uv_distortion_##m_member_id )
#pragma endregion _uv_distortion_helper_macros_

#define UPDATE_UV_DISTORTION() UPDATE_GROUP(uv_distortion)

#define PRIV_UV_DISTORTION_VARS()\
	GROUP_VARS(uv_distortion)\
	VAR_UVDIST(enabled,			bool,	false)\
	VAR_UVDIST(size,			float,	1.0f)\
	VAR_UVDIST(power,			float,	1.0f)

#define PUBLIC_UV_DISTORTION_FUNCS()\
	GETR_UVDIST(enabled,		bool)\
	GETR_UVDIST(size,			float)\
	GETR_UVDIST(power,			float)

#define BIND_UV_DISTORTION_VARS() \
	BIND_UVDIST(enabled,			enabled)\
	BIND_UVDIST(size,				scale)\
	BIND_UVDIST(power,				power)

#define PROPS_UV_DISTORTION()\
	ADD_GROUP("UV Distortion", "uv_distortion_");\
	PROP_UVDIST(enabled,	BOOL,	NONE)\
	PROP_UVDIST(size,		FLOAT,	RANGE, "0.001,100.0,0.01")\
	PROP_UVDIST(power,		FLOAT,	RANGE, "0.001,100.0,0.01")\
	ADD_INLINE_HELP(uv_distortion, UV Distortion, About UV Distortion)

#define MAKE_UV_DISTORTION_FUNCTIONS() \
	UPDATE_GRP_START(uv_distortion)\
		_UPDSH_UVDIST(size)\
		_UPDSH_UVDIST(power)\
	UPDATE_GRP_END()\
	SETUPD_UVDIST(enabled,	bool,	"Enable UV Distortion: ")\
	_SETPR_UVDIST(size,		float,	"UV Distortion Size: ")\
	_SETPR_UVDIST(power,	float,	"UV Distortion Power: ")

#pragma endregion _UV_DISTORTION_
// ################################################################################
#pragma region _DEBUG_VIEWS_
// *****************
// ** DEBUG_VIEWS **
// *****************

#pragma region _HELP_
#define HELP_DEBUG()\
	ADD_HELP_TOPIC_DECL(debug_views, R"(There are multiple modes of viewing the terrain for debuging different characteristics.

[ Autoshader ] Display the area designated for use by the autoshader, which shows materials based upon slope.

[ Checkered ] Shows a checkerboard display using a shader rendered pattern. This is turned on if the Texture List is empty. Note that when a blank texture slot is created, a 1k checkerboard texture is generated and stored in the texture slot. That takes VRAM. The two patterns have a slightly different scale.

[ Colormap ] Places the color map in the albedo channel.

[ Control Blend ] Albedo shows the blend value used to blend the base and overlay textures as greyscale. This is especially helpful to see how the noise texture adjusts the blending edges.

[ Control Texture ] Albedo shows the base and overlay texture indices defined by the control map. Red pixels indicate the base texture, with brightness showing texture ids 0 to 31. Green pixels indicate the overlay texture. Yellow indicates both.

[ Grey ] Albedo is set to 0.2 grey.

[ Heightmap ] Albedo is a white to black gradient depending on height. The gradient is scaled to a height of 300, so above that or far below 0 will be all white or black.

[ Navigation ] Displays the area designated for generating the navigation mesh.

[ Roughmap ] Albedo is set to the roughness modification map as grey scale. Middle grey, 0.5 means no roughness modification. Black would be high gloss while white is very rough.

[ Texture Height ] Albedo is set to the painted Height textures.

[ Texture Normal ] Albedo is set to the painted Normal textures.

[ Texture Rough ] Albedo is set to the painted Roughness textures. This is different from the roughness modification map above.

[ Vertex Grid ] Show a grid on the vertices, overlaying any above shader.)")
#pragma endregion _HELP_

#define GETR_DEBUG(m_bind_id) GSTR(debug_view_##m_bind_id, bool)
#define VAR_DEBUG(m_bind_id) VARR(debug_view_##m_bind_id, bool, false)
#define PROP_DEBUG(m_member_id) __PROP_GENGRP( debug_view, m_member_id, BOOL, NONE )
#define BIND_DEBUG(m_bind_id) ADD_BIND(debug_view_##m_bind_id, enabled) 

#define PRIV_DEBUG_VIEW_VARS()\
	VAR_DEBUG(navigation)\
	VAR_DEBUG(checkered)\
	VAR_DEBUG(grey)\
	VAR_DEBUG(heightmap)\
	VAR_DEBUG(colormap)\
	VAR_DEBUG(roughmap)\
	VAR_DEBUG(control_texture)\
	VAR_DEBUG(control_blend)\
	VAR_DEBUG(autoshader)\
	VAR_DEBUG(holes)\
	VAR_DEBUG(texture_height)\
	VAR_DEBUG(texture_normal)\
	VAR_DEBUG(texture_rough)\
	VAR_DEBUG(vertex_grid)

#define PUBLIC_DEBUG_VIEW_FUNCS()\
	GETR_DEBUG(navigation)\
	GETR_DEBUG(checkered)\
	GETR_DEBUG(grey)\
	GETR_DEBUG(heightmap)\
	GETR_DEBUG(colormap)\
	GETR_DEBUG(roughmap)\
	GETR_DEBUG(control_texture)\
	GETR_DEBUG(control_blend)\
	GETR_DEBUG(autoshader)\
	GETR_DEBUG(holes)\
	GETR_DEBUG(texture_height)\
	GETR_DEBUG(texture_normal)\
	GETR_DEBUG(texture_rough)\
	GETR_DEBUG(vertex_grid)\

#define BIND_DEBUG_VIEW_VARS() \
	BIND_DEBUG(checkered)\
	BIND_DEBUG(grey)\
	BIND_DEBUG(heightmap)\
	BIND_DEBUG(colormap)\
	BIND_DEBUG(roughmap)\
	BIND_DEBUG(control_texture)\
	BIND_DEBUG(control_blend)\
	BIND_DEBUG(autoshader)\
	BIND_DEBUG(holes)\
	BIND_DEBUG(navigation)\
	BIND_DEBUG(texture_height)\
	BIND_DEBUG(texture_normal)\
	BIND_DEBUG(texture_rough)\
	BIND_DEBUG(vertex_grid)

#define PROPS_DEBUG_VIEW()\
	ADD_GROUP("Debug Views", "debug_view_");\
	PROP_DEBUG(checkered)\
	PROP_DEBUG(grey)\
	PROP_DEBUG(heightmap)\
	PROP_DEBUG(colormap)\
	PROP_DEBUG(roughmap)\
	PROP_DEBUG(control_texture)\
	PROP_DEBUG(control_blend)\
	PROP_DEBUG(autoshader)\
	PROP_DEBUG(holes)\
	PROP_DEBUG(navigation)\
	PROP_DEBUG(texture_height)\
	PROP_DEBUG(texture_normal)\
	PROP_DEBUG(texture_rough)\
	PROP_DEBUG(vertex_grid)\
	ADD_INLINE_HELP(debug_views, Debug Views, About Debug View Modes)

#pragma endregion _DEBUG_VIEWS_ 
// ################################################################################


// ## MISC ##

// This help entry for shader override is important but currently the shader override group
// itself is not fully managed, so to make sure this is defined, it's here with the others.
#define __help_defined_for_shader_override
#define HELP_SHADER_OVERRIDE()\
	ADD_HELP_TOPIC_DECL(shader_override, R"( If shader_override_enabled is true and this Shader is valid, the material will use this custom shader code. If this is blank when you enable the override, the system will generate a shader with the current settings. So if you have a debug view enabled, the generated shader will have all of that code. A visual shader will also work here. However we only generate a text based shader so currently a visual shader needs to be constructed with the base code before it can work.)" )

#endif