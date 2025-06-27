extends Node

var interval
var current_beat = 0
@export var bpm := 80
@export var _beat = false
@onready var music = $Music
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var signal_bus_sender : SignalBusSender = $SignalBusSender
signal beat_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interval = (60.0/bpm) * 2


func _process(delta: float) -> void:
	if not music.playing:
		music.play()
		current_beat = 0
		
	var beat = floori(music.get_playback_position()/interval)
	
	if beat > current_beat:
		current_beat = beat
		signal_bus_sender.send_beat_changed()
