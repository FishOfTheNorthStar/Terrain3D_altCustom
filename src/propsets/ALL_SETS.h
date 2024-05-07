#pragma once

#ifndef TERRAIN3D_ALL_PROPSETS_H
#define TERRAIN3D_ALL_PROPSETS_H

#include "propsets/__PROPSETS.h"

//Code Templates for Terrain3D Managed GLSL/Godot Properties

// ################################################################################
// ## MISC ##
// ################################################################################
// It's critical that this help entry for shader override is defined but currently 
// the shader override group itself is not fully managed, so to make sure this is 
// defined, it's here with the all set.
#define __help_defined_for_shader_override
#define HELP_SHADER_OVERRIDE()\
	ADD_HELP_TOPIC_DECL(shader_override, R"(If shader_override_enabled is true and this Shader is valid, the material will use this custom shader code. If this is blank when you enable the override, the system will generate a shader with the current settings. So if you have a debug view enabled, the generated shader will have all of that code. A visual shader will also work here. However we only generate a text based shader so currently a visual shader needs to be constructed with the base code before it can work.)" )
// ################################################################################

#include "propsets/_AUTO_SHADER.h"
#include "propsets/_FEATURE_SHADER.h"
#include "propsets/_MULTI_SCALING.h"
#include "propsets/_NOISE_TINT.h"
#include "propsets/_UV_DISTORTION.h"
#include "propsets/_WORLD_NOISE.h"
#include "propsets/_ADJUST_AORMS.h"
#include "propsets/_RAIN.h"
#include "propsets/_VEGETATION.h"
#include "propsets/_STRATA_GRADIENT.h"
#include "propsets/_DEBUG_VIEWS.h"

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
	HELP_FEATURE_SHADER()\
	HELP_WORLD_NOISE()\
	HELP_NOISE_TINT()\
	HELP_UVDIST()\
	HELP_AAORMS()\
	HELP_RAIN()\
	HELP_STRATA()\
	HELP_VEG()\
	HELP_DEBUG()\
	HELP_SHADER_OVERRIDE()

// This generates all of the actual functions within the class .cpp file.
#define MAKE_MANAGED_FUNCTIONS()\
	MAKE_MULTI_SCALE_FUNCTIONS()\
	MAKE_AUTO_SHADER_FUNCTIONS()\
	MAKE_FEATURE_SHADER_FUNCTIONS()\
	MAKE_WORLD_NOISE_FUNCTIONS()\
	MAKE_NOISE_TINT_FUNCTIONS()\
	MAKE_ADJUST_AORMS_FUNCTIONS()\
	MAKE_RAIN_FUNCTIONS()\
	MAKE_STRATA_GRADIENT_FUNCTIONS()\
	MAKE_VEGETATION_FUNCTIONS()\
	MAKE_UV_DISTORTION_FUNCTIONS()

// This binds the necessary get/set functions for each managed property group.
#define BIND_MANAGED_VARS()\
	BIND_MULTI_SCALE_TEXTURING_VARS()\
	BIND_AUTO_SHADER_VARS()\
	BIND_FEATURE_SHADER_VARS()\
	BIND_UV_DISTORTION_VARS()\
	BIND_WORLD_NOISE_VARS()\
	BIND_NOISE_TINT_VARS()\
	BIND_ADJUST_AORMS_VARS()\
	BIND_RAIN_VARS()\
	BIND_STRATA_GRADIENT_VARS()\
	BIND_VEGETATION_VARS()\
	BIND_DEBUG_VIEW_VARS()

// This adds the managed properties to the Godot extension.  For sanity purposes, 
// it's probably best to call this after BIND_MANAGED_VARS, but I'm not sure 
// it really matters.
#define ADD_MANAGED_PROPS()\
	PROPS_MULTI_SCALE_TEXTURING()\
	PROPS_AUTO_SHADER()\
	PROPS_FEATURE_SHADER()\
	PROPS_WORLD_NOISE()\
	PROPS_NOISE_TINT()\
	PROPS_UV_DISTORTION()\
	PROPS_ADJUST_AORMS()\
	PROPS_RAIN()\
	PROPS_STRATA_GRADIENT()\
	PROPS_VEGETATION()\
	PROPS_DEBUG_VIEW()\

#define PRIVATE_MANAGED_VARS()\
	PRIV_AUTO_SHADER_VARS()\
	PRIV_FEATURE_SHADER_VARS()\
	PRIV_MULTI_SCALE_TEXTURING_VARS()\
	PRIV_WORLD_NOISE_VARS()\
	PRIV_NOISE_TINT_VARS()\
	PRIV_UV_DISTORTION_VARS()\
	PRIV_ADJUST_AORMS_VARS()\
	PRIV_RAIN_VARS()\
	PRIV_STRATA_GRADIENT_VARS()\
	PRIV_VEGETATION_VARS()\
	PRIV_DEBUG_VIEW_VARS()

#define PUBLIC_MANAGED_FUNCS()\
	__MAKE_MANAGED_HELP()\
	PUBLIC_AUTO_SHADER_FUNCS()\
	PUBLIC_FEATURE_SHADER_FUNCS()\
	PUBLIC_MULTI_SCALE_TEXTURING_FUNCS()\
	PUBLIC_WORLD_NOISE_FUNCS()\
	PUBLIC_NOISE_TINT_FUNCS()\
	PUBLIC_UV_DISTORTION_FUNCS()\
	PUBLIC_ADJUST_AORMS_FUNCS()\
	PUBLIC_RAIN_FUNCS()\
	PUBLIC_STRATA_GRADIENT_FUNCS()\
	PUBLIC_VEGETATION_FUNCS()\
	PUBLIC_DEBUG_VIEW_FUNCS()

#define UPDATE_MANAGED_VARS()\
	UPDATE_MULTI_SCALE_TEXTURING()\
	UPDATE_AUTO_SHADER()\
	UPDATE_FEATURE_SHADER()\
	UPDATE_WORLD_NOISE()\
	UPDATE_NOISE_TINT()\
	UPDATE_UV_DISTORTION()\
	UPDATE_ADJUST_AORMS()\
	UPDATE_RAIN()\
	UPDATE_STRATA_GRADIENT()\
	UPDATE_VEGETATION()\
	UPDATE_DEBUG_VIEW()

#pragma endregion _ALL_SETS_FUNCTIONS_
// ################################################################################

#endif