extends Area2D

var empurro_dist
var speed
var angulo = 0.0
var raio = 120.0
var meu_indice = 0
var total_escudos = 1

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Players")
	var total_escudos = RunData.egides_totais
	var meu_indice = RunData.egides_ativas.find(self)
	if player != null and meu_indice != -1 and total_escudos > 0:
		var tempo = Time.get_ticks_msec() / 1000.0
		var angulo_base = tempo * speed
		
		var espacamento = TAU / total_escudos
		var angulo_final = angulo_base + (espacamento * meu_indice)
		
		global_position.x = player.global_position.x + cos(angulo_final) * raio
		global_position.y = player.global_position.y + sin(angulo_final) * raio
		rotation = angulo_final 
	
func start(pos, velocidade, empurro):
	speed = velocidade
	empurro_dist = empurro


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigos"):
		print("Tomou")
		var player = get_tree().get_first_node_in_group("Players")
		var direcao_empurrao = (body.global_position - player.global_position).normalized()
		body.global_position += direcao_empurrao * empurro_dist
		RunData.egides_ativas.erase(self)
		RunData.sinal_egide_morreu.emit()
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.owner.is_in_group("Inimigos"):
		print("Tomou")
		var player = get_tree().get_first_node_in_group("Players")
		var direcao_empurrao = (area.owner.global_position - player.global_position).normalized()
		area.owner.global_position += direcao_empurrao * empurro_dist
		RunData.egides_ativas.erase(self)
		RunData.sinal_egide_morreu.emit()
		queue_free()
