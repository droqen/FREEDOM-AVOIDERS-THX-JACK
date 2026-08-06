extends NavdiSolePlayerBasics

signal jumped
signal touched(dir:Vector2i)
signal untouched(dir:Vector2i)

enum {
	TOUCHBUF_LEFT = 124124124233309,
	TOUCHBUF_DOWN = 884888450000000,
	TOUCHBUF_RGHT = 905060789070000,
}

var touching := {
	TOUCHBUF_LEFT:false,
	TOUCHBUF_DOWN:false,
	TOUCHBUF_RGHT:false,
}

const TOUCHDIRS = {
	TOUCHBUF_LEFT:Vector2i.LEFT,
	TOUCHBUF_DOWN:Vector2i.DOWN,
	TOUCHBUF_RGHT:Vector2i.RIGHT,
}

func touch(buf) -> void:
	if not touching[buf]:
		touching[buf] = true
		touched.emit(TOUCHDIRS[buf])
	bufs.on(buf)

func _ready() -> void:
	super._ready()
	bufs.setup_bufons([
		TOUCHBUF_LEFT,2,
		TOUCHBUF_DOWN,2,
		TOUCHBUF_RGHT,2,
	])

func _physics_process(_delta: float) -> void:
	var dpad := Pin.get_dpad()
	var jump_hit := Pin.get_jump_hit()
	var jump_held := Pin.get_jump_held()
	var onflor := is_on_floor()
	if onflor: touch(TOUCHBUF_DOWN)
	if jump_hit: bufs.on(JUMPBUF)
	tow_vx(dpad.x, 0.8, 0.05)
	tow_gravity(1.0, 0.023, jump_held, 0.047)
	#tow_gravity(1.0, 0.015, jump_held, 0.05)
	if vx and !mover.try_slip_move(self,solidcast,HORIZONTAL,vx,sign(vy)):
		vx=0
		touch(TOUCHBUF_LEFT if vx < 0 else TOUCHBUF_RGHT)
	if vy and !mover.try_slip_move(self,solidcast,VERTICAL,vy,sign(vx)):
		vy=0
	if bufs.has(TURNBUF): spr.setup([21])
	elif not onflor: spr.setup([11])
	elif dpad.x: spr.setup_forcechangeindex([11,10,12,10],10)
	else: spr.setup_trywaitformatch([20],0,[10,20])
	if bufs.try_eat([FLORBUF, JUMPBUF]):
		vy = -1.0
		jumped.emit()
	
	for buf in touching.keys():
		if touching[buf] and not bufs.has(buf):
			untouched.emit(TOUCHDIRS[buf])
			touching[buf] = false
