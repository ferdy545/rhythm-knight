extends Camera2D
class_name Camera

@export var target_path : NodePath
static var target


func _ready() -> void:
	target = get_node(target_path)
	
	if target:
		position = target.position
		
		
func _physics_process(_delta):
	if target:
		position = target.position


static func target_object(object):
	target = object
