// general purpose API for usage by navdi

const navdilink = {
			globalAudioCtx : new (window.AudioContext || window.webkitAudioContext)({ latencyHint: "interactive" }),
			_resume_ctx(){
				if (this.globalAudioCtx.state != "running") { this.globalAudioCtx.resume(); }
			},
			onDrop(files){
				console.log("navdilink default onDrop has not been overridden yet")
			},
			setDropCallback(cb){
				console.log("navdilink setDropCallback disabled; Godot web builds handle it fine themselves")
				// this.onDrop=cb;
			},

			_deadSynths : [],
			synthKillAll(){
				for (const [id, synth] of this._synths) {
					this.synthKill(id);
				}
				this._synths = {}; // clear all.
			},
			_synths : {},
			_synthNextCreateId : 1,
			synthCreate(songData, looping=false, custom_id=null){
				const id = custom_id || this._synthNextCreateId++;
				const s = new beepbox.Synth(songData, this.globalAudioCtx);
				if (!looping) s.loopRepeatCount = 0;
				this._synths[id] = s;
				return id;
			},
			synthKill(id){
				this.synthStop(id);
				const s = this._synths[id];
				if(s.playing) {
					this._deadSynths.push(s);
					// wait until no longer playing, custom code needed
					s.pause();
				}
				delete this._synths[id];

			},
			synthPlay(id) { const s=this._synths[id]; if(s) { if (s.loopRepeatCount==0 || s.suppressNewTones) { s.snapToStart(); } s.suppressNewTones = false; s.play(); } },
			synthPause(id) { const s=this._synths[id]; if(s) s.pause(); },
			synthStop(id) { const s=this._synths[id]; if(s) { s.freeAllTones(); s.suppressNewTones = true; } },
			synthGetPlayhead(id) { const s=this._synths[id]; return s ? s.playhead : 0.0; },
			synthSetVolume(id,v) { const s=this._synths[id]; if (s) s.volume=v; },
			synthSetSongTempo(id,bpm) { const s=this._synths[id]; if (s) s.song.tempo=Math.max(15,bpm); },

			_bgm_synth_id : null,
			play_bgm_string(bgm_string){
				this.stop_bgm();
				this._bgm_synth_id = this.synthCreate(bgm_string,true);
				this.synthPlay(this._bgm_synth_id);
			},
			stop_bgm(){
				if(this._bgm_synth_id!=null) {
					this.synthKill(this._bgm_synth_id);
					this._bgm_synth_id = null;
				}
			},
			play_sfx_string(sfx_string){
				if (!(sfx_string in this._synths)) {
					this.synthCreate(this._synths[sfx_string],false,sfx_string);
				}
				this.synthPlay(sfx_string);
			},
};

document.addEventListener('click', ()=>{
	navdilink._resume_ctx();
	console.log(navdilink._synths);
	// don't prevent default
});
document.addEventListener('keydown', (e) => {
	navdilink._resume_ctx();
	// don't prevent default
});
document.addEventListener('dragover', (e)=>{
	e.preventDefault()
});
document.addEventListener('drop', (e) => {
	navdilink._resume_ctx();
	console.log(e.dataTransfer.files);
	// document.getElementById('file').files = e.dataTransfer.files;
	navdilink.onDrop(e.dataTransfer.files);
	e.preventDefault();
});

window.navdilink = navdilink;
