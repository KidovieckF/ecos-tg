extends Node2D

var player_dentro = false
var 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_dentro:
		 pass


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	player_dentro = true


func _on_static_body_2d_body_exited(body: Node2D) -> void:
	player_dentro = false
