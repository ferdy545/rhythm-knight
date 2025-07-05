extends Node

var interval
var beat = 0
var current_beat = 0
@export var bpm := 80.0
@export var _beat = false
@onready var music = $Music
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var signal_bus_sender : SignalBusSender = $SignalBusSender
signal beat_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.play()
	interval = (60.0/bpm) * 2 # In this case, interval = 1.5


func _process(delta: float) -> void:
	beat = music.get_playback_position()
	
	# For this inequality, any value between 'interval' and 24.0 (playback length) and
	# reasonably distant from those edge values will work perfectly.
	if abs(current_beat - beat) >= 15.0: 
		current_beat = 0
	
	if beat > current_beat:
		current_beat += interval
		signal_bus_sender.send_beat_changed()
		print("BEAT")
