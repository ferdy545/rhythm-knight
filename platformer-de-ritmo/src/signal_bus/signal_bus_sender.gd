extends Node
class_name SignalBusSender


func send_player_entered_area(enemy):
	SignalBus.send("player_entered_area", [enemy])
