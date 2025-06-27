extends Node
class_name SignalBusReceiver

const GROUP := "RECEIVER"
static var receivers : Array[SignalBusReceiver]

signal player_entered_area
signal player_was_damaged
signal enemy_attack
signal enemy_was_killed
signal beat_changed


func _enter_tree() -> void:
	add_to_group(GROUP)
	

static func all(scene_tree : SceneTree):
	receivers.clear()
	for receiver in scene_tree.get_nodes_in_group(GROUP):
		if receiver:
			receivers.append(receiver)
	
	return receivers
