extends Area2D

var dano_tick: float = 6.0
var player_dentro: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$TimerDano.timeout.connect(_on_timer_dano_timeout)
	
	$AnimatedSprite2D.play("default")
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_dentro = body
		body.take_damage(dano_tick)
		$TimerDano.start(0.5)

func _on_body_exited(body: Node2D) -> void:
	if body == player_dentro:
		player_dentro = null

func _on_timer_dano_timeout() -> void:
	if is_instance_valid(player_dentro):
		player_dentro.take_damage(dano_tick)
