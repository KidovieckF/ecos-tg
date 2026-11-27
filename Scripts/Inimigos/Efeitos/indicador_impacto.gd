class_name IndicadorImpacto
extends Node2D

var raio: float = 80.0
var duracao: float = 0.75
var progresso: float = 0.0

static func criar(pai: Node, posicao: Vector2, p_raio: float, p_duracao: float) -> IndicadorImpacto:
	var ind = IndicadorImpacto.new()
	ind.raio = p_raio
	ind.duracao = p_duracao
	ind.global_position = posicao
	pai.add_child(ind)
	return ind

func _ready() -> void:
	z_index = 0
	var tween = create_tween()
	tween.tween_property(self, "progresso", 1.0, duracao)
	tween.tween_callback(queue_free)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, raio, Color(1.0, 0.15, 0.15, 0.2))
	draw_arc(Vector2.ZERO, raio, 0, TAU, 48, Color(1.0, 0.2, 0.2, 0.8), 2.5)
	if progresso > 0.0:
		draw_circle(Vector2.ZERO, raio * progresso, Color(1.0, 0.25, 0.25, 0.35))
