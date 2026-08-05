extends Node2D

var vel : Vector2
var dir : int = 0 # 0 = right, clockwise in 45 degree increments
var fdir : float = 0.0
var TAU8 = PI * 0.25
var swivel : float = 0.0
var swivel_amp : float = 0.0
@onready var so : SheetSprite = $SprOrth
@onready var sd : SheetSprite = $SprDiag

var fpsskip : int = 0

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	vel = vel * 0.95
	swivel = fposmod(swivel+0.2,PI*2)
	if dpad.x*vel.x>0 and dpad.y*vel.y>0:
		vel += dpad * lerp(0.10, 0.02, swivel_amp)
		swivel_amp = lerp(swivel_amp,1.0,0.05)
	else:
		swivel_amp *= 0.9
		vel.x = move_toward(vel.x, 0, 0.1)
		vel.y = move_toward(vel.y, 0, 0.1)
		vel += dpad * 0.25
	#vel = vel * 0.9 + Vector2(dpad) * 0.1 * 0.5
	if fpsskip > 0:
		fpsskip -= 1
	else:
		position += vel
		fpsskip = 1
	#position += 0.5 * Vector2.RIGHT.rotated(dir*TAU8)
	if dpad:
		var targetdir : int = posmod(round((vel + Vector2(dpad)).angle()/TAU8), 8)
		var to_targetdir : float = fposmod(targetdir - fdir, 8)
		if to_targetdir > 4: to_targetdir -= 8
		fdir = fposmod(fdir + clamp(to_targetdir,-0.5,0.5) * 0.5, 8)
		dir = posmod(round(fdir),8)
	_render()
func _render() -> void:
	var rendir : int = posmod(round(fdir + sin(swivel) * swivel_amp),8)
	match rendir:
		0,2,4,6:
			so.rotation = rendir * TAU8
			so.show(); sd.hide()
		1,3,5,7:
			sd.rotation = (rendir-1) * TAU8
			sd.show(); so.hide()
