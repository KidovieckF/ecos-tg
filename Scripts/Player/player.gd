extends CharacterBody2D


const JUMP_VELOCITY = -400.0

@export var personagem : player_data
@export var arma : ArmaRecurso

@onready var sprite = $Sprite2D
@onready var hud = get_tree().get_first_node_in_group("HUD")

var pode_tomar_dano = true
var tween_dano
var nivel = 1
var last_direction = Vector2(1,0)
var morto = false
var barra_exp
var xp_atual = 0
var atacando = false
var dashando = false
var direcao_dash = Vector2.ZERO
var direcao_tiro
var pausado = false
var tiro_primario = false
var tiro_secundario = false
var game_over_scene = preload("res://Cenas/Mundo/Game_over.tscn")
var upgrade = preload("res://Hud_upgrade.tscn")
var pause_scene = preload("res://Cenas/Huds/hud_pause.tscn")
var magia1 = preload("res://Cenas/Player/Magias/Magia1.tscn")

func _ready() -> void:
		
	if RecursosGlobais.arma_escolhida:
		arma = RecursosGlobais.arma_escolhida
	if RunData.arma_escolhida == null:
		RunData.iniciar_run(personagem, arma)
	RunData.carregar_player(self)
	$AttackTimer.wait_time = personagem.atk_cd
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Mudar"):
		if RunData.armas[1]:
			var aux = RunData.armas[0]
			RunData.armas[0] = RunData.armas[1]
			RunData.armas[1] = aux
	
	if $AttackTimer.is_stopped():
		if Input.is_action_pressed("Atirar") and not tiro_secundario:
			tiro_primario = true
			atacando = true
			var direcao_calculada = (get_global_mouse_position() - global_position).normalized()
			if RunData.gamemode == "Direcional":
				direcao_tiro = last_direction
			elif RunData.gamemode == "Mouse":
				direcao_tiro = direcao_calculada
			RunData.armas[0].usar_arma(self, delta, RunData.dano_adicional, RunData.dano_multiplicador, direcao_tiro)
			if abs(direcao_calculada.x) > abs(direcao_calculada.y) and direcao_calculada.x > 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("AtirandoLado")
			elif abs(direcao_calculada.x) > abs(direcao_calculada.y) and direcao_calculada.x < 0:
				$Sprite2D.flip_h = true
				$Sprite2D.play("AtirandoLado")
			elif abs(direcao_calculada.y) > abs(direcao_calculada.x) and direcao_calculada.y < 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("AtirandoCostas")
			elif abs(direcao_calculada.y) > abs(direcao_calculada.x) and direcao_calculada.y > 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("AtirandoFrente")
				
		if Input.is_action_pressed("Atirar2") and not tiro_primario:
			if RunData.armas[1]:
				tiro_secundario = true
				atacando = true
				var direcao_calculada = (get_global_mouse_position() - global_position).normalized()
				if RunData.gamemode == "Direcional":
					direcao_tiro = last_direction
				elif RunData.gamemode == "Mouse":
					direcao_tiro = direcao_calculada
				
				RunData.armas[1].usar_arma(self, delta, RunData.dano_adicional, RunData.dano_multiplicador, direcao_tiro)

				if abs(direcao_calculada.x) > abs(direcao_calculada.y) and direcao_calculada.x > 0:
					$Sprite2D.flip_h = false
					$Sprite2D.play("AtirandoLado")
				elif abs(direcao_calculada.x) > abs(direcao_calculada.y) and direcao_calculada.x < 0:
					$Sprite2D.flip_h = true
					$Sprite2D.play("AtirandoLado")
				elif abs(direcao_calculada.y) > abs(direcao_calculada.x) and direcao_calculada.y < 0:
					$Sprite2D.flip_h = false
					$Sprite2D.play("AtirandoCostas")
				elif abs(direcao_calculada.y) > abs(direcao_calculada.x) and direcao_calculada.y > 0:
					$Sprite2D.flip_h = false
					$Sprite2D.play("AtirandoFrente")
				
	if Input.is_action_just_released("Atirar"):
		tiro_primario = false
		atacando = false
		RunData.armas[0].parar_uso(self)
	if Input.is_action_just_released("Atirar2"):
		tiro_secundario = false
		atacando = false
		RunData.armas[0].parar_uso(self)
	
	

	var direction := Input.get_vector("Esquerda", "Direita", "Cima", "Baixo")
	
	if direction:
		velocity = direction * RunData.speed_calculado
	else:
		velocity.x = move_toward(velocity.x, 0, RunData.speed_calculado)
		velocity.y = move_toward(velocity.y, 0, RunData.speed_calculado)
	
	
	
	if not atacando:
		if direction:
			if direction.x > 0: 
				last_direction = direction
				$Sprite2D.flip_h = false
				$Sprite2D.play("AndandoLado")
			elif direction.x < 0:
				last_direction = direction
				$Sprite2D.flip_h = true
				$Sprite2D.play("AndandoLado")
			elif direction.y > 0:
				last_direction = direction
				$Sprite2D.flip_h = false
				$Sprite2D.play("AndandoFrente")
			elif direction.y < 0:
				last_direction = direction
				$Sprite2D.flip_h = false
				$Sprite2D.play("AndandoCosta")
	
		if direction == Vector2.ZERO:
			if last_direction.x > 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("IdleLado") 
			elif last_direction.x < 0:
				$Sprite2D.flip_h = true
				$Sprite2D.play("IdleLado")
			elif last_direction.y > 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("IdleFrente")
			elif last_direction.y < 0:
				$Sprite2D.flip_h = false
				$Sprite2D.play("IdleCostas")
		
		if Input.is_action_just_pressed("Dash") and not dashando and direction != Vector2.ZERO and $DashCD.is_stopped():     
			$DashCD.start()
			dashando = true
			direcao_dash = direction
			pode_tomar_dano = false 
			await get_tree().create_timer(0.2).timeout 
			dashando = false
			pode_tomar_dano = true
		if dashando:
			velocity = direcao_dash * RunData.speed_calculado * 2.5 
		else:
			if direction:
				velocity = direction * RunData.speed_calculado
			else:
				velocity.x = move_toward(velocity.x, 0, RunData.speed_calculado)
				velocity.y = move_toward(velocity.y, 0, RunData.speed_calculado)

	move_and_slide()

func atirar():
	var nova_magia = arma.projetil.instantiate()
	get_parent().add_child(nova_magia)
	var direcao_calculada = (last_direction - global_position).normalized()
	nova_magia.start(global_position, direcao_calculada, arma.dano, arma.speed)
	$AttackTimer.start()

func ganhar_xp(exp):
	xp_atual += exp 
	print("EXP: ", xp_atual)
	if xp_atual >= barra_exp:
		xp_atual = 0
		barra_exp = barra_exp * 1.25
		print("upei de nivel")
		nivel +=1
		print("nivel: ",nivel)
		var upg_scene = upgrade.instantiate()
		add_child(upg_scene)
		get_tree().paused = true
	hud.atualizar_xp(xp_atual, barra_exp, nivel)
	

func take_damage(quantidade, cor = Color.WHITE):
	if pode_tomar_dano == true:
		$Timer.start()
		RunData.vida_atual -= quantidade
		tween_dano = create_tween().set_loops()
		tween_dano.tween_property(sprite, "modulate:a", 0.0, 0.1)
		tween_dano.tween_property(sprite, "modulate:a", 1.0, 0.1)

		print("Tomou dano ", RunData.vida_atual )
		hud.atualizar_vida(RunData.vida_atual, RunData.vida_max)
		pode_tomar_dano = false
	if RunData.vida_atual <= 0 and morto == false:
		morto = true
		RunData.resetar_run()
		var game_over = game_over_scene.instantiate()
		get_tree().root.add_child(game_over)
		
func curar(quantidade):
	RunData.vida_atual =  min((RunData.vida_atual + quantidade), RunData.vida_max)
	hud.atualizar_vida(RunData.vida_atual, RunData.vida_max)
		
func coletar_moeda():
	hud.atualizar_dinheiro()
	

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
