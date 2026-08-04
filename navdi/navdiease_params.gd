extends Resource
class_name NavdiEaseParams

@export var sloppiness : float = 0.5
@export var accsloppiness : float = 0.2
@export var sloppyfriction : float = 0.8
@export var unsloppy_flat : float = 0.01

func setup(slop:float,acc:float,fric:float,flat:float) -> NavdiEaseParams:
	sloppiness = slop
	accsloppiness = acc
	sloppyfriction = fric
	unsloppy_flat = flat
	return self
