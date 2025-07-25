extends Structures

@export var wood_resource : Resource
@onready var area_3d: Area3D = $Area3D
var hp = 3

func harvest() -> Resource:
	hp -= 1
	if hp <= 0:
		queue_free() 
	return wood_resource
