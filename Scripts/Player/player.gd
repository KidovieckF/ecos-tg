extends CharacterBody2D


var speed_atual = 300.0
const JUMP_VELOCITY = -400.0
var pode_tomar_dano = true
var tween_dano

@export var arma : ArmaRecurso
var morto = false


@onready var sprite = $Sprite2D
@onready var hud = get_parent().get_node("HUD/ContainerCoracoes")
@onready var hud_moedas = get_parent().get_node("HUD/ColorRect/Dinheiro")
var game_over_scene = preload("res://Cenas/Mundo/Game_over.tscn")
var magia1 = preload("res://Cenas/Player/Magias/Magia1.tscn")

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if $AttackTimer.is_stopped:
		if Input.is_action_pressed("Atirar"):
			arma.usar_arma(self, delta)
	if Input.is_action_just_released("Atirar"):
		arma.parar_uso(self)
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		if direction.x > 0: 
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		
		velocity = direction * speed_atual
	else:
		velocity.x = move_toward(velocity.x, 0, speed_atual)
		velocity.y = move_toward(velocity.y, 0, speed_atual)

	move_and_slide()

func atirar():
	var nova_magia = arma.projetil.instantiate()
	get_parent().add_child(nova_magia)
	var direcao_calculada = (get_global_mouse_position() - global_position).normalized()
	nova_magia.start(global_position, direcao_calculada, arma.dano, arma.speed)
	$AttackTimer.start()


func take_damage(quantidade, cor = Color.WHITE):
	if pode_tomar_dano == true:
		$Timer.start()
		RecursosGlobais.vidaAtual -= quantidade
		if RecursosGlobais.vidaAtual >= 0 and RecursosGlobais.vidaAtual < hud.get_child_count():
			hud.get_child(RecursosGlobais.vidaAtual).visible = false
		tween_dano = create_tween().set_loops()
		tween_dano.tween_property(sprite, "modulate:a", 0.0, 0.1)
		tween_dano.tween_property(sprite, "modulate:a", 1.0, 0.1)

		print("Tomou dano ", RecursosGlobais.vidaAtual )
		pode_tomar_dano = false
	if RecursosGlobais.vidaAtual <= 0 and morto == false:
		morto = true
		var game_over = game_over_scene.instantiate()
		get_tree().root.add_child(game_over)
		
func curar(quantidade):
	if RecursosGlobais.vidaAtual < RecursosGlobais.vidaMax:
		hud.get_child(RecursosGlobais.vidaAtual).visible = true
		RecursosGlobais.vidaAtual = min(RecursosGlobais.vidaAtual + quantidade, RecursosGlobais.vidaMax)
		
func coletar_moeda():
	hud_moedas.text = "Dinheiro: " + str(RecursosGlobais.moeda)
	

func trocar_camera():
	if $CameraLobby.enabled == true:
		$CameraLobby.enabled = false
		$CameraJogo.enabled = true
	elif $CameraLobby.enabled == false:
		$CameraLobby.enabled = true
		$CameraJogo.enabled = false

func _on_timer_timeout() -> void:
	pode_tomar_dano = true # Replace with function body.
	if tween_dano:
		tween_dano.kill() # Para o motorzinho
		sprite.modulate.a = 1.0 # Garante que ela não pare "invisível"


func _on_attack_timer_timeout() -> void:
	pass
