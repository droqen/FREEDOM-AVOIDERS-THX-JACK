extends Node2D

var vx : float; var vy : float;

enum {
	TURNBUF=12484,
	JUSTHURTBUF=10992866116,
	HURTBUF=109928666,
	INVINCBUF=429,
}

const CENTER := Vector2(125, 75)

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	TURNBUF,4, JUSTHURTBUF,5, HURTBUF,30, INVINCBUF,120,])
@onready var SNAKESPRITE = $sprites/snakesprite
@onready var REDSPRITE = $sprites/redsprite
@onready var AAAGHSPRITE = $sprites/aaaghsprite
@onready var ALLSPRITES = $sprites.get_children()

var rot : int = 0

func showsprite(s):
	$sprites.modulate.a = 1.0
	#print(s, ALLSPRITES)
	for sprite in ALLSPRITES:
		if sprite == s: sprite.show()
		else: sprite.hide()
		#print(sprite, sprite.visible)

func whoosh(a,b,rate):
	# a fancy move_toward
	return lerp(move_toward(a,b,rate),b,rate*0.1)

func _physics_process(_delta: float) -> void:
	if not bufs.has(INVINCBUF):
		if $hurtbox.get_overlapping_bodies():
			tryhurtme()
	
	if bufs.has(HURTBUF):
		if bufs.has(JUSTHURTBUF):
			vx = sign(CENTER.x - position.x);
			vy = sign(CENTER.y - position.y);
		else:
			position += Vector2(vx,vy)
	else:
		var dpad = Pin.get_dpad()
		var preferred_dir : Vector2 = Vector2(1,1)
		position += Vector2(vx,vy)
		var canturn : bool = not bufs.has(TURNBUF) and not bufs.has(HURTBUF)
		match rot:
			0:
				preferred_dir = Vector2.UP.rotated(PI*0.25) # north-east
				if dpad.x > 0 and dpad.y >= 0 and canturn:
					# press right to rotate, while NOT pressing north
					rot = 1
					bufs.on(TURNBUF)
			1:
				preferred_dir = Vector2.RIGHT.rotated(PI*0.25)
				if dpad.y > 0 and dpad.x <= 0 and canturn:
					rot = 2
					bufs.on(TURNBUF)
			2:
				preferred_dir = Vector2.DOWN.rotated(PI*0.25)
				if dpad.x < 0 and dpad.y <= 0 and canturn:
					rot = 3
					bufs.on(TURNBUF)
			3:
				preferred_dir = Vector2.LEFT.rotated(PI*0.25)
				if dpad.y < 0 and dpad.x >= 0 and canturn:
					rot = 0
					bufs.on(TURNBUF)
		var raw_dot = preferred_dir.dot(Vector2(dpad)) # 2 = full match, -1 : least match
		var smooth_dot = 0.5 + 0.5 * clamp(raw_dot,-.7,.7)/.7
		var max_speed = 0.35 + 0.85 * smooth_dot * smooth_dot
		var accelmult = 0.02 + 0.04 * smooth_dot
		vx = whoosh(vx,dpad.x*max_speed,
			accelmult if dpad.x*vx>0 else 0.05)
		vy = whoosh(vy,dpad.y*max_speed,
			accelmult if dpad.y*vy>0 else 0.05)
		#if dpad.x and $sprites.scale.x != dpad.x:
			#$sprites.scale.x = dpad.x
			#bufs.on(TURNBUF)
		#if dpad.y and $sprites.scale.y != -dpad.y:
			#$sprites.scale.y = -dpad.y
			#bufs.on(TURNBUF)
			
		if position.x < 5: tryhurtme()
		if position.y < 5: tryhurtme()
		if position.x > 245: tryhurtme()
		if position.y > 145: tryhurtme()
	
	if bufs.has(INVINCBUF):
		if bufs.has(JUSTHURTBUF):
			showsprite(AAAGHSPRITE)
		elif bufs.has(HURTBUF):
			showsprite(REDSPRITE)
		else:
			showsprite(SNAKESPRITE)
		var iiiii = bufs.read(INVINCBUF)
		if iiiii > 40:
			$sprites.modulate.a = fposmod(iiiii * 0.25,1.25)
		else:
			$sprites.modulate.a = fposmod(iiiii * 0.125,1.25) + 0.25
	elif bufs.has(TURNBUF): showsprite(null)
	else: showsprite(SNAKESPRITE)
	$sprites.rotation = PI * 0.5 * rot
	#else: showsprite(REDSPRITE)
	

func tryhurtme() -> bool:
	if bufs.has(INVINCBUF): return false;
	for b in [JUSTHURTBUF,HURTBUF,INVINCBUF]:
		bufs.on(b)
	# lose hp? die? idk
	#rot = randi() % 4
	return true
