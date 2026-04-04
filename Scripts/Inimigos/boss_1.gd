extends CharacterBody2D

var vida_Maxima = 100
var vida_atual = vida_Maxima
signal tomou_dano
signal morreu
signal nasci
var tipo_atk = ""
var ativo = false
@export var player :CharacterBody2D

func _ready() -> void:
	$SpawnCS.start()
	var hud = get_tree().get_first_node_in_group("HUD")
	tomou_dano.connect(hud.atualizar_vida_boss)
	morreu.connect(hud.sumir_vida)
	$AreaAtaque/CollisionShape2D.set_deferred("disabled", true)
	nasci.connect(hud.abrir_vida_boss)
	nasci.emit(vida_Maxima)

	
func _physics_process(delta: float) -> void:
	if ativo:
		if not player:
			player = get_tree().get_first_node_in_group("Players")
		
		if not player:
			return
		if $AtaqueTimer.is_stopped():
			atacar()
	
func take_damage(quantidade, cor = Color.WHITE):
	vida_atual -= quantidade
	print("Inimigo tomou dano! Vida restante: ", vida_atual)
	tomou_dano.emit(vida_atual)
	
	if vida_atual <= 0:
		morrer()
		
func morrer():
	morreu.emit()
	queue_free()

func atacar():
	var atk = randi_range(1, 2)
	if atk == 1:
		ataque_forte()
	else:
		ataque_normal()
	$AtaqueTimer.start()

func ataque_normal():
	tipo_atk = "normal"
	print("Iniciando animação NORMAL")
	$AreaAtaque.global_position = player.global_position
	$AnimationPlayer.play("ataque_normal")
	
func ataque_forte():
	tipo_atk = "forte"
	print("Iniciando animação FORTE")
	$AreaAtaque.global_position = player.global_position
	$AreaAtaque.scale = Vector2(2,2)
	$AnimationPlayer.play("ataque_pesado")
	$AreaAtaque.scale = Vector2(1,1)


func _on_area_ataque_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		if tipo_atk == "normal":
			body.take_damage(2)
		else:
			body.take_damage(4)


func _on_spawn_cs_timeout() -> void:
	ativo = true
