extends RefCounted
class_name NavdiEase2D

signal value_changed(value:Vector2)
signal intvalue_changed(intvalue:Vector2i)

var velocity : Vector2
var value : Vector2
var target : Vector2

var intsnap : bool
var intvalue : Vector2i

# default values
var params : NavdiEaseParams

func _init() -> void:
	self.intsnap = false
	self.velocity = Vector2.ZERO
	self.value = Vector2.ZERO
	self.target = Vector2.ZERO
	self.params = NavdiEaseParams.new()

func update() -> void:
	var last_value : Vector2 = value
	value += (target - value).limit_length(params.unsloppy_flat)
	var vel2 : Vector2 = (target - value) * params.sloppiness
	velocity = lerp(velocity,vel2,params.accsloppiness) * (1-params.sloppyfriction)
	value += velocity
	if value != last_value:
		_emit_changed_signals()

func _emit_changed_signals():
	var snappedvalue = Vector2i(round(value.x),round(value.y))
	if intsnap and intvalue != snappedvalue:
		intvalue = snappedvalue
		intvalue_changed.emit(intvalue)
	value_changed.emit(value)

func setup_value(v : Vector2) -> NavdiEase2D:
	self.value = v
	self.intvalue = Vector2i(round(value.x),round(value.y))
	self.target = v
	self.velocity = Vector2.ZERO
	_emit_changed_signals()
	return self

func setup_params(p : NavdiEaseParams) -> NavdiEase2D:
	self.params = p
	return self

func setup_intsnap() -> NavdiEase2D:
	intsnap = true
	return self

func setup_sloppy(sloppy:float, accel:float, friction:float) -> NavdiEase2D:
	params.sloppiness = sloppy
	params.accsloppiness = accel
	params.sloppyfriction = friction
	return self

func setup_unsloppy(flat:float) -> NavdiEase2D:
	params.unsloppy_flat = flat
	return self
	
