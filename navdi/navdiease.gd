extends RefCounted
class_name NavdiEase

signal value_changed(value:float)
signal intvalue_changed(intvalue:float)

var velocity : float
var value : float
var target : float

var intsnap : bool
var intvalue : int

# default values
var params : NavdiEaseParams

func _init() -> void:
	self.intsnap = false
	self.velocity = 0.0
	self.value = 0.0
	self.target = 0.0
	self.params = NavdiEaseParams.new()

func update() -> void:
	var last_value : float = value
	value = move_toward(value, target, params.unsloppy_flat)
	var vel2 : float = (target - value) * params.sloppiness
	velocity = lerp(velocity,vel2,params.accsloppiness) * (1-params.sloppyfriction)
	value += velocity
	if value != last_value:
		_emit_changed_signals()

func _emit_changed_signals() -> void:
	if intsnap and intvalue != int(round(value)):
		intvalue = int(round(value))
		intvalue_changed.emit(intvalue)
	value_changed.emit(value)

func setup_value(v : float) -> NavdiEase:
	self.value = v
	self.intvalue = int(round(v))
	self.target = v
	self.velocity = 0.0
	_emit_changed_signals()
	return self

func setup_velocity(v : float) -> NavdiEase:
	self.velocity = v
	return self

func setup_params(p : NavdiEaseParams) -> NavdiEase:
	self.params = p
	return self

func setup_intsnap() -> NavdiEase:
	intsnap = true
	return self

func setup_sloppy(sloppy:float, accel:float, friction:float) -> NavdiEase:
	params.sloppiness = sloppy
	params.accsloppiness = accel
	params.sloppyfriction = friction
	return self

func setup_unsloppy(flat:float) -> NavdiEase:
	params.unsloppy_flat = flat
	return self
	
