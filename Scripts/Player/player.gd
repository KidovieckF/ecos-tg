extends CharacterBody2D


const JUMP_VELOCITY = -400.0

@export var personagem : player_data
@export var arma : ArmaRecurso

@onready var sprite = $Sprite2D
@onready var hud = get_tree().get_first_node_in_group("HUD")

var timer_passo: float = 0.0
var pode_tomar_dano = true
var tween_dano
var nivel = 1
var last_direction = Vector2(1,0)
var morto = false
var barra_exp
var xp_atual = 0
var fila_de_niveis: Array[int] = []
var atacando = false
var dashando = false
var direcao_dash = Vector2.ZERO
var direcao_tiro
var pausado = false
var tiro_primario = false
var tiro_secundario = false

var cura_ind = preload("res://Cenas/Player/cura_ind.tscn")
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
	$AttackTimer.wait_time = personagem.atk_cd / RunData.mult_de_atk_speed
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Ultimate") and RunData.barra_ultimate_atual == RunData.barra_ultimate:
		print("Teste")
		
	for upgrade in RunData.armas[0].upgrades_ativos:
		if upgrade.has_method("ao_atualizar_jogador"):
			upgrade.ao_atualizar_jogador(self, delta)

	
	
	if Input.is_action_just_pressed("Mudar"):
		if RunData.armas[1]:
			var aux = RunData.armas[0]
			RunData.armas[0] = RunData.armas[1]
			RunData.armas[1] = aux
	
	if $AttackTimer.is_stopped():
		$AttackTimer.wait_time = personagem.atk_cd / RunData.mult_de_atk_speed
		if Input.is_action_pressed("Atirar") and not tiro_secundario:
			tiro_primario = true
			atacando = true
			var direcao_calculada = (get_global_mouse_position() - global_position).normalized()
			if RunData.gamemode == "Direcional":
				direcao_tiro = last_direction
			elif RunData.gamemode == "Mouse":
				direcao_tiro = direcao_calculada
				
			$Muzzle.position = direcao_tiro * 30.0
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
				$Muzzle.position = direcao_tiro * 30.0
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
	
	var vel_final = RunData.speed_calculado + RunData.speed_bonus_temporario
	
	if direction:
		velocity = direction * vel_final
	else:
		velocity.x = move_toward(velocity.x, 0, vel_final)
		velocity.y = move_toward(velocity.y, 0, vel_final)
	
	
	
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
				
		if velocity == Vector2.ZERO:
			RunData.aplicar_efeitos_parado(self, delta) 
		
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
				velocity = direction * vel_final
			else:
				velocity.x = move_toward(velocity.x, 0, vel_final)
				velocity.y = move_toward(velocity.y, 0, vel_final)

	
	move_and_slide()
	_processar_passos(delta)

func _processar_passos(delta: float) -> void:
	if velocity.length() > 25.0 and not dashando:
		timer_passo -= delta
		if timer_passo <= 0.0:
			var intervalo = clamp(90.0 / velocity.length(), 0.20, 0.42)
			timer_passo = intervalo
			
			AudioManager.tocar_sfx(AudioManager.SFX_PASSO_GRAMA, -20.0, true)
	else:
		timer_passo = 0.06

func atirar():
	var nova_magia = arma.projetil.instantiate()
	get_parent().add_child(nova_magia)
	var direcao_calculada = (last_direction - global_position).normalized()
	nova_magia.start(global_position, direcao_calculada, arma.dano, arma.speed)
	$AttackTimer.start()

func ganhar_xp(quantidade_xp: float) -> void:
	processar_xp_jogador(quantidade_xp)
	
	var arma_ativa = RunData.armas[0]
	if arma_ativa:
		processar_xp_arma(arma_ativa, quantidade_xp)

func processar_xp_jogador(qtd: float) -> void:
	xp_atual += qtd
	
	while xp_atual >= barra_exp:
		xp_atual -= barra_exp
		barra_exp = barra_exp * 1.25
		nivel += 1
		
		var vida_bonus = 10.0
		RunData.vida_max += vida_bonus
		curar(vida_bonus)
		print("🎉 ALICE SUBIU PARA O NÍVEL ", nivel, "! Vida Máxima: ", RunData.vida_max)
		
	if hud and hud.has_method("atualizar_xp"):
		hud.atualizar_xp(xp_atual, barra_exp, nivel)

func processar_xp_arma(arma: ArmaRecurso, qtd: float) -> void:
	arma.xp_atual += qtd
	
	while arma.xp_atual >= arma.barra_exp:
		arma.xp_atual -= arma.barra_exp
		arma.barra_exp = arma.barra_exp * 1.30
		arma.nivel += 1
		
		fila_upgrades_armas.append(arma)
		print("⚡ MAESTRIA: ", arma.nome, " subiu para o Nível ", arma.nivel, "!")
	processar_proximo_upgrade_arma()

# processar o upgrade da arma que matou

var fila_upgrades_armas: Array[ArmaRecurso] = []

func processar_proximo_upgrade_arma() -> void:
	if fila_upgrades_armas.is_empty():
		return
	if get_node_or_null("TelaUpgradeAtiva"):
		return
		
	var arma_que_upou = fila_upgrades_armas.pop_front()
	
	var upg_scene = upgrade.instantiate()
	upg_scene.name = "TelaUpgradeAtiva"
	
	# Passamos para a tela de upgrade exatamente a arma que upou!
	upg_scene.arma_alvo = arma_que_upou
	
	upg_scene.tree_exited.connect(func():
		if not fila_upgrades_armas.is_empty():
			call_deferred("processar_proximo_upgrade_arma")
	)
	
	add_child(upg_scene)

func processar_proximo_upgrade() -> void:
	if fila_de_niveis.is_empty():
		return
	if get_node_or_null("TelaUpgradeAtiva"):
		return
		
	var nivel_do_upgrade = fila_de_niveis.pop_front()
	
	var upg_scene = upgrade.instantiate()
	upg_scene.name = "TelaUpgradeAtiva"
	
	upg_scene.eh_upgrade_de_arma = (nivel_do_upgrade % 5 == 0)
	
	upg_scene.tree_exited.connect(func():
		if not fila_de_niveis.is_empty():
			call_deferred("processar_proximo_upgrade")
	)
	
	add_child(upg_scene)
	

func take_damage(quantidade, cor = Color.WHITE):
	if pode_tomar_dano == true:
		$Timer.start()
		var quantidade_real = quantidade * (1.0 - RunData.dano_reducao)
		RunData.vida_atual -= quantidade_real
		tween_dano = create_tween().set_loops()
		tween_dano.tween_property(sprite, "modulate:a", 0.0, 0.1)
		tween_dano.tween_property(sprite, "modulate:a", 1.0, 0.1)

		print("Tomou dano ", RunData.vida_atual )
		hud.atualizar_vida(RunData.vida_atual, RunData.vida_max)
		pode_tomar_dano = false
	if RunData.vida_atual <= 0 and morto == false:
		SaveManager.registrar_derrota()
		morto = true
		RunData.resetar_run()
		var game_over = game_over_scene.instantiate()
		get_tree().root.add_child(game_over)
		
func curar(quantidade : float):
	var cena_ind_cura = cura_ind.instantiate()
	get_parent().add_child(cena_ind_cura)
	RunData.vida_atual =  min((RunData.vida_atual + quantidade), RunData.vida_max)
	hud.atualizar_vida(RunData.vida_atual, RunData.vida_max)
	cena_ind_cura.global_position = global_position
	cena_ind_cura._mostrar_cura(quantidade, Color.GREEN)
		
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
