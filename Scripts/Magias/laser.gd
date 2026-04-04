extends Area2D

var dano_bala
var pos_final
@onready var limite : RayCast2D = $RayCast2D
@onready var mira : Line2D = $Line2D
@onready var laser : Panel = $Panel

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	limite.force_raycast_update()
	if limite.is_colliding():
		
		pos_final = limite.get_collision_point()
		pos_final = to_local(pos_final)
		
	else:
		pos_final = limite.target_position
	mira.set_point_position(1, pos_final)
	laser.size.x = pos_final.x



func start(dano, pos):
	dano_bala = dano
	look_at(get_global_mouse_position())
	limite.target_position = Vector2(1000,0)



func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(dano_bala)
