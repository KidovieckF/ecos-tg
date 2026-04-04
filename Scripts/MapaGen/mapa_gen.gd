extends Node

@export var player: CharacterBody2D
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var salas_possiveis = [ preload("res://Cenas/Mundo/Salas/sala_base.tscn")] #preload("res://Cenas/Mundo/Salas/sala_2.tscn", preload("res://Cenas/Mundo/Salas/sala_1.tscn")  ]
var sala_loja = preload("res://Cenas/Mundo/Salas/sala_loja.tscn")
var sala_boss =  preload("res://Cenas/Mundo/Salas/sala_boss.tscn")
var porta = preload("res://Cenas/Mundo/Salas/Porta.tscn")
var room_altura = 641
var room_largura = 1139
var room_size = Vector2(room_largura,room_altura)
var salas_criadas = {}
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	generate_level()# Replace with function body.
	player.trocar_camera()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func generate_level():
	var current_pos = Vector2i(0, 0)
	var directions = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
	while salas_criadas.size() < 15:
		var walk_dir = directions.pick_random()
		var sala_sorteada = salas_possiveis.pick_random()
		var nova_sala = sala_sorteada.instantiate()
		
		if salas_criadas.size() == 10:
			nova_sala = sala_loja.instantiate()
		if salas_criadas.size() == 14:
			nova_sala = sala_boss.instantiate()
		if not salas_criadas.has(current_pos):
			nova_sala.global_position = Vector2(current_pos.x * room_size.x, current_pos.y * room_size.y)
			get_parent().add_child.call_deferred(nova_sala)
			salas_criadas[current_pos] = nova_sala
		current_pos += walk_dir
		
	criar_porta()
		
	player.position = room_size / 2
	print("Player gerado no ", player.position)
	
func criar_porta():

	
	for i in salas_criadas:
		var tem_s = false
		var tem_n = false
		var tem_o = false
		var tem_l = false
		var sala_atual = salas_criadas[i]
		if salas_criadas.has(i + Vector2i(1, 0)):
			print("Tem vizinho!")
			var sala_vizinha = salas_criadas[i + Vector2i(1, 0)]
			var nova_porta = porta.instantiate()
			nova_porta.global_position = Vector2((i.x + 1) * room_largura, (i.y * room_altura) + (room_altura / 2))
			nova_porta.rotation = deg_to_rad(90)
			add_child(nova_porta)
			sala_atual.portas_da_sala.append(nova_porta)
			sala_vizinha.portas_da_sala.append(nova_porta)
			tem_l = salas_criadas.has(i + Vector2i(1, 0))
		if salas_criadas.has(i + Vector2i(0, 1)):
			var sala_vizinha = salas_criadas[i + Vector2i(0, 1)]
			var nova_porta = porta.instantiate()
			print("Tem vizinho!")
			nova_porta.global_position = Vector2((i.x * room_largura) + (room_largura / 2 ), (i.y + 1) * room_altura)
			add_child(nova_porta)
			sala_atual.portas_da_sala.append(nova_porta)
			sala_vizinha.portas_da_sala.append(nova_porta)
			tem_s = salas_criadas.has(i + Vector2i(0, 1))
		if salas_criadas.has(i + Vector2i(-1, 0)):
			tem_o = salas_criadas.has(i + Vector2i(-1, 0))
		if salas_criadas.has(i + Vector2i(0, -1)):
			tem_n = salas_criadas.has(i + Vector2i(0, -1))
		sala_atual.ajustar_parede(tem_n, tem_s, tem_l, tem_o)

		 
	
	



	

	
