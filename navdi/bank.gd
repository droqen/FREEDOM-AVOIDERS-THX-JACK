extends Node
class_name Bank

@export var spawnparent : Node
@export var prefabs : Array[PackedScene]

var _spawnables : Dictionary[String, Node]
var _spawnableindex : Dictionary[String, int]

func _ready() -> void:
	if spawnparent == null: spawnparent = get_parent()
	for child in get_children():
		_spawnables[child.name] = child.duplicate()
		child.hide()
		child.process_mode = Node.PROCESS_MODE_DISABLED
		child.queue_free()
	for prefab in prefabs:
		#print(prefab, prefab.resource_path.rsplit("/",true,1)[1])
		_spawnables[prefab.resource_path.rsplit("/",true,1)[1]] = prefab.instantiate()

func spawn(objname : String, prespawn : Callable = _nocall):
	var original = _spawnables.get(objname, null)
	if original:
		var idx : int = _spawnableindex.get(objname, 0)
		_spawnableindex[objname] = idx + 1
		var spawned = original.duplicate()
		spawned.name += "%04d"%idx
		if prespawn != _nocall: prespawn.call(spawned)
		spawnparent.add_child(spawned, true)
		spawned.owner = spawnparent.owner if spawnparent.owner else spawnparent;
		return spawned
	else:
		push_warning("bank - no spawnable '%s'" % objname)

func _nocall(obj): pass
