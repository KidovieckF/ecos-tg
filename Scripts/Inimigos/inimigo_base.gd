extends CharacterBody2D

signal morreu
@export var player :CharacterBody2D
@export var cena_item : PackedScene
@export var cena_moeda : PackedScene
@export var data : inimigo_data
var last_direction
@export var ativo = false
var vida_max
var vida_atual
var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")
var morto = false
var dano_pendente = 0
var estado_custom = {}


func _ready() -> void:
	set_physics_process(true) 
	$CollisionShape2D.set_deferred("disabled",false)
	$AreaDano.pegarDano(data.dano)

func _physics_process(delta: float) -> void:
	if vida_atual == null:
		if not player:
			player = get_tree().get_first_node_in_group("Players")
		if player:
			vida_max = data.vida * player.nivel
			vida_atual = vida_max
		else:
			return
			
	dano_na_fila()
	
	if player != null and not morto:
		data.movimento(self,delta)
		if $AcaoTimer.is_stopped() and data.tem_acao:
			data.acao(self, delta)
			
		
func dano_na_fila():
	if dano_pendente > 0 and not morto:
		print("Processando dano_pendente: ", dano_pendente, " | vida_atual ANTES: ", vida_atual)
		vida_atual -= dano_pendente
		dano_pendente = 0
		if vida_atual <= 0:
			print(">>> VIDA ZEROU! morto = true, chamando morrer()")
			morto = true
			$AreaDano.set_deferred("monitoring", false)
			morrer()
			print(">>> VOLTOU DO morrer()")
			return


func take_damage(quantidade, cor = Color.WHITE):
	if morto:
		return
	dano_pendente += quantidade
	var novo_dano = ind_dano.instantiate() 
	get_parent().add_child(novo_dano)
	novo_dano.global_position = global_position
	novo_dano._mostrar_dano(quantidade, cor)

func morrer():
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	$AreaDano.collision_layer = 0
	$AreaDano.collision_mask = 0
	var death = AnimatedSprite2D.new()
	death.sprite_frames = $Sprite2D.sprite_frames
	death.scale = $Sprite2D.scale
	death.play("Morrendo")
	death.animation_finished.connect(queue_free)
	get_parent().add_child(death)
	death.global_position = global_position
	spawn_item()
	queue_free()
	morreu.emit()
	
func spawn_item():
	var sorteio = randi() % 100
	if sorteio <= 50:
		var novo_item = cena_item.instantiate()
		novo_item.position = position
		novo_item.coletado.connect(player.curar)
		get_parent().add_child(novo_item)
		var moeda_nova = cena_moeda.instantiate()
		moeda_nova.position = position
		moeda_nova.coletado.connect(player.coletar_moeda)
		get_parent().add_child(moeda_nova)
		
