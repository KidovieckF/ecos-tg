@tool
extends Control

@onready var roleta = %Roleta_dentro
@onready var label = $Control/Label
@onready var ponteiro = $Control/Control/Polygon2D

var girando: bool = false

var fatias = [
	{"nome": "Mercado", "cor": Color(0.72, 0.18, 0.22)}, # Vermelho Sangue
	{"nome": "Caos", "cor": Color(0.48, 0.20, 0.68)},    # Roxo Yogg
	{"nome": "Pacto", "cor": Color(0.16, 0.35, 0.58)},   # Azul Profundo
	{"nome": "Fortuna", "cor": Color(0.85, 0.65, 0.15)}, # Dourado
	{"nome": "Velocidade", "cor": Color(0.12, 0.65, 0.55)}, # Ciano/Vento
	{"nome": "Tormenta", "cor": Color(0.85, 0.35, 0.15)}  # Laranja Caos
]

func _draw() -> void:
	var centro = size / 2.0
	var raio = min(size.x, size.y) / 2.0 - 8.0
	var total = fatias.size()
	var angulo_fatia = TAU / total

	for i in range(total):
		var ang_ini = i * angulo_fatia
		var ang_fim = (i + 1) * angulo_fatia
		
		var pontos = PackedVector2Array([centro])
		for step in range(25):
			var a = lerp(ang_ini, ang_fim, float(step) / 24.0)
			pontos.append(centro + Vector2(cos(a), sin(a)) * raio)
		draw_colored_polygon(pontos, fatias[i]["cor"])
		
		draw_line(centro, centro + Vector2(cos(ang_ini), sin(ang_ini)) * raio, Color(0.08, 0.08, 0.08, 0.8), 2.5)
		
		draw_circle(centro + Vector2(cos(ang_ini), sin(ang_ini)) * (raio - 2.0), 4.0, Color.GOLD)

	draw_arc(centro, raio, 0, TAU, 64, Color(0.9, 0.75, 0.2), 6.0)
	draw_arc(centro, raio + 3.0, 0, TAU, 64, Color(0.15, 0.1, 0.05), 2.0)


func _on_girar_button_pressed() -> void:
	if girando:
		return
	girando = true
	%Girar_Button.disabled = true
	%Titulo.text = "O Destino está girando..."
	var total_fatias = roleta.fatias.size()
	var indice_sorteado = randi() % total_fatias
	var angulo_fatia = TAU / total_fatias
	var centro_fatia = (indice_sorteado + 0.5) * angulo_fatia
	var angulo_topo = 1.5 * PI
	
	var leve_variacao = randf_range(-angulo_fatia * 0.3, angulo_fatia * 0.3)
	
	# 6 voltas completas de suspense + ângulo da fatia
	var voltas = 12.0 * TAU
	var angulo_final = voltas + (angulo_topo - centro_fatia) + leve_variacao
	roleta.rotation = fmod(roleta.rotation, TAU)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(roleta, "rotation", roleta.rotation + angulo_final, 4.5)
	tween.tween_callback(func():
		girando = false
		var resultado = roleta.fatias[indice_sorteado]
		%Titulo.text = "Destino Selecionado: " + resultado["nome"] + "!"
		

		var t_ponteiro = create_tween()
		t_ponteiro.tween_property(ponteiro, "scale", Vector2(1.3, 1.3), 0.1)
		t_ponteiro.tween_property(ponteiro, "scale", Vector2(1.0, 1.0), 0.15)
	)
