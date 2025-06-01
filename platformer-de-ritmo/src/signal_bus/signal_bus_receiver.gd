extends Node
class_name SignalBusReceiver

const GROUP := "RECEIVER"
static var receivers : Array[SignalBusReceiver]

signal player_entered_area


func _enter_tree() -> void:
	add_to_group(GROUP)
	

static func all(scene_tree : SceneTree):
	receivers.clear()
	for receiver in scene_tree.get_nodes_in_group(GROUP):
		if receiver:
			receivers.append(receiver)
	
	return receivers
