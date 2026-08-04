extends ReferenceRect
class_name NavdiViewRect
signal moved

func _ready() -> void:
	NavdiViewer.follow(self)
func move_to(target_position:Vector2) -> void:
	self.position = target_position
	moved.emit()
