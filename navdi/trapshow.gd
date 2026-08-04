extends CanvasItem

func _ready() -> void:
	update()
	
func _physics_process(_delta: float) -> void:
	update()

func update() -> void:
	if get_parent() is NavdiAreaPTrigger:
		if (get_parent() as NavdiAreaPTrigger).player_here:
			show()
		else:
			hide()
