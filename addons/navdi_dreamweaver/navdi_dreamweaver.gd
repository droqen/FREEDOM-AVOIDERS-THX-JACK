@tool
extends EditorPlugin

const DREAMWEAVER_MESSAGE = &"Create Dream from pyxel"
const DREAMBUNDLER_MESSAGE = &"Bundle Dream"

var dialog_create_dream : EditorFileDialog
var dialog_bundle_dream : EditorFileDialog

func _enter_tree() -> void:
	dialog_create_dream = EditorFileDialog.new()
	dialog_create_dream.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog_create_dream.title = DREAMWEAVER_MESSAGE
	dialog_create_dream.filters = ["*.pyxel"]
	dialog_create_dream.current_dir = "res://dreams/"
	get_editor_interface().get_base_control().add_child(dialog_create_dream)
	add_tool_menu_item(DREAMWEAVER_MESSAGE, _on_create_dream_menu_pressed)
	dialog_create_dream.file_selected.connect(_on_pyxel_selected)
	
	dialog_bundle_dream = EditorFileDialog.new()
	dialog_bundle_dream.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog_bundle_dream.title = DREAMBUNDLER_MESSAGE
	dialog_bundle_dream.filters = ["*_Dream.tres"]
	dialog_bundle_dream.current_dir = "res://dreams/"
	get_editor_interface().get_base_control().add_child(dialog_bundle_dream)
	add_tool_menu_item(DREAMBUNDLER_MESSAGE, _on_bundle_dream_menu_pressed)
	dialog_bundle_dream.file_selected.connect(_on_dream_selected_to_bundle)

func _exit_tree() -> void:
	if dialog_create_dream:
		remove_tool_menu_item(DREAMWEAVER_MESSAGE)
		dialog_create_dream.queue_free() # disconnect incl.
	if dialog_bundle_dream:
		remove_tool_menu_item(DREAMBUNDLER_MESSAGE)
		dialog_bundle_dream.queue_free() # disconnect incl.
	
func _on_create_dream_menu_pressed() -> void:
	dialog_create_dream.popup_centered(Vector2i(800,600))
	
func _on_bundle_dream_menu_pressed() -> void:
	dialog_bundle_dream.popup_centered(Vector2i(800,600))

func _on_pyxel_selected(path:String) -> void:
	if path.ends_with(".pyxel"):
		var parent_dir_file = path.rsplit("/",false,2)
		var dir = parent_dir_file[0] + "/" + parent_dir_file[1] + "/"
		var dirname = parent_dir_file[1]
		var filename_fileext = parent_dir_file[2].rsplit(".",false,1)
		var filename = filename_fileext[0]
		
		var pyxel_resource = ResourceLoader.load(path)
		
		var SHEET_PATHNAME = dir+filename+"_sheet.tres"
		var TILES_PATHNAME = dir+filename+"_tiles.tres"
		var NOTES_PATHNAME = dir+filename+"_notes.txt"
		var SCENE_PATHNAME = dir+dirname+"_scene.tscn"
		var DREAM_PATHNAME = dir+dirname+"_Dream.tres"
		
		var notes = FileAccess.open(NOTES_PATHNAME, FileAccess.WRITE)
		if notes:
			notes.store_string(NavdiGenUtil.gen_dreamnotes(filename))
			notes.close()
		else:
			push_error("failed to create notes @ %s, err code %s" % [NOTES_PATHNAME, FileAccess.get_open_error()])
		
		var err
		err = save_if_new(SHEET_PATHNAME, func():
			var new_sheet = Sheet.new()
			new_sheet.texture = pyxel_resource
			new_sheet.hframes = 10
			new_sheet.vframes = 10
			return new_sheet)
		err = save_if_new(TILES_PATHNAME, func():
			var new_atlas = TileSetAtlasSource.new()
			new_atlas.texture = pyxel_resource
			new_atlas.texture_region_size = Vector2i(10,10)
			var grid_size = new_atlas.get_atlas_grid_size()
			if grid_size != Vector2i(10,10):
				push_warning("atlas is not 10x10 tiles; ",pyxel_resource," usually expects 100x100.")
			for y in range(grid_size.y):
				for x in range(grid_size.x):
					new_atlas.create_tile(Vector2i(x,y))
			var new_tiles = TileSet.new()
			new_tiles.tile_size = Vector2i(10,10)
			new_tiles.add_physics_layer(0)
			new_tiles.set_physics_layer_collision_layer(0,1)
			new_tiles.add_source(new_atlas)
			return new_tiles)
		err = save_if_new(SCENE_PATHNAME, func():
			var node = Node2D.new(); node.name = dirname
			var maze = Maze.new(); maze.name = "Maze"
			maze.tile_set = ResourceLoader.load(TILES_PATHNAME)
			for x in range(10):for y in range(10):
				maze.set_cell_tid(Vector2i(x,y),randi()%3-1)
			var spr = SheetSprite.new(); spr.name = "Spr"
			spr.sheet = ResourceLoader.load(SHEET_PATHNAME)
			spr.frames = [10,11]
			spr.ani_period = 10
			spr.position = Vector2(50,50)
			spr.playing = true
			var view = NavdiViewRect.new(); view.name = "View"
			view.size = Vector2i(100, 100)
			
			node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
			node.add_child(maze); maze.owner = node;
			node.add_child( spr);  spr.owner = node;
			node.add_child(view); view.owner = node;
			
			var new_scene = PackedScene.new()
			var result = new_scene.pack(node)
			if result != OK:
				push_error("SCENE CREATION FAILED err ",result)
			return new_scene)
		err = save_if_new(DREAM_PATHNAME,func():
			var new_dream = NavdiDream.new()
			new_dream.packed_scene = ResourceLoader.load(SCENE_PATHNAME)
			return new_dream)
	else:
		push_error("dreamweaver cannot use non-pyxel file: ",path)

func _on_dream_selected_to_bundle(dreampath:String) -> void:
	var maybe_dream = ResourceLoader.load(dreampath)
	if maybe_dream and maybe_dream is NavdiDream:
		var dream := maybe_dream as NavdiDream
		var pathsplit := dreampath.rsplit("/",false,1)
		var dir := pathsplit[0]
		var dreamname := dir.rsplit("/",false,1)[-1]
		print("Selected dream `%s`" % dreamname)
		var packer := PCKPacker.new()
		# new pck file path name
		var pckpath := "res://dreambundles/newgame.droq%s" % dreamname
		# orig pck file path name
		#var pckpath := "res://dreambundles/%s.pck" % dreamname
		packer.pck_start(pckpath)
		for file in DirAccess.get_files_at(dir):
			repack_resource(packer, dir.path_join(file))
		var err = packer.flush()
		if err == OK:
			print("Successfully bundled dream @ `%s`" % pckpath)
		else:
			print("Dream bundling failed, err %s" % err)
			if err == 31:
				print("(31: The problem is probably that res://dreambundles doesn't exist)")

func repack_resource(packer:PCKPacker, filepath:String) -> void:
	packer.add_file_removal(filepath)
	var importpath = filepath+'.import'
	if FileAccess.file_exists(importpath):
		var importconfig = ConfigFile.new()
		var err = importconfig.load(importpath)
		if err == OK:
			var remappath = importconfig.get_value("remap","path")
			if remappath:
				packer.add_file(remappath, remappath)
				print("packed: ",remappath)
		else:
			push_error("repack .import exists but couldn't be read @ %s - err=%s" % [importpath,err])
	packer.add_file(filepath, filepath)
	print("packed: ",filepath)

func save_if_new(fullfilepath:String, generate:Callable) -> Error:
	if FileAccess.file_exists(fullfilepath):
		#push_warning("File already exists at ",fullfilepath)
		return Error.ERR_ALREADY_EXISTS
	else:
		ResourceSaver.save(generate.call(),fullfilepath)
		return OK
