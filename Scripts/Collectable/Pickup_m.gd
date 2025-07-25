extends Area3D

class_name Pickup

@export var resource_type: Resource

func _ready() -> void:
	connect("body_entered", _on_body_entered)
	
func _on_body_entered(body: Node3D):
	var inventory = body.find_child("Inventory")
	if inventory:
		inventory.add_resources(resource_type, 1)
		queue_free()
