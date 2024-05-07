// --------------------------------------------------------------------------------------
// * Placeholder function / variable defs to appease syntax highlighter in Godot:
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
void placeholder_func_VERTEX_VEG() {
// * External parameters:
//const uint _CONTROL = 0u;
//const uint _background_mode = 1u;
//const uint CAMERA_VISIBLE_LAYERS = 1u;
//const uint _mouse_layer = 1u;
//const ivec3 v_region = ivec3(0u);

// * Local changes to:
vec3	VERTEX	= vec3(0.); // In this code portion, VERTEX may be written to, to invalidate it.
// * Original source of:
// bool	_HOLE : No set use for this yet but it's available as needed for the remaineder of the vertex function.
// float _FRV : a floating point version of this regions index value, but only if it's the first one?  
//				This needs looked into, I'm not sure the point of this.  Used during vertex normal calculation 
//				as a blending value against zero for texture gathered height samples.  Very unclear the purpose of this.
#endif
// --------------------------------------------------------------------------------------
// *** BEGIN: VERTEX_VEG 
// --------------------------------------------------------------------------------------
		v_noise = get_local_noise(v_vertex);
		v_elevmarks = get_elevmark_metrics(v_height); 

		#if defined(STRATA_GRADIENT_ENABLED) || defined(VEGETATION_ENABLED)
			v_gradients = vec4( get_local_gradient_periods( v_elevmarks, v_noise), 0.);
		#else
			v_gradients = vec4(0.);
		#endif

		#if defined(VEGETATION_ENABLED)
			float _veg_mix = clamp((v_role -2.0)/2.0,0., 1.); 
			v_veg = get_veg_response(v_role, v_elevmarks.z, v_gradients.z, v_noise.x);
			float _visible_veg_response = mix ( 0.5, max(0., v_veg*2.), _veg_mix)*2.;
			v_gradients.w = _visible_veg_response;
			#if defined(VEGETATION_RAISE_HEIGHT)
				// Temp, seeing how it looks with veg nudgin vert up a little
				VERTEX.y += get_veg_height_from_response(_visible_veg_response);
			#endif
		#else
			v_veg = 0.;
		#endif
// --------------------------------------------------------------------------------------
// *** END: VERTEX_VEG 
// --------------------------------------------------------------------------------------
#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
}
#endif