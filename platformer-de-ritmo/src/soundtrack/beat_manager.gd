extends Node

var interval
var beat = 0
var current_beat = 0
@export var bpm := 80
@export var _beat = false
@onready var music = $Music
@onready var song_beat : AnimationPlayer = $SongBeat
@onready var signal_bus_sender : SignalBusSender = $SignalBusSender
signal beat_changed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music.play()
	interval = (60.0/bpm) * 2


func _process(delta: float) -> void:
	if beat >= 16:
		current_beat = 0
		
	beat = floori(music.get_playback_position()/interval)
	
	if beat > current_beat:
		print("BEAT")
		current_beat = beat
		signal_bus_sender.send_beat_changed()
