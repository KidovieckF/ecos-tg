extends Area2D
func _ready() -> void:
	
	$CollisionShape2D.set_deferred("disabled", true)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		body.take_damage(99999)

func ativar():
	$CollisionShape2D.set_deferred("disabled", false)
