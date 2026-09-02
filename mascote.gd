extends CharacterBody2D

@export var player : CharacterBody2D
@export var inimigo : CharacterBody2D
@export var mascote : MascoteRucurso
var is_in_range = []

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Players")
	mascote.movimentacao(self, player)
	move_and_slide()

func _on_range_area_entered(area : Area2D) -> void:	
	var dono_da_area = area.get_parent()
	if dono_da_area != null and dono_da_area.is_in_group("Inimigos"):
		is_in_range.append(dono_da_area)
		if $AtkTimer.is_stopped():
			$AtkTimer.start()


func _on_range_area_exited(area : Area2D) -> void:
	var dono_da_area = area.get_parent()
	
	if dono_da_area != null and dono_da_area.is_in_group("Inimigos"):
		is_in_range.erase(dono_da_area)



func _on_atk_timer_timeout() -> void:
	print("O Timer disparou!")
	var alvo_proximo = null
	var distancia_minima = 99999
	for inimigo in is_in_range:
		var dist = global_position.distance_to(inimigo.global_position)
		if dist < distancia_minima:
			distancia_minima = dist
			alvo_proximo = inimigo
	if alvo_proximo != null:
		print("Vou atacar o alvo: ", alvo_proximo)
		mascote.atacar(self, alvo_proximo)
		
