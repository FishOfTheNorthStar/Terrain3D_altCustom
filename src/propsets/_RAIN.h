#pragma once

#ifndef TERRAIN3D_RAIN_H
#define TERRAIN3D_RAIN_H

//Code Templates for Terrain3D Managed GLSL/Godot RAIN Properties

// ################################################################################
#pragma region _RAIN_

// *******************
// ** RAIN **
// *******************

#pragma region _HELP_
#define HELP_RAIN()\
	ADD_HELP_TOPIC_DECL(rain, R"(Rain gives surfaces more shine, a slightly darker albedo, and at high levels, fills in disturbances in the normal maps of horizontal surfaces.  Also it creates puddles in those surfaces (modulated by noise.x), if they are extremely close to perfectly flat.)")
#pragma endregion _HELP_

#pragma region _rain_helper_macros_
#define   GETR_RAIN(m_bind_id, m_type)				GSTR( rain_##m_bind_id, m_type )
#define    VAR_RAIN(m_bind_id, m_type, m_value)		VARR( rain_##m_bind_id, m_type##, m_value )
#define   PROP_RAIN(m_member_id, m_var_type, ...)	__PROP_GENGRP( rain, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_RAIN(m_bind_id, m_param_label)	 	ADD_BIND( rain_##m_bind_id, m_param_label )
#define SETUPD_RAIN(m_bind_id, m_type, s_log_desc)  SETUPD__GRP( rain, rain_##m_bind_id, m_type, s_log_desc )
#define _SETPR_RAIN(m_bind_id, m_type, s_log_desc)  __SETPR_GRP( rain, rain_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_RAIN(m_member_id)					UPDATE_SHADER( rain_##m_member_id )
#pragma endregion _rain_helper_macros_

#define UPDATE_RAIN() UPDATE_GROUP(rain)

#define PRIV_RAIN_VARS()\
	GROUP_VARS(rain)\
	VAR_RAIN(enabled,			bool,	true)\
	VAR_RAIN(current_level,		float,	0.15f)\
	VAR_RAIN(puddles_enabled,	bool,	true)\
	VAR_RAIN(puddles_size,		float,	0.10f)

#define PUBLIC_RAIN_FUNCS()\
	GETR_RAIN(enabled,			bool)\
	GETR_RAIN(current_level,	float)\
	GETR_RAIN(puddles_enabled,	bool)\
	GETR_RAIN(puddles_size,		float)

#define BIND_RAIN_VARS() \
	BIND_RAIN(enabled,			enabled)\
	BIND_RAIN(current_level,	scale)\
	BIND_RAIN(puddles_enabled,	enabled)\
	BIND_RAIN(puddles_size,		puddles_size)

#define PROPS_RAIN()\
	ADD_GROUP("Rain", "rain_");\
	PROP_RAIN(enabled,			BOOL,	NONE)\
	PROP_RAIN(current_level,	FLOAT,	RANGE, "0.0,1.0,0.01")\
	PROP_RAIN(puddles_enabled,	BOOL,	NONE)\
	PROP_RAIN(puddles_size,		FLOAT,	RANGE, "0.0,1.0,0.001")\
	ADD_INLINE_HELP(rain, Rain, About Rain Effects)

#define MAKE_RAIN_FUNCTIONS() \
	UPDATE_GRP_START(rain)\
		_UPDSH_RAIN(current_level)\
		_UPDSH_RAIN(puddles_size)\
	UPDATE_GRP_END()\
	SETUPD_RAIN(enabled,			bool,	"Enable Rain Effects: ")\
	_SETPR_RAIN(current_level,		float,	"Rain Current Level: ")\
	SETUPD_RAIN(puddles_enabled,	bool,	"Enable Rain Effects: ")\
	_SETPR_RAIN(puddles_size,		float,	"Puddle Size: ")

#pragma endregion _RAIN_
// ################################################################################
#endif