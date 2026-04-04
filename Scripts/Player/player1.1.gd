extends CharacterBody2D


const SPEED = 600.0
const JUMP_VELOCITY = -400.0

@onready var sprite = $Sprite2D
var magia1 = preload("res://Cenas/Magias/Magia1.tscn")
var last_facing_direction = Vector2.RIGHT


func _physics_process(delta: float) -> void:
	
	
	
	if Input.is_action_just_pressed("Atirar"):
		atirar()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		if direction.x > 0: 
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if direction != Vector2(0,0):
		last_facing_direction = direction
	move_and_slide()

func atirar():
	var nova_magia = magia1.instantiate()
	get_parent().add_child(nova_magia)
	var direcao_calculada = (get_global_mouse_position() - global_position).normalized()
	nova_magia.start(global_position, last_facing_direction)
	
