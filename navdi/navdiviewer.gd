extends Node
class_name NavdiViewer
const GROUP : StringName = &"ViewerGrp"
const VIEWRECTGROUPNAME : StringName = &"ViewRectGrp"

signal navdilogged(k:String, v:String)

const VIEWER_CAPTURES_FOLDER_PATH : String = "res://viewer_captures/"

var _smoothness : float = 1.0
@export_range(-10, 10, 0.1) var smoothness : float :
	get : return _smoothness
	set (v) :
		_smoothness = v
		view_shader.set_shader_parameter("smoothness", v)
var following_viewrect:NavdiViewRect = null
var view_shader : ShaderMaterial :
	get : return $ViewShaderLayer/ViewShaderRect.material as ShaderMaterial

static func navdilog(n:Node,k:String,s:String) -> void:
	var viewer:NavdiViewer = n.get_tree(
	).get_first_node_in_group(GROUP)
	if viewer: viewer.navdilogged.emit(k,s)

static func follow(r:NavdiViewRect) -> void:
	var viewer:NavdiViewer = r.get_tree(
	).get_first_node_in_group(GROUP)
	if viewer: viewer._follow(r)
func _follow(r:NavdiViewRect) -> void:
	if following_viewrect != r:
		if following_viewrect:
			close_eyes()
			following_viewrect.moved.disconnect(update_following)
			following_viewrect.tree_exiting.disconnect(close_eyes)
			following_viewrect = null
		following_viewrect = r
		if is_instance_valid(following_viewrect):
			following_viewrect.moved.connect(update_following)
			following_viewrect.tree_exiting.connect(close_eyes)
	if is_instance_valid(following_viewrect):
		update_following()
	else:
		close_eyes()

func _ready() -> void:
	add_to_group(GROUP)
	if !OS.has_feature('editor'):
		$UiLayer.hide()

func _physics_process(_delta: float) -> void:
	if is_instance_valid(following_viewrect):
		_follow(following_viewrect)
	elif following_viewrect:
		_follow(null)

func update_following() -> void:
	$ViewCamera.position = following_viewrect.position;
	view_shader.set_shader_parameter(
		"dreamsize", following_viewrect.size)
	view_shader.set_shader_parameter(
		"zoom", max(1,calculate_fitscale(
			get_viewport().get_visible_rect().size*0.75,
			following_viewrect.size
		))
	)

func close_eyes() -> void:
	view_shader.set_shader_parameter("dreamsize", Vector2(0,0))

func calculate_fitscale(pondsize:Vector2,fishsize:Vector2) -> float:
	#print( min(pondsize.x/fishsize.x,pondsize.y/fishsize.y,) )
	return min(pondsize.x/fishsize.x,pondsize.y/fishsize.y,)

func _unhandled_key_input(event: InputEvent) -> void:
	var keyevent := event as InputEventKey
	if keyevent.pressed:
		if OS.has_feature("editor") and keyevent.get_modifiers_mask() & (
		KeyModifierMask.KEY_MASK_META
		):
			match keyevent.keycode:
				KEY_1:
					screenshot(true,true,"png")
					get_viewport().set_input_as_handled()
				KEY_2:
					screenshot(true,false,"png")
					get_viewport().set_input_as_handled()
				KEY_3:
					screenshot(true)
					get_viewport().set_input_as_handled()
		else:
			match keyevent.keycode:
				KEY_QUOTELEFT:
					$UiLayer.visible = not $UiLayer.visible
					get_viewport().set_input_as_handled()

func timestamp() -> String:
	var now = Time.get_datetime_dict_from_system(true)
	return "%04d%02d%02dT%02d%02d%02dZ" % [now.year,now.month,now.day,now.hour,now.minute,now.second]

func screenshot(hideui:bool=true,hidefilter:bool=false,ext:String="jpg") -> void:
	var hide_layers : Array[CanvasLayer] = []
	if hideui and $UiLayer.visible: hide_layers.append($UiLayer)
	if hidefilter and $ViewShaderLayer.visible: hide_layers.append($ViewShaderLayer)
	var screenshot_filename = "%s%s_%s.%s"%[
		get_tree().current_scene.name,
		"x1" if hidefilter else "",
		timestamp(),
		ext
	]
	for layer in hide_layers: layer.hide()
	RenderingServer.force_draw()
	var image = get_viewport().get_texture().get_image()
	for layer in hide_layers: layer.show()
	RenderingServer.force_draw()
	
	if hidefilter:
		image.crop(
		int(ceil(following_viewrect.size.x)),
		int(ceil(following_viewrect.size.y)))
	
	var err
	
	if DirAccess.open(VIEWER_CAPTURES_FOLDER_PATH) == null:
		err = DirAccess.make_dir_recursive_absolute(VIEWER_CAPTURES_FOLDER_PATH)
		if err == OK:
			var ignorefile := FileAccess.open(VIEWER_CAPTURES_FOLDER_PATH
				.path_join(".gdignore"),FileAccess.WRITE)
			ignorefile.close()
			var gitignorefile := FileAccess.open(VIEWER_CAPTURES_FOLDER_PATH
				.path_join(".gitignore"),FileAccess.WRITE)
			gitignorefile.store_string("*")
			gitignorefile.close()
		else:
			push_error("Problem making dir %s, err code: %s" % [VIEWER_CAPTURES_FOLDER_PATH, err])
			return
	
	var pngpath := VIEWER_CAPTURES_FOLDER_PATH.path_join(screenshot_filename)
	
	match ext:
		"png": err = image.save_png(pngpath)
		"jpg": err = image.save_jpg(pngpath,.25)
		_: push_error("Unknown extension *.%s" % ext)
	if err == OK:
		print("pic saved @ %s" % pngpath)
	else:
		push_error("Problem saving pic @ %s, err code: %s" % [pngpath, err])
