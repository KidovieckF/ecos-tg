extends Area2D

var speed: float = 85.0         
var dano: float = 10.0
var duracao: float = 4.0        
var intervalo_tick: float = 0.5  

var player: Node2D = null
var timer_tick: float = 0.0
var player_em_cima: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Players")
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
	
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	
	await get_tree().create_timer(duracao).timeout
	var tween_out = create_tween()
	tween_out.tween_property(self, "modulate:a", 0.0, 0.3)
	tween_out.tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var dir = global_position.direction_to(player.global_position)
		global_position += dir * speed * delta
		
	if player_em_cima and player and is_instance_valid(player):
		timer_tick -= delta
		if timer_tick <= 0.0:
			timer_tick = intervalo_tick
			if player.has_method("take_damage"):
				player.take_damage(dano, Color.CYAN)

func start(pos: Vector2, _dir: Vector2, p_dano: float = 10.0) -> void:
	global_position = pos
	dano = p_dano

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_em_cima = true
		timer_tick = 0.0

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_em_cima = false
