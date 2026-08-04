@tool
extends EditorImportPlugin


func _get_importer_name() -> String:
	return "pyxel.unzipped"

func _get_visible_name() -> String:
	return "Pyxel"

func _get_recognized_extensions() -> PackedStringArray:
	return ["pyxel"]

func _get_save_extension() -> String:
	return "res"

func _get_resource_type() -> String:
	return "PortableCompressedTexture2D"

func _get_import_options(_path: String, _preset_index: int) -> Array[Dictionary]:
	return [] # no import options

func _import(
source_file: String,
save_path: String,
options: Dictionary,
platform_variants: Array[String],
gen_files: Array[String]) -> Error:
	var reader = ZIPReader.new()
	var err : Error
	err = reader.open(source_file);
	
	if err!=OK:push_error("%s - failed to open source file"%err);return err
	var doc_data_bytes = reader.read_file("docData.json")
	var doc_data: Dictionary = JSON.parse_string(
			doc_data_bytes.get_string_from_utf8())
	var layer0_bytes = reader.read_file("layer0.png")
	var layer0 : Image = Image.new()
	layer0.load_png_from_buffer(layer0_bytes)
	err = reader.close()
	if err!=OK:push_error("%s - failed to close reader"%err);return err
	
	var tex := PortableCompressedTexture2D.new()
	tex.create_from_image(layer0,
			PortableCompressedTexture2D
			.COMPRESSION_MODE_LOSSLESS)
			
	var doc_data_canvas = doc_data.get("canvas")
	if doc_data_canvas and doc_data_canvas is Dictionary:
		for dockey in ["tileWidth", "tileHeight", ]:
			tex.set_meta(dockey, doc_data_canvas[dockey])
			
	err = ResourceSaver.save(tex, "%s.%s" % [save_path, _get_save_extension()])
	if err!=OK:push_error("%s - failed to save pctex2d"%err);return err
	
	return OK
