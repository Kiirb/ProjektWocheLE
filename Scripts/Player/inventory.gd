extends Node

class_name Inventory

@export var resources: Dictionary = { } 

func add_resources(type: Resource, amount: float):
	if resources.has(type):
		resources[type] += amount
	else:
		resources[type] = amount

func get_ammount(type: Resource) -> int:
	if resources.has(type):
		return resources[type]
	else:
		resources[type] = 0.0
		return resources[type]
