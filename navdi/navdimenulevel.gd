extends RefCounted
class_name NavdiMenuLevel
var selectionid:int=0
var identifier:Variant
var menuitems:Array
var menuwrapping:bool
func _init(_my_identifier:Variant,_menuitems:Array,_menuwrapping:bool=true) -> void:
	self.identifier = _my_identifier
	self.menuitems = _menuitems
	self.menuwrapping = _menuwrapping
func try_move(dy:int) -> bool:
	var previd = self.selectionid
	if menuwrapping: selectionid = posmod(selectionid+dy,len(menuitems))
	else: selectionid = clampi(selectionid+dy,0,len(menuitems)-1)
	return previd != self.selectionid
