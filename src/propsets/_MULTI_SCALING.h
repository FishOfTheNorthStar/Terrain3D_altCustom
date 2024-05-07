#pragma once

#ifndef TERRAIN3D_MULTI_SCALING_H
#define TERRAIN3D_MULTI_SCALING_H

//Code Templates for Terrain3D Managed GLSL/Godot MULTI_SCALING Properties

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
#endif