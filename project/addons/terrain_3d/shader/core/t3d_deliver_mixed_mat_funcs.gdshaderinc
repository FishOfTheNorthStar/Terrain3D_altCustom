#if !defined(__T3D_INTERNAL_GLOBALS_AVAILABLE__)
// REQUIRED EXTERNAL TYPES:
// "Material" (struct): Provided by
#include "res://addons/terrain_3d/shader/core/t3d_material_def.gdshaderinc"
// EXTERNAL CALLS:
Material get_material(vec2 _uv,vec4 _g,uint _cx, int _nx, float _ax, out Material _mat) { return Material( vec4(0.), vec4(0.), 0, 0, 0.0); }
#endif

// uv co-ord, sampling gradient (RTX_GRAD), control ufloats, neighbor ints, random angle floats
Material[4] get_materials( vec2 _uv, vec4 _g, uvec4 _c, ivec4 _n, vec4 _a) {
	Material _m[4];
	get_material(_uv, _g, _c.x, _n.x, _a.x, _m[0]);
	get_material(_uv, _g, _c.y, _n.y, _a.y, _m[1]);
	get_material(_uv, _g, _c.z, _n.z, _a.z, _m[2]);
	get_material(_uv, _g, _c.w, _n.w, _a.w, _m[3]);
	return _m; }

