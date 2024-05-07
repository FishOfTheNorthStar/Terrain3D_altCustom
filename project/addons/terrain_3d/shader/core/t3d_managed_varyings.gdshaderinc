// Copyright (c) 2023 Cory Petkovsek, Roope Palmroos, and Contributors.
//
#if !defined(__T3D_MANAGED_VARYINGS_AVAILABLE__)
#define __T3D_MANAGED_VARYINGS_AVAILABLE__
// -----------------------------------------------------------------------------
// This file is isolated from the rest of the header to make it easier to track
// any changes or additions to the varying's over time, and to run tests to make 
// sure they can properly toggle optional elements in/out of the shader without
// causing issues for other functionality.
// *****************************************************************************

varying flat vec3	v_vertex;		// World coordinate vertex location
varying flat vec3	v_camera_pos;	
// varying flat float	v_vertex_dist;  // Unfortunately this didn't work out well at all. maybe if it wasn't flat, will try that sometime.  Seems to be some kind of issue where when drawing the current vertex it's using the last (invalid) value, which resets something internally causing it to correct the next time, and end result is every two cycles the same quads toggle on / off randomly (all of them, like static), from their correct location to not there at all.  It's very strange and might make a cool effect if it was intentional.
varying flat ivec3	v_region;
varying flat vec3	v_norm_region;
varying flat vec2	v_uv_offset;
varying flat vec2	v_uv2_offset;
varying flat uvec4	v_control;
varying flat ivec4	v_neighbors;
varying flat vec4	v_rangles;

varying float	v_far_factor;
varying float	v_height;
varying float	v_role;
varying float	v_veg;
varying vec3	v_noise;
varying vec3	v_normal;
varying vec3	v_tangent;
varying vec3	v_binormal;
#if defined(UV_DISTORTION_ENABLED)
varying vec2	v_uvdistort;
#endif
varying vec4 	v_gradients;
varying vec4	v_elevmarks;

// *****************************************************************************
// END: MANAGED VARYINGS
// -----------------------------------------------------------------------------

#endif
