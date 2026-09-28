extends Area2D


var dano_bala
var speed
var inimigos_lista = []
var direction 
var dano_add
var indice_atual = 0
var caminho : Array
var limite_queimadura
var tempo_vida_fogo
var crescimento_fogo
var tem_crescimento


@export var cena_da_queimadura : PackedScene
@export var debuff : DebuffsData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var raio = 20
	var posicao_mouse = get_global_mouse_position()
	$Timer.start()
	$TempoVida.wait_time += tempo_vida_fogo
	$TempoVida.start()
	global_position = posicao_mouse + Vector2(randf_range(-raio, raio), randf_range(-raio, raio))

func _process(delta: float) -> void:
	scale += Vector2(crescimento_fogo, crescimento_fogo) * delta * 0.1
	

func start(dano, crescimento, limite, tempo_vida):
	dano_bala = dano
	limite_queimadura = limite
	tempo_vida_fogo = tempo_vida
	if crescimento > 1:
		crescimento_fogo = crescimento
	else:
		crescimento_fogo = 0



func _on_area_exited(area: Node2D) -> void:
	inimigos_lista.erase(area)


	


func _on_tempo_vida_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		$Timer.start()
		inimigos_lista.append(area)


func _on_timer_timeout() -> void:
	for inimigos in inimigos_lista:
		var queimando = inimigos.get_node_or_null("Queimadura")
		if queimando and not queimando.is_queued_for_deletion():
			queimando.adicionar_stacks(limite_queimadura, dano_bala)
		else:
			var nova_queima = cena_da_queimadura.instantiate()
			nova_queima.name = ("Queimadura")
			nova_queima.debuff = debuff
			inimigos.add_child(nova_queima)
			nova_queima.adicionar_stacks(limite_queimadura, dano_bala)
