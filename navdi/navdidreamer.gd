extends Node
class_name NavdiDreamer

var dream_stack : Array[NavdiDream] = []
var dream_depth : int = -1

var _memory_stack : Array[Dictionary]

func w(k,v,d:NavdiDream=null):
	#prints("w",k,v,d)
	navdilog(k,str(v))
	if dream_depth < 0:
		push_error("dream depth is -1, meaning Dreamer has not been initiated - w (write) does not work")
	elif d == null:
		_memory_stack[dream_depth][k] = v
	else:
		var i = dream_stack.find(d)
		#print(i)
		if i >= 0:
			_memory_stack[i][k] = v
		else:
			push_error("dream %s is undreamt - w (write) does not work on dreams not currently in the dream stack")
func r(k,d=null):
	#print("r",k)
	for i in range(0,dream_depth+1):
		if _memory_stack[i].has(k):
			#prints("hello i has:", _memory_stack[i][k])
			navdilog(k, str(_memory_stack[i][k]) + " (read)")
			return _memory_stack[i][k]
	navdilog(k,str(d) + " (default)")
	return d
func first(k)->bool:
	if r(k)==null: w(k,1); return true;
	return false # else<

func _goto_current_dream_packed():
	if dream_depth < 0:
		push_error("goto current dream packed failed - dream depth < 0 - quitting")
		get_tree().quit(0)
	else:
		var d : NavdiDream = dream_stack[dream_depth]
		if d == null:
			#print(dream_stack)
			#print(dream_depth)
			#print(dream_stack[dream_depth])
			push_error("goto current dream packed failed - current dream is null.")
		elif d.packed_scene == null:
			push_error("goto current dream packed failed - dream %s has no packed scene" % dream_stack[dream_depth])
		else:
			var ps : PackedScene = d.packed_scene
			await get_tree().process_frame # wait 1 frame... in the long run we could be waiting longer than this
			var err = get_tree().change_scene_to_packed(ps)
			if err != OK:
				push_error("failed to change scene to packed %s of dream %s : reason %s" % [ps, d , err])

func dream(d:NavdiDream) -> void:
	if d in dream_stack:
		push_error("already inside dream %s" % d)
	else:
		dream_stack.append(d)
		_memory_stack.append(Dictionary())
		dream_depth += 1
		_goto_current_dream_packed()

func startdreamtransition(d:NavdiDream) -> void:
	# look at current dream, fuck it up, then go.
	d.scout()
	if d._tiles or d._sheet:
		_recursive_apply_dream_assets(
			get_tree().current_scene,
			d._pixel,
			d._tiles,
			d._sheet,
		)
		var freezetime : float = randf_range(0.1,0.2)
		if randf () < 0.25: freezetime *= randf_range(2.0,5.0)
		await get_tree().create_timer(freezetime).timeout
	if is_inside_tree():
		dreamfresh(d)
	else:
		push_error("ERR - NavdiDreamer after pause is no longer inside the tree")

func _recursive_apply_dream_assets(n:Node,p:Variant,t:TileSet,s:Sheet) -> void:
	if n is SheetSprite and s:
		(n as SheetSprite).sheet = s
		n.process_mode = Node.PROCESS_MODE_ALWAYS
	elif n is TileMapLayer and t:
		(n as TileMapLayer).tile_set = t
	elif n is ColorRect and p is Color:
		(n as ColorRect).color = (p as Color)
	else:
		n.process_mode = Node.PROCESS_MODE_DISABLED
		if n is CanvasItem:
			(n as CanvasItem).self_modulate = Color(0,0,0,0)
			# everything else invisible.
	
	for child in n.get_children():
		_recursive_apply_dream_assets(child,p,t,s)

func dreamfresh(d:NavdiDream) -> void:
	dream_stack=[d]
	_memory_stack=[Dictionary()]
	dream_depth=0
	_goto_current_dream_packed()

func reset():
	_goto_current_dream_packed()

func wake() -> void:
	dream_stack.pop_back()
	_memory_stack.pop_back()
	dream_depth -= 1
	if dream_depth >= 0:
		_goto_current_dream_packed()
	else:
		# save memories?
		get_tree().quit(0) # awake

func wake_to(d:NavdiDream):
	var i = dream_stack.find(d)
	if i >= 0:
		dream_stack = dream_stack.slice(0, i + 1)
		dream_depth = i
		_goto_current_dream_packed()
	else:
		push_error("can't wake up to undreamt dream %s" % d); return false;

func spawn(node_or_packed, parent : Node = null) -> HandledNodeSpawn:
	var hns = HandledNodeSpawn.new(node_or_packed)
	if !parent: parent = get_tree().current_scene
	if hns.n and parent:
		_add_to_and_own.call_deferred(hns.n, parent)
	else:
		push_error("spawning %s to parent %s failed"
			% [node_or_packed, parent])
	return hns

func navdilog(key:String,value:String) -> void:
	NavdiViewer.navdilog(self,key,value)

func _add_to_and_own(ch:Node, par:Node) -> void:
	par.add_child(ch)
	ch.owner = par.owner if par.owner else par

func dream_packed_dream(dream_pck_filepath: String, with_transition : bool = true) -> NavdiDream:
	#print("*** load packed dream (%s)" % dream_pck_filepath)
	var extracted_dream_name : String = ''
	if dream_pck_filepath.ends_with(".pck"):
		var dream_broken := (dream_pck_filepath
			.rsplit("/",false,1)[-1]
			.split('.',false)
		)
		extracted_dream_name = dream_broken[-1]
		if len(dream_broken) > 1 and dream_broken[-1] == "pck":
			extracted_dream_name = dream_broken[-2]
	elif dream_pck_filepath.contains(".droq"):
		extracted_dream_name = dream_pck_filepath.rsplit(".droq",true,1)[-1]
	
	if extracted_dream_name:
		#print("*** about to load resource pack..")
		var _success = ProjectSettings.load_resource_pack(dream_pck_filepath, true)
		#print("*** load resource pack success? ",_success)
		var expected_dream_file_path = "res://dreams/%s/%s_Dream.tres" % [
			extracted_dream_name,
			extracted_dream_name]
		#print("*** expected path: ",expected_dream_file_path)
		var expected_dream = ResourceLoader.load(expected_dream_file_path, "NavdiDream", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if expected_dream:
			if expected_dream is NavdiDream:
				if with_transition:
					startdreamtransition(expected_dream)
				else:
					dreamfresh(expected_dream)
				navdilog("lpck", "Dreaming... %s" % extracted_dream_name)
				return expected_dream
			else:
				navdilog("lpck", "Corrupted dream found at %s" % expected_dream_file_path)
				return null
		else:
			navdilog("lpck", "Expected dream not found at %s" % expected_dream_file_path)
			return null
			#dream()
	return null

class HandledNodeSpawn:
	var n : Node
	func _init(obj_or_packed):
		var obj = obj_or_packed
		if obj is PackedScene:
			obj = obj_or_packed.instantiate()
		if obj is Node:
			n = obj # TODO: to duplicate or not to duplicate...
		else:
			n = null # remain null
			push_error(
				"HandledNodeSpawn n failed ; "+
					"%s (%s) is not Node or PackedScene"
				% [obj, obj_or_packed] )
	func setup_pos(pos:Vector2) -> HandledNodeSpawn:
		if n and n is Node2D:
			n.position = pos
		else:
			push_error("setup_pos failed ; n %s is not Node2D" % n)
		return self
	func setup_varvals(varvals:Array) -> HandledNodeSpawn:
		if n and n is Object:
			for i in range(0, len(varvals)-1, 2):
				n[varvals[i]] = varvals[i+1]
		else:
			push_error("setup_varvals failed ; n %s is not Object" % n)
		return self

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if (event as InputEventKey).keycode == KEY_ESCAPE:
			if OS.has_feature("editor"):
				wake()
