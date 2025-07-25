extends CharacterBody3D
class_name  AutoAttackProjectile

@export var direction: Vector3 = Vector3.ZERO
var speed: float

signal hit_target(target:Node,attacker:CharacterBody3D)
var origin_position: Vector3

@onready var hitbox: Area3D = $Hitbox
@export var particles: GPUParticles3D

var body_ref: CharacterBody3D
var manager: AutoAttackManager
var target_ref: Node3D


func _ready():
	origin_position = global_position
	
func _physics_process(_delta):
	
	velocity = direction *  speed
	move_and_slide()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == body_ref:  # Prevent friendly fire if ne ded
		return
	if body == self:
		return
	if body is Enemy and body_ref is Enemy:
		return
	if body is CharacterBody3D:
		emit_signal("hit_target", body)
	queue_free()
