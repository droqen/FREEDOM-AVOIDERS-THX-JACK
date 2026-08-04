extends Resource
class_name NavdiDream
@export var packed_scene : PackedScene = null # default is null.
@export var beepbox_url : String = ""
func _to_string() -> String:
	return "NavdiDream@%s" % resource_path
#func get_pyxel() -> Texture2D:
	#var pyxel_path = resource_name.replace("_Dream.tres",".pyxel")
	#return ResourceLoader.load(pyxel_path, "Texture2D")
func scout() -> void:
	var pyxel_path : String = ''
	var dream_folder_path : String = resource_path.rsplit("/",true,1)[0]
	for file in DirAccess.get_files_at(dream_folder_path):
		if file.ends_with('.pyxel'): pyxel_path = dream_folder_path.path_join(file); break;
	if pyxel_path:
		_tiles = ResourceLoader.load(
			pyxel_path.replace(".pyxel", "_tiles.tres"),
			"TileSet"
		)
		_sheet = ResourceLoader.load(
			pyxel_path.replace(".pyxel", "_sheet.tres"),
			"Sheet"
		)
		if _sheet:
			_pixel = _sheet.texture.get_image().get_pixel(0,0)
var _pixel : Color = Color(0,0,0)
var _sheet : Sheet = null
var _tiles : TileSet = null
