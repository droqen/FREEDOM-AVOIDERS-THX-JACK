extends Node2D

var spawning : int = 0

var vx : float; var vy : float;

var straightlinedur : int = 0
var straightlinedir : Vector2i

enum {
	TURNBUF=12484,
	JUSTHURTBUF=10992866116,
	HURTBUF=109928666,
	INVINCBUF=429,
}

const CENTER := Vector2(125, 75)
const TAU16 := PI * 0.125
const TAU8 := PI * 0.25
const TAU4 := PI * 0.5

@onready var bufs : Bufs = Bufs.Make(self).setup_bufons([
	TURNBUF,4, JUSTHURTBUF,5, HURTBUF,30, INVINCBUF,120, ])
@onready var SPAWNSPRITE = $sprites/spawnsprite
@onready var SNAKESPRITE = $sprites/snakesprite
@onready var DASHSPRITE = $sprites/dashsprite
@onready var REDSPRITE = $sprites/redsprite
@onready var AAAGHSPRITE = $sprites/aaaghsprite
@onready var ALLSPRITES = $sprites.get_children()

var dying : int = 0
var rot : int = 0
var justhurt : bool = false
var hurting : bool = false

func chaser_overlap() -> void:
	if not dying: dying = 1
	vx = 0; vy = 0;

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
	
	if spawning < 80:
		if spawning == 0:
			SPAWNSPRITE.setup([0,90],50)
		else:
			SPAWNSPRITE.setup([[90,91,92,93,94,95,10,10,10][floor(spawning*0.1)]],0)
		showsprite(SPAWNSPRITE)
		return
	
	if not bufs.has(INVINCBUF):
		if $hurtbox.get_overlapping_bodies():
			tryhurtme()
	
	if dying:
		straightlinedur = 0
		dying += 1
		if dying > 30:
			queue_free()
	elif bufs.has(HURTBUF):
		straightlinedur = 0
		hurting = true; justhurt = bufs.has(JUSTHURTBUF);
		#vx = 0; vy = 0;
		#if bufs.has(JUSTHURTBUF):
			#vx = sign(CENTER.x - position.x);
			#vy = sign(CENTER.y - position.y);
		#else:
			#position += Vector2(vx,vy)
	else:
		hurting = false; justhurt = false;
		var dpad = Pin.get_dpad()
		if (dpad.x != 0) != (dpad.y != 0):
			if dpad == straightlinedir:
				straightlinedur += 1
			else:
				straightlinedir = dpad
				straightlinedur = 0
		elif straightlinedur > 0:
			if straightlinedir.x and dpad.x == straightlinedir.x:
				straightlinedur -= 1
			elif straightlinedir.y and dpad.y == straightlinedir.y:
				straightlinedur -= 1
			else:
				straightlinedur = 0
		else:
			straightlinedur = 0
		
		var straight_dir : Vector2i = Vector2i(0,-1)
		position += Vector2(vx,vy)
		var canturn : bool = not bufs.has(TURNBUF) and not bufs.has(HURTBUF)
		match rot:
			0:
				straight_dir = Vector2i.UP # north
				if dpad.x > 0 and dpad.y >= 0 and canturn:
					# press right to rotate, while NOT pressing north
					rot = 1
					bufs.on(TURNBUF)
			1:
				straight_dir = Vector2i.RIGHT
				if dpad.y > 0 and dpad.x <= 0 and canturn:
					rot = 2
					bufs.on(TURNBUF)
			2:
				straight_dir = Vector2i.DOWN
				if dpad.x < 0 and dpad.y <= 0 and canturn:
					rot = 3
					bufs.on(TURNBUF)
			3:
				straight_dir = Vector2i.LEFT
				if dpad.y < 0 and dpad.x >= 0 and canturn:
					rot = 0
					bufs.on(TURNBUF)
		var preferred_dir : Vector2 = Vector2(straight_dir).rotated(TAU8) # 45 degrees cw
		var raw_dot = preferred_dir.dot(Vector2(dpad)) # 2 = full match, -1 : least match
		var smooth_dot = 0.5 + 0.5 * clamp(raw_dot,-.7,.7)/.7
		var max_speed = 0.35 + 0.85 * smooth_dot * smooth_dot
		if straightlinedur > 20:
			if straightlinedir == straight_dir:
				max_speed *= 1 + 0.25 * inverse_lerp(10,50,clamp(straightlinedur,20,50))
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
	
	if dying:
		showsprite(AAAGHSPRITE)
		#AAAGHSPRITE.setup([21,21,22,23,24],6)
		AAAGHSPRITE.setup([21,32,33,34,35,36,36,],5)
		$sprites.modulate.a = 1 # fposmod(dying * 0.25,1.25) - 0.05 * dying
	elif bufs.has(INVINCBUF):
		if bufs.has(JUSTHURTBUF): showsprite(AAAGHSPRITE)
		elif bufs.has(HURTBUF): showsprite(REDSPRITE)
		elif straightlinedur > 20: showsprite(DASHSPRITE)
		else: showsprite(SNAKESPRITE)
		var iiiii = bufs.read(INVINCBUF)
		if iiiii > 40:
			$sprites.modulate.a = fposmod(iiiii * 0.25,1.25)
		else:
			$sprites.modulate.a = fposmod(iiiii * 0.125,1.25) + 0.25
	elif bufs.has(TURNBUF): showsprite(null)
	elif straightlinedur > 20: showsprite(DASHSPRITE)
	else: showsprite(SNAKESPRITE)
	$sprites.rotation = TAU4 * rot
	#else: showsprite(REDSPRITE)
	

func tryhurtme() -> bool:
	if bufs.has(INVINCBUF): return false;
	for b in [JUSTHURTBUF,HURTBUF,INVINCBUF]:
		bufs.on(b)
	# lose hp? die? idk
	#rot = randi() % 4
	return true
