#pragma once

#ifndef TERRAIN3D_VEGETATION_H
#define TERRAIN3D_VEGETATION_H

//Code Templates for Terrain3D Managed GLSL/Godot VEGETATION Properties

// ################################################################################
#pragma region _VEGETATION_

// ****************
// ** VEGETATION **
// ****************

#pragma region _HELP_
#define HELP_VEG()\
	ADD_HELP_TOPIC_DECL(vegetation, R"(UV Distortion slightly (or drastically) shifts the textures around at a vertex level in a random way based on where that point in space is.  You can adjust the size and height of the effect.)")
#pragma endregion _HELP_

#pragma region _vegetation_helper_macros_
#define   GETR_VEG(m_bind_id, m_type)				GSTR( vegetation_##m_bind_id, m_type )
#define    VAR_VEG(m_bind_id, m_type, m_value)		VARR( vegetation_##m_bind_id, m_type##, m_value )
#define   PROP_VEG(m_member_id, m_var_type, ...)	__PROP_GENGRP( vegetation, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_VEG(m_bind_id, m_param_label)	 	ADD_BIND( vegetation_##m_bind_id, m_param_label )
#define SETUPD_VEG(m_bind_id, m_type, s_log_desc)   SETUPD__GRP( vegetation, vegetation_##m_bind_id, m_type, s_log_desc )
#define _SETPR_VEG(m_bind_id, m_type, s_log_desc)   __SETPR_GRP( vegetation, vegetation_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_VEG(m_member_id)						UPDATE_SHADER( vegetation_##m_member_id )
#pragma endregion _vegetation_helper_macros_

#define UPDATE_VEGETATION() UPDATE_GROUP(vegetation)

#define PRIV_VEGETATION_VARS()\
	GROUP_VARS(vegetation)\
	VAR_VEG(enabled,			bool,	false)\
	VAR_VEG(size,				float,	1.0f)\
	VAR_VEG(raise_enabled,		bool,	false)\
	VAR_VEG(height,				float,	1.0f)

#define PUBLIC_VEGETATION_FUNCS()\
	GETR_VEG(enabled,			bool)\
	GETR_VEG(size,				float)\
	GETR_VEG(raise_enabled,		bool)\
	GETR_VEG(height,			float)

#define BIND_VEGETATION_VARS() \
	BIND_VEG(enabled,			enabled)\
	BIND_VEG(size,				scale)\
	BIND_VEG(raise_enabled,		enabled)\
	BIND_VEG(height,			height)

#define PROPS_VEGETATION()\
	ADD_GROUP("Vegetation", "vegetation_");\
	PROP_VEG(enabled,			BOOL,	NONE)\
	PROP_VEG(size,				FLOAT,	RANGE, "0.0,1.0,0.01")\
	PROP_VEG(raise_enabled,		BOOL,	NONE)\
	PROP_VEG(height,			FLOAT,	RANGE, "0.0,5.0,0.01")\
	ADD_INLINE_HELP(vegetation, Vegetation, About Vegetation)

#define MAKE_VEGETATION_FUNCTIONS() \
	UPDATE_GRP_START(vegetation)\
		_UPDSH_VEG(size)\
		_UPDSH_VEG(height)\
	UPDATE_GRP_END()\
	SETUPD_VEG(enabled,			bool,	"Enable Vegetation: ")\
	_SETPR_VEG(size,			float,	"Vegetation Size: ")\
	SETUPD_VEG(raise_enabled,	bool,	"Vegetation Raise From Ground: ")\
	_SETPR_VEG(height,			float,	"Vegetation Height: ")

#pragma endregion _VEGETATION_
// ################################################################################
#endif