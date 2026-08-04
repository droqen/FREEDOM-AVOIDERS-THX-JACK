extends Camera2D
class_name CameraForDreaming

@export var pixelsnap : bool = false
@export var subpixelsnap : bool = true

@export var posease_params : NavdiEaseParams = NavdiEaseParams.new(
	).setup(0.5, 0.2, 0.8, 0.01)
@export var zoomease_params : NavdiEaseParams = NavdiEaseParams.new(
	).setup(0.5, 0.2, 0.8, 0.003)

@onready var posease : NavdiEase2D = NavdiEase2D.new(
).setup_params(posease_params).setup_value(Vector2(50, 50)).setup_intsnap()
@onready var zoomease : NavdiEase = NavdiEase.new(
).setup_params(zoomease_params).setup_value(3.0)

@export var zoom_levels_int_only : bool = true
@export var zoom_minimum : float = 1.0
@export var view_padding_absolute : Vector2 = Vector2(10, 10)
@export var dreamview_rect : Rect2 = Rect2(0, 0, 100, 100)
var _last_known_dreamview_rect : Rect2
var _last_known_viewport_size : Vector2
var _last_known_viewport_size_padded : Vector2

func _ready() -> void:
	posease.value_changed.connect(func(pos):
		if pixelsnap: position = posease.intvalue
		elif subpixelsnap: position = Vector2(Vector2i(pos*zoom.x))/zoom.x
		else: position = pos
	)
	zoomease.value_changed.connect(func(z):
		zoom = Vector2(z,z)
	)
	get_viewport().size_changed.connect(_force_update_viewport_size)
	_force_update_viewport_size()
	_force_update_viewport_size.call_deferred()
func _force_update_viewport_size() -> void:
	_last_known_viewport_size = get_viewport_rect().size
	_last_known_viewport_size_padded = _last_known_viewport_size - view_padding_absolute * 2
	_force_update_targets()
func _force_update_targets() -> void:
	_last_known_dreamview_rect = dreamview_rect
	#_target_zoom = max(zoom_minimum,
		#min()
	#)
	var dreamsize : Vector2 = dreamview_rect.size
	posease.target = dreamview_rect.position + dreamsize * 0.5
	zoomease.target = max(1,zoom_minimum,min(
		_last_known_viewport_size_padded.x / dreamsize.x,
		_last_known_viewport_size_padded.y / dreamsize.y
	))
	if zoom_levels_int_only: zoomease.target = int(zoomease.target)

func set_dreamview_size(size:Vector2) -> void:
	if dreamview_rect.size != size:
		var focus : Vector2 = dreamview_rect.get_center()
		dreamview_rect.size = size
		set_dreamview_focus(focus)
func set_dreamview_focus(focus:Vector2) -> void:
	dreamview_rect.position = focus - dreamview_rect.size * 0.5

func snap_to_target() -> void:
	_force_update_targets()
	posease.setup_value(posease.target)
	zoomease.setup_value(zoomease.target)

func _physics_process(_delta: float) -> void:
	if _last_known_dreamview_rect != dreamview_rect:
		_force_update_targets()
	
	posease.update()
	zoomease.update()
