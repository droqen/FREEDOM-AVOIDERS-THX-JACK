extends HTTPRequest
class_name NavdiBeeper
const BEEPER_BEEP_GROUP : String = &"BeeperGroup"
const URL_PLAY : String = "http://127.0.0.1:3000/play-synth"
const URL_PAUSE: String = "http://127.0.0.1:3000/pause-synth"
const HEADERS : PackedStringArray = ["Content-Type: application/json"]

var last_played_url:String = ''

var navdilink:JavaScriptObject

func _ready() -> void:
	print("clientside NavdiBeeper initialized!")
	if OS.has_feature("editor"):
		print("remember to launch the local beepbox puppet!")
		print("> cd ~/beepboxpuppet")
		print("> HEADFUL=1 node server2.mjs")
	else:
		navdilink = JavaScriptBridge.get_interface("navdilink")
		if navdilink == null:
			push_warning("No navdilink js bridge found... retrying after 1 second")
			await get_tree().create_timer(1).timeout
			if !is_inside_tree(): return
			navdilink = JavaScriptBridge.get_interface("navdilink")
			if navdilink == null:
				push_error("No navdilink js bridge found. (Final.)")
		# we're hitting da browser

#func _physics_process(_delta: float) -> void:
	#var topbeep = get_tree().get_first_node_in_group(BEEPER_BEEP_GROUP)
	#
	#if topbeep: play(topbeep.get_beepbox_url())
	#elif Dreamer.dream_stack and Dreamer.dream_stack[-1]:
		#play(Dreamer.dream_stack[-1].beepbox_url)
	#else: play('') # stop

#func _exit_tree() -> void:
	#play('')

#func play(url:String) -> void:
	#if last_played_url != url:
		#last_played_url = url
		#if url:
			#if navdilink:
				#navdilink.play_bgm_string(url.split('#',false,1)[1])
			#else:
				#print(URL_PLAY)
				#_send_request.call_deferred(URL_PLAY, {
					#"restart": true,
					#"song": url.split('#',false,1)[1]
				#})
		#else:
			#if navdilink:
				#navdilink.stop_bgm()
			#else:
				#_send_request.call_deferred(URL_PAUSE)
		#print("changed to ",last_played_url)

func play_sfx(url:String) -> void:
	if navdilink:
		await navdilink.play_sfx_string(url.split('#',false,1)[1])
	else:
		push_warning("sfx unsupported except on navdilink for now. couldn't play sfx %s" % url)

func synth_set_volume(id:int, volume:float) -> void:
	if navdilink: await navdilink.synthSetVolume(id, volume)
func synth_set_tempo(id:int, bpm:int) -> void:
	if navdilink: await navdilink.synthSetSongTempo(id, bpm)
func synth_create(song_data:String, looping:bool = false) -> int:
	if navdilink: return (navdilink
		.synthCreate(song_data, looping))
	return 0
func synth_pause(id:int) -> void:
	if navdilink: await navdilink.synthPause(id)
func synth_stop(id:int) -> void:
	# the same as kill except non-permanent
	if navdilink: await navdilink.synthStop(id)
func synth_kill(id:int) -> void:
	# stops, then (at some point) deletes permanently?
	if navdilink: await navdilink.synthKill(id)
func synth_play(id:int, volume:float = -1) -> void:
	if volume>=0: synth_set_volume(id, volume)
	if navdilink:
		print("synth_play:#%d" % [id])
		await navdilink.synthPlay(id)
func synth_killall() -> void:
	# detonate all synths byebye
	if navdilink: await navdilink.synthKillAll()

# unused

#func _send_request(url : String, keys : Dictionary = {}) -> void:
	#var err = request(url, HEADERS, HTTPClient.METHOD_POST, JSON.stringify(keys))
	#if err != OK:
		#push_error("NavdiBeeper error %s = %s" % [url, err])
#
#func _on_request_completed(
	#result: int,
	#_response_code: int,
	#_headers: PackedStringArray,
	#_body: PackedByteArray) -> void:
	#print(result)
