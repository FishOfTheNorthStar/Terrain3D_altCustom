// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#ifndef TERRAIN3D_TEXTURE_CLASS_H
#define TERRAIN3D_TEXTURE_CLASS_H

#include <godot_cpp/classes/texture2d.hpp>

using namespace godot;

class Terrain3DTexture : public Resource {
	GDCLASS(Terrain3DTexture, Resource);

public:
	// Constants
	static inline const char *__class__ = "Terrain3DTexture";

	struct Settings {
		String _name = "New Texture";
		int _texture_id = 0;
		Color _albedo_color = Color(1.f, 1.f, 1.f, 1.f);
		Ref<Texture2D> _albedo_texture;
		Ref<Texture2D> _normal_texture;
		real_t _uv_scale = 0.1f;
		real_t _uv_rotation = 0.0f;
		real_t _spec_adjust = 0.5f;
		Color _solid_color = Color(1.f, 1.f, 1.f, 0.5f);
		Vector4 _userdata = Vector4(0.f, 0.f, 0.f, 0.f);
	};

private:
	Settings _data;

	bool _is_texture_valid(const Ref<Texture2D> &p_texture) const;

public:
	Terrain3DTexture();
	~Terrain3DTexture();

	// Edit data directly to avoid signal emitting recursion
	Settings *get_data() { return &_data; }
	void clear();

	void set_name(String p_name);
	String get_name() const { return _data._name; }

	void set_texture_id(int p_new_id);
	int get_texture_id() const { return _data._texture_id; }

	void set_albedo_color(Color p_color);
	Color get_albedo_color() const { return _data._albedo_color; }

	void set_albedo_texture(const Ref<Texture2D> &p_texture);
	Ref<Texture2D> get_albedo_texture() const { return _data._albedo_texture; }

	void set_normal_texture(const Ref<Texture2D> &p_texture);
	Ref<Texture2D> get_normal_texture() const { return _data._normal_texture; }

	void set_uv_scale(real_t p_scale);
	real_t get_uv_scale() const { return _data._uv_scale; }

	void set_uv_rotation(real_t p_rotation);
	real_t get_uv_rotation() const { return _data._uv_rotation; }
	
	void set_spec_adjust(real_t p_spec_adjust);
	real_t get_spec_adjust() const { return _data._spec_adjust; }

	void set_solid_color(Color p_color);
	Color get_solid_color() const { return _data._solid_color; }

	void set_userdata(Vector4 p_color);
	Vector4 get_userdata() const { return _data._userdata; }

protected:
	static void _bind_methods();
};

#endif // TERRAIN3D_TEXTURE_CLASS_H