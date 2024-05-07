#pragma once

#ifndef TERRAIN3D_STRATA_GRADIENT_H
#define TERRAIN3D_STRATA_GRADIENT_H

//Code Templates for Terrain3D Managed GLSL/Godot STRATA_GRADIENT Properties

// ################################################################################
#pragma region _STRATA_GRADIENT_

// *******************
// ** STRATA_GRADIENT **
// *******************

#pragma region _HELP_
#define HELP_STRATA()\
	ADD_HELP_TOPIC_DECL(strata_gradient, R"(Strata gradients tint the ground variably based on elevation.  Different gradients can be applied to vertical and flat surfaces, and the amount of tinting to either can be adjusted.  The gradients repeat.)")
#pragma endregion _HELP_

#pragma region _strata_gradient_helper_macros_
#define   GETR_STRATA(m_bind_id, m_type)					  GSTR( strata_gradient_##m_bind_id, m_type )
#define    VAR_STRATA(m_bind_id, m_type, m_value)			  VARR( strata_gradient_##m_bind_id, m_type##, m_value )
#define   PROP_STRATA(m_member_id, m_var_type, ...)  __PROP_GENGRP( strata_gradient, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_STRATA(m_bind_id, m_param_label)	 		  ADD_BIND( strata_gradient_##m_bind_id, m_param_label )
#define SETUPD_STRATA(m_bind_id, m_type, s_log_desc)   SETUPD__GRP( strata_gradient, strata_gradient_##m_bind_id, m_type, s_log_desc )
#define _SETPR_STRATA(m_bind_id, m_type, s_log_desc)   __SETPR_GRP( strata_gradient, strata_gradient_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_STRATA(m_member_id)					 UPDATE_SHADER( strata_gradient_##m_member_id )
#pragma endregion _strata_gradient_helper_macros_

#define UPDATE_STRATA_GRADIENT() UPDATE_GROUP(strata_gradient)

#define PRIV_STRATA_GRADIENT_VARS()\
	GROUP_VARS(strata_gradient)\
	VAR_STRATA(enabled,			bool,	false)\
	VAR_STRATA(vertical_surface_scale,	float,	0.5f)\
	VAR_STRATA(vertical_power,			float,	1.0f)\
	VAR_STRATA(flat_surface_scale,		float,	6.4f)\
	VAR_STRATA(flat_power,				float,	1.0f)

#define PUBLIC_STRATA_GRADIENT_FUNCS()\
	GETR_STRATA(enabled,				bool)\
	GETR_STRATA(vertical_surface_scale,	float)\
	GETR_STRATA(vertical_power,			float)\
	GETR_STRATA(flat_surface_scale,		float)\
	GETR_STRATA(flat_power,				float)

#define BIND_STRATA_GRADIENT_VARS() \
	BIND_STRATA(enabled,				enabled)\
	BIND_STRATA(vertical_surface_scale,	scale)\
	BIND_STRATA(vertical_power,			power)\
	BIND_STRATA(flat_surface_scale,		scale)\
	BIND_STRATA(flat_power,				power)

#define PROPS_STRATA_GRADIENT()\
	ADD_GROUP("Strata Gradient", "strata_gradient_");\
	PROP_STRATA(enabled,	BOOL,	NONE)\
	PROP_STRATA(vertical_surface_scale,	FLOAT,	RANGE, "0.001,5.0,0.001")\
	PROP_STRATA(vertical_power,			FLOAT,	RANGE, "0.0,1.0,0.01")\
	PROP_STRATA(flat_surface_scale,		FLOAT,	RANGE, "0.001,20.0,0.001")\
	PROP_STRATA(flat_power,				FLOAT,	RANGE, "0.0,1.0,0.01")\
	ADD_INLINE_HELP(strata_gradient, Strata Gradient, About Strata Gradients)

#define MAKE_STRATA_GRADIENT_FUNCTIONS() \
	UPDATE_GRP_START(strata_gradient)\
		_UPDSH_STRATA(vertical_surface_scale)\
		_UPDSH_STRATA(vertical_power)\
		_UPDSH_STRATA(flat_surface_scale)\
		_UPDSH_STRATA(flat_power)\
	UPDATE_GRP_END()\
	SETUPD_STRATA(enabled,					bool,	"Enable Strata Gradient: ")\
	_SETPR_STRATA(vertical_surface_scale,	float,	"Strata Gradient Vertical Surface Size: ")\
	_SETPR_STRATA(vertical_power,			float,	"Strata Gradient Vertical Surface Power: ")\
	_SETPR_STRATA(flat_surface_scale,		float,	"Strata Gradient Flat Surface Size: ")\
	_SETPR_STRATA(flat_power,				float,	"Strata Gradient Flat Surface Power: ")

#pragma endregion _STRATA_GRADIENT_
// ################################################################################
#endif