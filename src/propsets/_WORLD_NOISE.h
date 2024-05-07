#pragma once

#ifndef TERRAIN3D_WORLD_NOISE_H
#define TERRAIN3D_WORLD_NOISE_H

//Code Templates for Terrain3D Managed GLSL/Godot WORLD_NOISE Properties

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
#endif