extends Node
class_name SignalBusSender


func send_player_entered_area(enemy):
	SignalBus.send("player_entered_area", [enemy])
	

func send_player_was_damaged():
	SignalBus.send("player_was_damaged", [])
	

func send_enemy_attack(enemy):
	SignalBus.send("enemy_attack", [enemy])

	
func send_enemy_was_killed(enemy):
	SignalBus.send("enemy_was_killed", [enemy])
	

func send_beat_changed():
	SignalBus.send("beat_changed", [])
