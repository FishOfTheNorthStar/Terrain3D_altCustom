#pragma once

#ifndef TERRAIN3D_ADJUST_AORMS_H
#define TERRAIN3D_ADJUST_AORMS_H

//Code Templates for Terrain3D Managed GLSL/Godot ADJUST_AORMS Properties

// ################################################################################
#pragma region _ADJUST_AORMS_

// *******************
// ** ADJUST_AORMS **
// *******************

#pragma region _HELP_
#define HELP_AAORMS()\
	ADD_HELP_TOPIC_DECL(adjust_aorms, R"(Ambient Occlusion/Roughness/Metallic/Saturation adjustments change those factors up or down per material as controlled by it's User Data property. To-Do: outline which ones do what.  Currently it's X is hacky normal strength (??), Y is AO pow, Z and W are unused and spec has it's own material property already.  So this needs some work here.)")
#pragma endregion _HELP_

#pragma region _adjust_aorms_helper_macros_
#define   GETR_AAORMS(m_bind_id, m_type)					  GSTR( adjust_aorms_##m_bind_id, m_type )
#define    VAR_AAORMS(m_bind_id, m_type, m_value)			  VARR( adjust_aorms_##m_bind_id, m_type##, m_value )
#define   PROP_AAORMS(m_member_id, m_var_type, ...)  __PROP_GENGRP( adjust_aorms, m_member_id, m_var_type, __VA_ARGS__ )
#define   BIND_AAORMS(m_bind_id, m_param_label)	 		  ADD_BIND( adjust_aorms_##m_bind_id, m_param_label )
#define SETUPD_AAORMS(m_bind_id, m_type, s_log_desc)   SETUPD__GRP( adjust_aorms, adjust_aorms_##m_bind_id, m_type, s_log_desc )
#define _SETPR_AAORMS(m_bind_id, m_type, s_log_desc)   __SETPR_GRP( adjust_aorms, adjust_aorms_##m_bind_id, m_type, s_log_desc )
#define _UPDSH_AAORMS(m_member_id)					 UPDATE_SHADER( adjust_aorms_##m_member_id )
#pragma endregion _adjust_aorms_helper_macros_

#define UPDATE_ADJUST_AORMS() UPDATE_GROUP(adjust_aorms)

#define PRIV_ADJUST_AORMS_VARS()\
	GROUP_VARS(adjust_aorms)\
	VAR_AAORMS(enabled,			bool,	false)\
	VAR_AAORMS(ao_exp,			float,	1.0f)

#define PUBLIC_ADJUST_AORMS_FUNCS()\
	GETR_AAORMS(enabled,		bool)\
	GETR_AAORMS(ao_exp,			float)

#define BIND_ADJUST_AORMS_VARS() \
	BIND_AAORMS(enabled,			enabled)\
	BIND_AAORMS(ao_exp,				ao_exp)

#define PROPS_ADJUST_AORMS()\
	ADD_GROUP("Adjust AoRMS", "adjust_aorms_");\
	PROP_AAORMS(enabled,	BOOL,	NONE)\
	PROP_AAORMS(ao_exp,		FLOAT,	RANGE, "0.001,0.25,0.001")\
	ADD_INLINE_HELP(adjust_aorms, Adjust AoRMS, About Adjust AoRMS)

#define MAKE_ADJUST_AORMS_FUNCTIONS() \
	UPDATE_GRP_START(adjust_aorms)\
		_UPDSH_AAORMS(ao_exp)\
	UPDATE_GRP_END()\
	SETUPD_AAORMS(enabled,	bool,	"Enable AoRMS Adjustments: ")\
	_SETPR_AAORMS(ao_exp,	float,	"UV Distortion Power: ")

#pragma endregion _ADJUST_AORMS_
// ################################################################################
#endif