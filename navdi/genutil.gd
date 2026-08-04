@tool
extends Object
class_name NavdiGenUtil

#func _run() -> void:
	#print(gen_dreamnotes("test"))

static func gen_dreamnotes(dreamname:String) -> String:
	seed(dreamname.hash())
	var dreamnotes : String = (
"""
	Notes for dream '%s'
	created %s
	
	---
	
	Tarot card for this project:
	%s. %s
"""
		% [
			dreamname,
			gen_prettydate(),
			gen_az(), gen_simpletarot(),
		])
	randomize()
	return dreamnotes

const TAROT = ['the fool','the magician','the high priestess','the empress','the emperor','the hierophant','the lovers','the chariot','strength','the hermit','the wheel of fortune','justice','the hanged man','death','temperance','the devil','the tower','the star','the moon','the sun','judgement','the world','ace of coins','ace of cups','ace of swords','ace of wands','two of coins','two of cups','two of swords','two of wands','three of coins','three of cups','three of swords','three of wands','four of coins','four of cups','four of swords','four of wands','five of coins','five of cups','five of swords','five of wands','six of coins','six of cups','six of swords','six of wands','seven of coins','seven of cups','seven of swords','seven of wands','eight of coins','eight of cups','eight of swords','eight of wands','nine of coins','nine of cups','nine of swords','nine of wands','ten of coins','ten of cups','ten of swords','ten of wands','page of coins','page of cups','page of swords','page of wands','knight of coins','knight of cups','knight of swords','knight of wands','queen of coins','queen of cups','queen of swords','queen of wands','king of coins','king of cups','king of swords','king of wands']
const ALPHABET = 'qwertyuiopasdfghjklzxcvbnm'
const MONTHS = ['Invalid Zero Month',
	'January', 'February', 'March', 'April',
	'May', 'June', 'July', 'August',
	'September', 'October', 'November', 'December',]

static func gen_megahexdate() -> String:
	var now = Time.get_datetime_dict_from_system()
	return "%d%X%s" % [
		now.year-1991,
		now.month,
		"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"[now.day]
	]

static func gen_prettydate() -> String:
	var now = Time.get_datetime_dict_from_system()
	return "%d %s %d, at %02d:%02d" % [
		now.year, MONTHS[now.month], now.day, 
			# at
		now.hour, now.minute,
	]
static func gen_az() -> String:
	return ALPHABET[randi()%len(ALPHABET)]
static func gen_simpletarot() -> String:
	return TAROT[randi()%len(TAROT)]
static func gen_oobdir(pos:Vector2,rect:Rect2i,margin:float=0.0) -> Vector2i:
	# returns a - sign value if out of bounds in a - direction (up, left)
	# returns a + sign value if out of bounds in a + direction (right, down)
	# margin>0 shrinks the rect, making oobdir *more sensitive*
	var x0:int = rect.position.x
	var x1:int = x0 + rect.size.x
	var y0:int = rect.position.y
	var y1:int = y0 + rect.size.y
	return Vector2i(
		(-1 if pos.x < x0+margin else 0)
		+(1 if pos.x > x1-margin else 0),
		(-1 if pos.y < y0+margin else 0)
		+(1 if pos.y > y1-margin else 0)
	)
static func shrink_rect2(rect:Rect2,shrink:float) -> Rect2:
	return Rect2(
		rect.position
			+ Vector2(shrink,shrink),
		rect.size
			- Vector2(shrink+shrink,shrink+shrink))
static func shrink_rect2i(rect:Rect2i,shrink:int) -> Rect2i:
	return Rect2i(
		rect.position
			+ Vector2i(shrink,shrink),
		rect.size
			- Vector2i(shrink+shrink,shrink+shrink))
