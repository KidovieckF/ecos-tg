extends Area2D


var dano_bala
var speed
var inimigos_lista = []
var direction 
@export var cena_da_queimadura : PackedScene
@export var debuff : DebuffsData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = get_global_mouse_position()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Timer.is_stopped():
		for inimigos in inimigos_lista:
			inimigos.take_damage(dano_bala)
			$Timer.start()
			var queimando = inimigos.get_node_or_null("Queimadura")
			if queimando and not queimando.is_queued_for_deletion():
				queimando.adicionar_stacks()
			else:
				var nova_queima = cena_da_queimadura.instantiate()
				nova_queima.name = ("Queimadura")
				nova_queima.debuff = debuff
				inimigos.add_child(nova_queima)

func start(dano):
	dano_bala = dano


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		$Timer.start()
		inimigos_lista.append(body)



func _on_body_exited(body: Node2D) -> void:
	inimigos_lista.erase(body)
