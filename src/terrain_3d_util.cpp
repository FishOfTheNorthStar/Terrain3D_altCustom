// Copyright © 2023 Cory Petkovsek, Roope Palmroos, and Contributors.

#include <godot_cpp/classes/engine.hpp>

#include "logger.h"
#include "terrain_3d_util.h"

///////////////////////////
// Public Functions
///////////////////////////

void Terrain3DUtil::print_dict(String p_name, const Dictionary &p_dict, int level) {
	LOG(level, "Printing Dictionary: ", p_name);
	Array keys = p_dict.keys();
	for (int i = 0; i < keys.size(); i++) {
		LOG(level, "Key: ", keys[i], ", Value: ", p_dict[keys[i]]);
	}
}

void Terrain3DUtil::dump_gen(GeneratedTex p_gen, String p_name) {
	LOG(DEBUG, "Generated ", p_name, " RID: ", p_gen.get_rid(), ", dirty: ", p_gen.is_dirty(), ", image: ", p_gen.get_image());
}

void Terrain3DUtil::dump_maps(const TypedArray<Image> p_maps, String p_name) {
	LOG(DEBUG, "Dumping ", p_name, " map array. Size: ", p_maps.size());
	for (int i = 0; i < p_maps.size(); i++) {
		Ref<Image> img = p_maps[i];
		LOG(DEBUG, "[", i, "]: Map size: ", img->get_size(), " format: ", img->get_format(), " ", img);
	}
}

/**
 * Returns the minimum and maximum values for a heightmap (red channel only)
 */
Vector2 Terrain3DUtil::get_min_max(const Ref<Image> p_image) {
	if (p_image.is_null()) {
		LOG(ERROR, "Provided image is not valid. Nothing to analyze");
		return Vector2(INFINITY, INFINITY);
	} else if (p_image->is_empty()) {
		LOG(ERROR, "Provided image is empty. Nothing to analyze");
		return Vector2(INFINITY, INFINITY);
	}

	Vector2 min_max = Vector2(0.f, 0.f);

	for (int y = 0; y < p_image->get_height(); y++) {
		for (int x = 0; x < p_image->get_width(); x++) {
			Color col = p_image->get_pixel(x, y);
			if (col.r < min_max.x) {
				min_max.x = col.r;
			}
			if (col.r > min_max.y) {
				min_max.y = col.r;
			}
		}
	}

	LOG(INFO, "Calculating minimum and maximum values of the image: ", min_max);
	return min_max;
}

/**
 * Returns a Image of a float heightmap normalized to RGB8 greyscale and scaled
 * Minimum of 8x8
 */
Ref<Image> Terrain3DUtil::get_thumbnail(const Ref<Image> p_image, Vector2i p_size) {
	if (p_image.is_null()) {
		LOG(ERROR, "Provided image is not valid. Nothing to process.");
		return Ref<Image>();
	} else if (p_image->is_empty()) {
		LOG(ERROR, "Provided image is empty. Nothing to process.");
		return Ref<Image>();
	}
	p_size.x = CLAMP(p_size.x, 8, 16384);
	p_size.y = CLAMP(p_size.y, 8, 16384);

	LOG(INFO, "Drawing a thumbnail sized: ", p_size);
	// Create a temporary work image scaled to desired width
	Ref<Image> img;
	img.instantiate();
	img->copy_from(p_image);
	img->resize(p_size.x, p_size.y, Image::INTERPOLATE_LANCZOS);

	// Get minimum and maximum height values on the scaled image
	Vector2 minmax = get_min_max(img);
	real_t hmin = minmax.x;
	real_t hmax = minmax.y;
	// Define maximum range
	hmin = abs(hmin);
	hmax = abs(hmax) + hmin;
	// Avoid divide by zero
	hmax = (hmax == 0) ? 0.001f : hmax;

	// Create a new image w / normalized values
	Ref<Image> thumb = Image::create(p_size.x, p_size.y, false, Image::FORMAT_RGB8);
	for (int y = 0; y < thumb->get_height(); y++) {
		for (int x = 0; x < thumb->get_width(); x++) {
			Color col = img->get_pixel(x, y);
			col.r = (col.r + hmin) / hmax;
			col.g = col.r;
			col.b = col.r;
			thumb->set_pixel(x, y, col);
		}
	}
	return thumb;
}

/* Get an Image filled with specified color and format
 * If p_color.a < 0, fill with checkered pattern multiplied by p_color.rgb
 *
 * Behavior changes if a compressed format is requested:
 * If the editor is running and format is DXT1/5, BPTC_RGBA, it returns a filled image.
 * Otherwise, it returns a blank image in that format.
 *
 * The reason is the Image compression library is available only in the editor. And it is
 * unreliable, offering little control over the output format, choosing automatically and
 * often wrong. We have selected a few compressed formats it gets right.
 */
Ref<Image> Terrain3DUtil::get_filled_image(Vector2i p_size, Color p_color, bool p_create_mipmaps, Image::Format p_format) {
	if (p_format < 0 || p_format >= Image::FORMAT_MAX) {
		p_format = Image::FORMAT_DXT5;
	}

	Image::CompressMode compression_format = Image::COMPRESS_MAX;
	Image::UsedChannels channels = Image::USED_CHANNELS_RGBA;
	bool compress = false;
	bool fill_image = true;

	if (p_format >= Image::Format::FORMAT_DXT1) {
		switch (p_format) {
			case Image::FORMAT_DXT1:
				p_format = Image::FORMAT_RGB8;
				channels = Image::USED_CHANNELS_RGB;
				compression_format = Image::COMPRESS_S3TC;
				compress = true;
				break;
			case Image::FORMAT_DXT5:
				p_format = Image::FORMAT_RGBA8;
				channels = Image::USED_CHANNELS_RGBA;
				compression_format = Image::COMPRESS_S3TC;
				compress = true;
				break;
			case Image::FORMAT_BPTC_RGBA:
				p_format = Image::FORMAT_RGBA8;
				channels = Image::USED_CHANNELS_RGBA;
				compression_format = Image::COMPRESS_BPTC;
				compress = true;
				break;
			default:
				compress = false;
				fill_image = false;
				break;
		}
	}

	Ref<Image> img = Image::create(p_size.x, p_size.y, p_create_mipmaps, p_format);

	if (fill_image) {
		if (p_color.a < 0.0f) {
			p_color.a = 1.0f;
			Color col_a = Color(0.8f, 0.8f, 0.8f, 1.0) * p_color;
			Color col_b = Color(0.5f, 0.5f, 0.5f, 1.0) * p_color;
			img->fill_rect(Rect2i(Vector2i(0, 0), p_size / 2), col_a);
			img->fill_rect(Rect2i(p_size / 2, p_size / 2), col_a);
			img->fill_rect(Rect2i(Vector2(p_size.x, 0) / 2, p_size / 2), col_b);
			img->fill_rect(Rect2i(Vector2(0, p_size.y) / 2, p_size / 2), col_b);
		} else {
			img->fill(p_color);
		}
		if (p_create_mipmaps) {
			img->generate_mipmaps();
		}
	}
	if (compress && Engine::get_singleton()->is_editor_hint()) {
		img->compress_from_channels(compression_format, channels);
	}
	return img;
}

/* From source RGB and R channels, create a new RGBA image. If p_invert_green_channel is true,
 * the destination green channel will be 1.0 - input green channel.
 */
Ref<Image> Terrain3DUtil::pack_image(const Ref<Image> p_src_rgb, const Ref<Image> p_src_r, bool p_invert_green_channel) {
	if (!p_src_rgb.is_valid() || !p_src_r.is_valid()) {
		LOG(ERROR, "Provided images are not valid. Cannot pack.");
		return Ref<Image>();
	}
	if (p_src_rgb->get_size() != p_src_r->get_size()) {
		LOG(ERROR, "Provided images are not the same size. Cannot pack.");
		return Ref<Image>();
	}
	if (p_src_rgb->is_empty() || p_src_r->is_empty()) {
		LOG(ERROR, "Provided images are empty. Cannot pack.");
		return Ref<Image>();
	}
	Ref<Image> dst = Image::create(p_src_rgb->get_width(), p_src_rgb->get_height(), false, Image::FORMAT_RGBA8);
	LOG(INFO, "Creating image from source RGB + R images.");
	for (int y = 0; y < p_src_rgb->get_height(); y++) {
		for (int x = 0; x < p_src_rgb->get_width(); x++) {
			Color col = p_src_rgb->get_pixel(x, y);
			col.a = p_src_r->get_pixel(x, y).r;
			if (p_invert_green_channel) {
				col.g = 1.0f - col.g;
			}
			dst->set_pixel(x, y, col);
		}
	}
	return dst;
}

///////////////////////////
// Protected Functions
///////////////////////////

void Terrain3DUtil::_bind_methods() {
	// Control map converters
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("as_float", "value"), &as_float);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("as_uint", "value"), &as_uint);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_base", "pixel"), &gd_get_base);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_base", "base"), &gd_enc_base);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_overlay", "pixel"), &gd_get_overlay);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_overlay", "overlay"), &gd_enc_overlay);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_blend", "pixel"), &gd_get_blend);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_blend", "blend"), &gd_enc_blend);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("is_hole", "pixel"), &gd_is_hole);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_hole", "pixel"), &enc_hole);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("is_nav", "pixel"), &gd_is_nav);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_nav", "pixel"), &enc_nav);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("is_auto", "pixel"), &gd_is_auto);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("enc_auto", "pixel"), &enc_auto);

	// Image handling
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_min_max", "image"), &Terrain3DUtil::get_min_max);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_thumbnail", "image", "size"), &Terrain3DUtil::get_thumbnail, DEFVAL(Vector2i(256, 256)));
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("get_filled_image", "size", "color", "create_mipmaps", "format"), &Terrain3DUtil::get_filled_image);
	ClassDB::bind_static_method("Terrain3DUtil", D_METHOD("pack_image", "src_rgb", "src_r", "invert_green_channel"), &Terrain3DUtil::pack_image, DEFVAL(false));
}
