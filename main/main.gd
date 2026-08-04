extends Node2D

@export var first_dream : NavdiDream

func _ready() -> void:
	Dreamer.dream(first_dream)
