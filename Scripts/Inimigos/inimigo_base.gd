extends CharacterBody2D

signal morreu
var speed = 100
@export var player :CharacterBody2D
@export var cena_item : PackedScene
@export var cena_moeda : PackedScene
var vida = 3
var ativo = false
var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

func take_damage(quantidade, cor = Color.WHITE):
	vida -= quantidade
	print("Inimigo tomou dano! Vida restante: ", vida)
	var novo_dano = ind_dano.instantiate() 
	get_parent().add_child(novo_dano)
	novo_dano.global_position = global_position
	novo_dano._mostrar_dano(quantidade, cor)
	if vida <= 0:
		morrer()

func morrer():
	print("1. INIMIGO: Morri e emiti o sinal!")
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
		
