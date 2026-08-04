extends Node
class_name NavdiDreamDropper

func _ready() -> void:
	#print("dropper setup success")
	get_window().files_dropped.connect(_on_files_dropped)
	var ecb = JavaScriptBridge.create_callback(_example_callback)
	# TODO: pass this callback to javascript! via  some object:
	var link = JavaScriptBridge.get_interface("navdilink")
	if ecb and link:
		#print("link: ",link)
		#link.testCallback(ecb);
		#print("ecb: ",ecb)
		link.setDropCallback(ecb);

func _example_callback(a) -> void:
	Dreamer.navdilog("dropper","example callback received! %d" % randi())
	print(a)

func _on_files_dropped(files:PackedStringArray) -> void:
	var file_order := range(len(files))
	file_order.shuffle()
	for i in file_order:
		var file := files[i]
		if file.ends_with(".pck"):
			var dream : NavdiDream = Dreamer.dream_packed_dream(file)
			if dream:
				return # done :)
		elif file.contains(".droq"):
			var dream : NavdiDream = Dreamer.dream_packed_dream(file)
			if dream:
				return # done :)
