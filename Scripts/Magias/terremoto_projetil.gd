extends Area2D

var dano_bala
var speed
var inimigos_lista = []
var direction 
var dano_add
var indice_atual = 0
var caminho : Array
var ticks = 0

func _ready() -> void:
	var raio = 20
	var posicao_mouse = get_global_mouse_position()
	global_position = posicao_mouse + Vector2(randf_range(-raio, raio), randf_range(-raio, raio))
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(dano):
	dano_bala = dano
	
	

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		print("entrou")
		inimigos_lista.append(area)


func _on_area_exited(area: Area2D) -> void:
	inimigos_lista.erase(area)


func _on_timer_timeout() -> void:
	ticks +=1
	$Panel.scale *= ticks
	$CollisionShape2D.scale *= ticks
	if ticks >= 4:
		queue_free()
	for inimigos in inimigos_lista:
		dano_bala *= ticks
		inimigos.take_damage(dano_bala)
		
		
