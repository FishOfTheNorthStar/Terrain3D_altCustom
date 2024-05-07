#pragma once

#ifndef TERRAIN3D_FEATURE_SHADER_H
#define TERRAIN3D_FEATURE_SHADER_H

//Code Templates for Terrain3D Managed GLSL/Godot FEATURE_SHADER Properties

// ################################################################################
#pragma region _FEATURE_SHADER_
// *****************
// ** FEATURE_SHADER **
// *****************

#pragma region _HELP_
#define HELP_FEATURE_SHADER()\
	ADD_HELP_TOPIC_DECL(feature_shader, R"(Enables selecting two texture IDs that will automatically be applied to the terrain based upon slope.)" )
#pragma endregion _HELP_

#pragma region _feature_shader_helper_macros_
#define GETR_FEATS(m_bind_id, m_type) GSTR(feature_shader_##m_bind_id, m_type)
#define  VAR_FEATS(m_bind_id, m_type, m_value) VARR(feature_shader_##m_bind_id, m_type##, m_value)
#define PROP_FEATS(m_member_id, m_var_type, ...) __PROP_GENGRP( feature_shader, m_member_id, m_var_type, __VA_ARGS__ )
#define BIND_FEATS(m_bind_id, m_param_label) ADD_BIND(feature_shader_##m_bind_id, m_param_label)
#define SETUPD_FEATS(m_bind_id, m_type, s_log_desc) SETUPD__GRP(feature_shader, feature_shader_##m_bind_id, m_type, s_log_desc)
#define _SETPR_FEATS(m_bind_id, m_type, s_log_desc) __SETPR_GRP(feature_shader, feature_shader_##m_bind_id, m_type, s_log_desc)
#define _UPDSH_FEATS(m_member_id) UPDATE_SHADER(feature_shader_##m_member_id)
#pragma endregion _feature_shader_helper_macros_

#define UPDATE_FEATURE_SHADER() UPDATE_GROUP(feature_shader)

#define PRIV_FEATURE_SHADER_VARS()\
	GROUP_VARS(feature_shader)\
	VAR_FEATS(enabled,				bool,	false)\
	VAR_FEATS(slopes,				Vector4, Vector4(0.52, 0.585, 0.96, 0.985))\
	VAR_FEATS(height_bias,			float,	1.0f)\
	VAR_FEATS(vertical_texture,		int,	0)\
	VAR_FEATS(hazard_texture,		int,	0)\
	VAR_FEATS(obstruction_texture,	int,	0)\
	VAR_FEATS(flat_texture,			int,	0)\
	VAR_FEATS(flat_inner_texture,	int,	0)\
	VAR_FEATS(puddle_texture,		int,	0)\
	VAR_FEATS(vertical_alt_texture,		int,	0)\
	VAR_FEATS(hazard_alt_texture,		int,	0)\
	VAR_FEATS(obstruction_alt_texture,	int,	0)\
	VAR_FEATS(flat_alt_texture,			int,	0)\
	VAR_FEATS(flat_alt_inner_texture,	int,	0)\
	VAR_FEATS(puddle_alt_texture,		int,	0)

#define PUBLIC_FEATURE_SHADER_FUNCS()\
	GETR_FEATS(enabled,				bool)\
	GETR_FEATS(slopes,				Vector4)\
	GETR_FEATS(height_bias,			float )\
	GETR_FEATS(vertical_texture,	int )\
	GETR_FEATS(hazard_texture,		int )\
	GETR_FEATS(obstruction_texture,	int )\
	GETR_FEATS(flat_texture,		int )\
	GETR_FEATS(flat_inner_texture,	int )\
	GETR_FEATS(puddle_texture,		int )\
	GETR_FEATS(vertical_alt_texture,	int)\
	GETR_FEATS(hazard_alt_texture,		int)\
	GETR_FEATS(obstruction_alt_texture,	int)\
	GETR_FEATS(flat_alt_texture,		int)\
	GETR_FEATS(flat_alt_inner_texture,	int)\
	GETR_FEATS(puddle_alt_texture,		int)

#define BIND_FEATURE_SHADER_VARS() \
	BIND_FEATS(enabled,				enabled)\
	BIND_FEATS(slopes,				threshholds)\
	BIND_FEATS(height_bias,			bias)\
	BIND_FEATS(vertical_texture,	layer )\
	BIND_FEATS(hazard_texture,		layer )\
	BIND_FEATS(obstruction_texture,	layer )\
	BIND_FEATS(flat_texture,		layer )\
	BIND_FEATS(flat_inner_texture,	layer )\
	BIND_FEATS(puddle_texture,		layer )\
	BIND_FEATS(vertical_alt_texture,	layer )\
	BIND_FEATS(hazard_alt_texture,		layer )\
	BIND_FEATS(obstruction_alt_texture,	layer )\
	BIND_FEATS(flat_alt_texture,		layer )\
	BIND_FEATS(flat_alt_inner_texture,	layer )\
	BIND_FEATS(puddle_alt_texture,		layer )

#define PROPS_FEATURE_SHADER()\
	ADD_GROUP("Texture By Feature", "feature_shader_");\
	PROP_FEATS(enabled,				BOOL,	NONE)\
	PROP_FEATS(slopes,				VECTOR4,NONE)\
	PROP_FEATS(height_bias,			FLOAT,  RANGE, "-1.0, 1.0, 0.001")\
	PROP_FEATS(vertical_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(hazard_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(obstruction_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(flat_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(flat_inner_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(puddle_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(vertical_alt_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(hazard_alt_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(obstruction_alt_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(flat_alt_texture,		INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(flat_alt_inner_texture,	INT,	RANGE, "0, 31, 1")\
	PROP_FEATS(puddle_alt_texture,		INT,	RANGE, "0, 31, 1")\
	ADD_INLINE_HELP(feature_shader, Texture By Feature, About Feature Shader)

#define MAKE_FEATURE_SHADER_FUNCTIONS() \
	UPDATE_GRP_START(feature_shader)\
		_UPDSH_FEATS(slopes)\
		_UPDSH_FEATS(height_bias)\
		_UPDSH_FEATS(vertical_texture)\
		_UPDSH_FEATS(hazard_texture)\
		_UPDSH_FEATS(obstruction_texture)\
		_UPDSH_FEATS(flat_texture)\
		_UPDSH_FEATS(flat_inner_texture)\
		_UPDSH_FEATS(puddle_texture)\
		_UPDSH_FEATS(vertical_alt_texture)\
		_UPDSH_FEATS(hazard_alt_texture)\
		_UPDSH_FEATS(obstruction_alt_texture)\
		_UPDSH_FEATS(flat_alt_texture)\
		_UPDSH_FEATS(flat_alt_inner_texture)\
		_UPDSH_FEATS(puddle_alt_texture)\
	UPDATE_GRP_END()\
	SETUPD_FEATS(enabled,				bool,	"Enable feature shader: ")\
	_SETPR_FEATS(slopes,				Vector4,"Feature Shader Slopes: ")\
	_SETPR_FEATS(height_bias,			float,	"Feature Shader Height Bias: ")\
	_SETPR_FEATS(vertical_texture,		int,	"Feature Shader Vertical Texture: ")\
	_SETPR_FEATS(hazard_texture,		int,	"Feature Shader Hazard Texture: ")\
	_SETPR_FEATS(obstruction_texture,	int,	"Feature Shader Obstruction Texture: ")\
	_SETPR_FEATS(flat_texture,			int,	"Feature Shader Flat Texture: ")\
	_SETPR_FEATS(flat_inner_texture,	int,	"Feature Shader Flat-Inner Texture: ")\
	_SETPR_FEATS(puddle_texture,		int,	"Feature Shader Puddle Texture: ")\
	_SETPR_FEATS(vertical_alt_texture,		int,	"Feature Shader Alternate Vertical Texture: ")\
	_SETPR_FEATS(hazard_alt_texture,		int,	"Feature Shader Alternate Hazard Texture: ")\
	_SETPR_FEATS(obstruction_alt_texture,	int,	"Feature Shader Alternate Obstruction Texture: ")\
	_SETPR_FEATS(flat_alt_texture,			int,	"Feature Shader Alternate Flat Texture: ")\
	_SETPR_FEATS(flat_alt_inner_texture,	int,	"Feature Shader Alternate Flat-Inner Texture: ")\
	_SETPR_FEATS(puddle_alt_texture,		int,	"Feature Shader Alternate Puddle Texture: ")

#pragma endregion _FEATURE_SHADER_
// ################################################################################
#endif