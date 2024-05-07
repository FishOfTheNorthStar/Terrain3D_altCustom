#pragma once

#ifndef TERRAIN3D_AUTO_SHADER_H
#define TERRAIN3D_AUTO_SHADER_H

//Code Templates for Terrain3D Managed GLSL/Godot AUTO_SHADER Properties

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
#endif