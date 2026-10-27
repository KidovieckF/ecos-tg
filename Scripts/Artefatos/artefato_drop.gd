extends Area2D

@export var artefato: Artefato_data

var cena_hud_artefato = preload("res://Cenas/Huds/Hud_artefato.tscn")
var hud_instanciado = null
var pode_interagir = true


const CORES_RARIDADE = {
	"Comum": Color(0.8, 0.8, 0.8),      
	"Incomum": Color(0.2, 0.85, 0.3),     
	"Raro": Color(0.2, 0.6, 1.0),         
	"Epico": Color(0.65, 0.25, 0.9),      
	"Lendario": Color(1.0, 0.8, 0.1),    
	"Unico": Color(0.95, 0.2, 0.2)       
}

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if artefato:
		configurar(artefato)
	$AnimationPlayer.play("Float")

func configurar(p_artefato: Artefato_data) -> void:
	artefato = p_artefato
	if artefato.icone:
		$Icone.texture = artefato.icone
		var tamanho_tex = artefato.icone.get_size()
		var maior_lado = max(tamanho_tex.x, tamanho_tex.y)
		var escala_final = 48.0 / maior_lado
		$Icone.scale = Vector2(escala_final, escala_final)
		
	var cor = CORES_RARIDADE.get(artefato.raridade, Color.WHITE)
	$Sombra.modulate = cor

func _on_body_entered(body: Node2D) -> void:
	if not pode_interagir or not body.is_in_group("Players"):
		return
		
	if artefato == null:
		return

	hud_instanciado = cena_hud_artefato.instantiate()
	get_tree().root.add_child(hud_instanciado)
	hud_instanciado.exibir_artefato(artefato)
	

	hud_instanciado.tree_exited.connect(_ao_fechar_hud)

func _ao_fechar_hud() -> void:

	if RunData.artefatos_coletados.has(artefato):
		queue_free()
	else:

		pode_interagir = false
		await get_tree().create_timer(1.5).timeout
		pode_interagir = true
