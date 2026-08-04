extends Node
class_name NavdiBeep

var _synthid : int = 0
@export var url : String
@export var autoplay : bool = false
@export var play_volume : float = 1
@export var looping : bool = false
@export var tempo : int = -1 :
	set(v): if tempo != v:
		tempo = v
		if _synthid: Beeper.synth_set_tempo(_synthid, tempo)
var destroyed : bool = false
var _volume : float = 1.0
var volume :
	get () : return _volume
	set (v) :
		_volume = v
		if _synthid:
			Beeper.synth_set_volume(_synthid, v)

func _initialize_synth() -> void:
	if destroyed: push_error("initialized after destroy"); return;
	if !_synthid:
		_synthid = Beeper.synth_create(get_beepbox_song_code(), looping)
		if _synthid:
			Beeper.synth_set_volume(_synthid, _volume)
			if tempo >= 0: Beeper.synth_set_tempo(_synthid, tempo)
			else: tempo = -1 #? ??

func _destroy_synth() -> void:
	if _synthid and not destroyed: Beeper.synth_kill(_synthid)
	destroyed = true

func _enter_tree() -> void:
	_initialize_synth() # try right away
	if autoplay: play(play_volume)

func _exit_tree() -> void:
	_destroy_synth()

#func _ready() -> void:
	#add_to_group(NavdiBeeper.BEEPER_BEEP_GROUP)

func get_beepbox_url() -> String:
	return url

func get_beepbox_song_code() -> String:
	if url: return url.split('#',false,1)[1]
	else: return ''

func play(set_volume : float = -1) -> void:
	_initialize_synth()
	if _synthid:
		print("play beep %s, i'm looping? %s" % [name, looping])
		volume = set_volume if set_volume >= 0 else play_volume
		Beeper.synth_play(_synthid, set_volume
			if set_volume >= 0
			else play_volume)
	else:
		push_warning("failed to play beep %s, no synth id" % name)

func pause() -> void:
	_initialize_synth()
	if _synthid: Beeper.synth_pause(_synthid)
	
func stop() -> void:
	_initialize_synth()
	if _synthid: Beeper.synth_stop(_synthid)
