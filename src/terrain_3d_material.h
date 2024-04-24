// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef TERRAIN3D_MATERIAL_CLASS_H
#define TERRAIN3D_MATERIAL_CLASS_H

//#define __DEBUG_ACTIVE_AND_SHADER_PARAMS   // Uncomment this line for extra console spam about shader / resource parameter groups

#include <godot_cpp/classes/shader.hpp>
#include <godot_cpp/classes/noise_texture2d.hpp>

#include "generated_tex.h"
#include "__MACROS.h"

using namespace godot;

class Terrain3DMaterial : public Resource {
	GDCLASS(Terrain3DMaterial, Resource);

public:
	// Constants
	static inline const char *__class__ = "Terrain3DMaterial";

	enum WorldBackground {
		NONE,
		FLAT,
		NOISE_1,
		NOISE_2
	};

	enum TextureFiltering {
		LINEAR,
		NEAREST,
	};

private:

	PRIVATE_MANAGED_VARS()

	bool _initialized = false;
	RID _material;
	RID _shader;
	String _last_generated_defines = "";
	bool _shader_override_enabled = false;
	Ref<Shader> _shader_override;
	Ref<Shader> _shader_tmp;
	Dictionary _shader_code;//	= Dictionary();
	mutable TypedArray<StringName> _active_params;	// All shader params in the current shader
	mutable Dictionary _shader_params;				// Public shader params saved to disk

	// Material Features
	WorldBackground _world_background = FLAT;
	TextureFiltering _texture_filtering = LINEAR;


	// Cached data from Storage
	int _texture_count = 0;
	int _region_size = 1024;
	real_t _mesh_vertex_spacing = 1.0f;
	Vector2i _region_sizev = Vector2i(_region_size, _region_size);
	PackedInt32Array _region_map;
	GeneratedTex _generated_region_blend_map; // 512x512 blurred image of region_map

	// Functions
	String get_snippet(String _snippet_id);
	void _preload_shaders();
	void _parse_shader(String p_shader, String p_name, bool p_force_uppercase_ids = false);
	String _add_if_exists(String _current, String _snippetID_);
	String _add_if_enabled(String _current, bool _controlVar, String _snippetID_enabled, String _snippetID_disabled = "");
	Array _add_if_true(Array _toset, bool _condition, String _toadd, String _toadd_if_false = "");
	void _safe_material_set_param(StringName _param, Variant _value);

	String _apply_inserts(String p_shader, Array p_excludes = Array(), Array p_defines = Array());
	String _generate_shader_code(String _explicitDefines = "");
	void _confirm_noise_texture();
	Ref<NoiseTexture2D> _generate_noise_texture();
	String _get_current_defines();
	String _add_or_update_header(String _to_code, String _explicitDefines = "");
	void _update_shader();
	void _update_shader_if_defines_have_changed();
	void _update_regions(const Array &p_args);
	void _generate_region_blend_map();
	void _update_texture_arrays(const Array &p_args);
	void _set_region_size(int p_size);
	void _set_shader_parameters(const Dictionary &p_dict);
	Dictionary _get_shader_parameters() const { return _shader_params; }

public:
	Terrain3DMaterial(){};
	void initialize(int p_region_size);
	~Terrain3DMaterial();

	RID get_material_rid() const { return _material != Variant::NIL ? _material : RID(); }
	RID get_shader_rid() const;
	RID get_region_blend_map() { return _generated_region_blend_map.get_rid(); }

	// Material settings
	void set_world_background(WorldBackground p_background);
	WorldBackground get_world_background() const { return _world_background; }

	TextureFiltering get_texture_filtering() const { return _texture_filtering; }
	void set_texture_filtering(TextureFiltering p_filtering);

	void set_shader_param(const StringName &p_name, const Variant &p_value);
	Variant get_shader_param(const StringName &p_name) const;
	void set_mesh_vertex_spacing(real_t p_spacing);
	void save();

	void _set_help_no_op_temp(String p_unused);

	bool  is_uv_distortion_enabled()			const { return _uv_distortion_enabled; }

	void enable_shader_override(bool p_enabled);
	bool is_shader_override_enabled() const { return _shader_override_enabled; }
	void set_shader_override(const Ref<Shader> &p_shader);
	Ref<Shader> get_shader_override() const { return _shader_override; }

	PUBLIC_MANAGED_FUNCS()

protected:
	void _get_property_list(List<PropertyInfo> *p_list) const;
	bool _property_can_revert(const StringName &p_name) const;
	bool _property_get_revert(const StringName &p_name, Variant &r_property) const;
	bool _set(const StringName &p_name, const Variant &p_property);
	bool _get(const StringName &p_name, Variant &r_property) const;

	static void _bind_methods();
};

VARIANT_ENUM_CAST(Terrain3DMaterial::WorldBackground);
VARIANT_ENUM_CAST(Terrain3DMaterial::TextureFiltering);

#endif // TERRAIN3D_MATERIAL_CLASS_H