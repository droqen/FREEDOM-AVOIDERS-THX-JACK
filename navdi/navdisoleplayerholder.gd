extends Node2D
class_name NavdiSolePlayerHolder
const GROUP_NAME : String = "__NSPH"
static func GetHolder(node_in_tree:Node):
	var holder = node_in_tree.get_tree().get_first_node_in_group(GROUP_NAME)
	if is_instance_valid(holder): return holder # else null
func _ready() -> void:
	add_to_group(GROUP_NAME)
