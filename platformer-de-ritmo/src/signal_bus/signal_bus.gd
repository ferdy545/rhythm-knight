extends Node

func send(signal_name : String, args : Array):
	broadcast(signal_name, args)
	
func broadcast(signal_name : String, args : Array):
	for receiver in SignalBusReceiver.all(get_tree()):
		receiver.callv("emit_signal", [signal_name] + args)
