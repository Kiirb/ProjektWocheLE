extends Attack

#nodes
@onready var collision_detection: Area3D = $collision_detection
@onready var despawn_timer: Timer = $despawn_timer

var me: CharacterBody3D

var damage: float = 10
var dur: float =  10
var size: Vector3 = Vector3(1, 0.1, 1)

#on attack
func attack(from: CharacterBody3D):
	me = from
	damage *= me.stats.dmg_multiplyer

#signals
func _on_collision_detection_body_entered(body: Node3D) -> void:
	super.do_dmg(me, body, damage)

func _on_despawn_timer_timeout() -> void:
	queue_free()
