extends Node
class_name SignalBusSender

func send_player_entered_area():
	SignalBus.send("player_entered_area", [])
