extends Node

class LogEntry:
	var name : String
	var last_update_ts : int
	var message_history : Array[String] = []
	var last_message : String
	var last_tick : int = 0
	func _init(_name:String) -> void:
		self.name = _name
	func update_message(message : String, tick : int) -> void:
		if message != last_message:
			message_history.append(message)
			last_message = message
			last_tick = tick

var entries : Dictionary
var reprint_queued : bool = true
var reprint_ticker : int = 0
func now() -> int:
	return Time.get_ticks_usec()

func navdilog(key:String,message:String) -> void:
	entries.get_or_add(key,LogEntry.new(key)).update_message(message, now())
	reprint_queued = true
	reprint_ticker = 1000

func display_keys_messages(keysLabel:RichTextLabel, msgsLabel:RichTextLabel, maxLogs:int) -> void:
	keysLabel.text = ''
	msgsLabel.text = ''
	var elist = entries.values()
	elist.sort_custom(func(a,b):return a.last_tick>b.last_tick)
	var later : bool = false
	var _now : int = now()
	for i in range(min(len(elist),maxLogs)):
		if not later and elist[i].last_tick <= _now - 1000000:
			later = true
			keysLabel.text += "[color=#fff3]"
			msgsLabel.text += "[color=#fff3]"
		keysLabel.text += "%s::\n" % [elist[i].name]
		msgsLabel.text += "%s\n" % [elist[i].last_message]

func _ready() -> void:
	$"../..".navdilogged.connect(navdilog)
	var mhd = NavdiGenUtil.gen_megahexdate()
	var prd = NavdiGenUtil.gen_prettydate().split(',')[0].split(' ')
	navdilog("today [[%s]]"%mhd, "%s:'%s' + %s:'%s' + %s:'%s'" % [
		mhd.substr(0,2), prd[0],
		mhd.substr(2,1), prd[1],
		mhd.substr(3,1), prd[2],
	])

func _physics_process(_delta: float) -> void:
	if reprint_ticker <= 0 or reprint_queued:
		reprint_ticker = 100
		reprint_queued = false
		display_keys_messages($Keys, $Messages, 10)
	else:
		reprint_ticker -= 1
