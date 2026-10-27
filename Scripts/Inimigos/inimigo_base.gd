extends CharacterBody2D

signal morreu

@export var player :CharacterBody2D
@export var cena_item : PackedScene
@export var cena_moeda : PackedScene
@export var ativo = false
@export var data : inimigo_data

var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")
var cena_drop_artefato = preload("res://Cenas/Artefatos/Artefato_drop.tscn")

var last_direction
var vida_max
var vida_atual
var morto = false
var e_anomalo: bool = false
var dano_pendente = 0
var estado_custom = {}


func _ready() -> void:
	set_physics_process(true) 
	$Hurtbox.set_deferred("disabled",false)
	$AreaDano.pegarDano(data.dano)

func _physics_process(delta: float) -> void:
	if vida_atual == null:
		if not player:
			player = get_tree().get_first_node_in_group("Players")
		if player:
			RunData.multiplicar_dificuldade()
			vida_max = data.vida * RunData.mult_dificuldade
			vida_atual = vida_max
			_aplicar_anomalo()
		else:
			return
			
	dano_na_fila()
	
	if player != null and not morto:
		data.movimento(self,delta)
		if $AcaoTimer.is_stopped() and data.tem_acao:
			data.acao(self, delta)
			
func _aplicar_anomalo() -> void:
	var chance = clamp((RunData.dificuldade - 1) * 1, 1, 1)
	
	if randf() < chance:
		e_anomalo = true
		vida_max *= 2.0
		vida_atual = vida_max
		scale *= 1.25                        
		modulate = Color(1.3, 0.6, 1.6)      
		$AreaDano.pegarDano(data.dano * 2.0)



func dano_na_fila():
	if dano_pendente > 0 and not morto:
		vida_atual -= dano_pendente
		dano_pendente = 0
		if vida_atual <= 0:
			morto = true
			$AreaDano.set_deferred("monitoring", false)
			morrer()
			return



func morrer():
	var player = get_tree().get_first_node_in_group("Players")
	
	if player:
		for upgrade in RunData.armas[0].upgrades_ativos:
			upgrade.ao_inimigo_morrer(self, player)
				
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
	#DROPAR O ARTEFATO
	var artefato_sorteado = RunData.checar_drop_inimigo_comum()
	if artefato_sorteado != null:
		var drop_art = cena_drop_artefato.instantiate()
		get_parent().add_child(drop_art)
		drop_art.configurar(artefato_sorteado)
		espalhar_item(drop_art, randf_range(35, 50))


	var sorteio = randi() % 100
	if sorteio <= 50:
		var novo_item = cena_item.instantiate()
		novo_item.coletado.connect(player.curar)
		get_parent().add_child(novo_item)
		espalhar_item(novo_item, randf_range(20, 35))
		
		var moeda_nova = cena_moeda.instantiate()
		moeda_nova.coletado.connect(player.coletar_moeda)
		get_parent().add_child(moeda_nova)
		espalhar_item(moeda_nova, randf_range(20, 35))

func espalhar_item(item_no: Node2D, distancia: float):
	item_no.global_position = global_position
	var direcao_aleatoria = Vector2.from_angle(randf() * TAU)
	var pos_alvo = global_position + (direcao_aleatoria * distancia)
	
	var tween = item_no.create_tween()
	tween.tween_property(item_no, "global_position", pos_alvo, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
