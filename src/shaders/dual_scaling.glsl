// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

R"(

//INSERT: MULTI_SCALING_BASE
	// If dual scaling, apply to base texture
	if(region < 0) {
		matUV *= _multi_scale_macro_size;
		uv1_grad *= _multi_scale_macro_size;
	}
	vec3 matUVW1 = vec3(matUV, float(out_mat.base));
	albedo_ht = textureGrad(_texture_array_albedo, matUVW1, uv1_grad.xy, uv1_grad.zw);
	normal_rg = textureGrad(_texture_array_normal, matUVW1, uv1_grad.xy, uv1_grad.zw);
	if(out_mat.base == _multi_scale_texture || out_mat.over == _multi_scale_texture) {
		vec3 dmatUVW1 = vec3(matUV*_multi_scale_micro_size, float(_multi_scale_texture));
		vec4 duv1_grad = uv1_grad *_multi_scale_micro_size;
		albedo_far = textureGrad(_texture_array_albedo, dmatUVW1, duv1_grad.xy, duv1_grad.zw);
		normal_far = textureGrad(_texture_array_normal, dmatUVW1, duv1_grad.xy, duv1_grad.zw); 
	}
	if(out_mat.base == _multi_scale_texture) {
		albedo_ht = mix(albedo_ht, albedo_far, v_far_factor);
		normal_rg = mix(normal_rg, normal_far, v_far_factor); 
	} 

//INSERT: UNI_SCALING_BASE
	albedo_ht = textureGrad(_texture_array_albedo, vec3(matUV, float(out_mat.base)), uv1_grad.xy, uv1_grad.zw);
	normal_rg = textureGrad(_texture_array_normal, vec3(matUV, float(out_mat.base)), uv1_grad.xy, uv1_grad.zw);

//INSERT: MULTI_SCALING_OVERLAY
		// If multi scaling, apply to overlay texture
		float vff = v_far_factor * float(1-abs(min(1,out_mat.over - _multi_scale_texture)));
		albedo_ht2 = mix(albedo_ht2, albedo_far, vff);
		normal_rg2 = mix(normal_rg2, normal_far, vff);

)"