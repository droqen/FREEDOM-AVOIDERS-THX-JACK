extends ReferenceRect
class_name NavdiAreaPTrigger

var _ph : bool = false
var player_here : bool :
	get : return _ph
	set (v) : if _ph != v: _ph = v; 

func _physics_process(_delta: float) -> void:
	var p = NavdiSolePlayer.GetPlayer(self)
	player_here = (p and get_rect()
		.has_point(p.position))
