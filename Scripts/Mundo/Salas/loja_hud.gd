extends Control

@export var armas : Array[ArmaRecurso] = []
@export var artefatos : Array[Artefato_data] = []
var sorteado
var sorteadoArma
var sorte1 :Artefato_data
var sorte2 :Artefato_data
var sorte3 :Artefato_data

var sorteArma : ArmaRecurso
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sortear_artefato()
	sorte1 = artefatos[sorteado]
	%ArtNome1.text = sorte1.nome
	%ArtefatoBtn.texture_normal = sorte1.icone
	%ArtPreco1.text = "$" + str(sorte1.preco)
	sortear_artefato()
	sorte2 = artefatos[sorteado]
	%ArtNome2.text = sorte2.nome
	%ArtefatoBtn2.texture_normal = sorte2.icone
	%ArtPreco3.text = "$: " + str(sorte2.preco)
	
	var mostrar_arma = randi_range(0,1)
	
	if mostrar_arma == 1:
		sortear_arma()
		sorteArma = armas[sorteadoArma]
		%PrecoArma.text = "$: " + str(sorteArma.preco)
		%DescricaoArma.text = str(sorteArma.nome)
		%ArmaBtn.texture_normal = sorteArma.textura
	elif mostrar_arma == 0:
		%PrecoArma.visible = false
		%ArmaBtn.visible = false
		%DescricaoArma.text = "Nenhuma arma em estoque."
		%ComprarBtn.visible = false
		
func sortear_artefato():
	sorteado =  randi_range(0, artefatos.size() - 1 )
	
func sortear_arma():
	sorteadoArma =  randi_range(0, armas.size() - 1 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_arma_btn_pressed() -> void:
	if RunData.moeda_run >= sorteArma.preco:
		RunData.armas[0] = sorteArma
		%ArmaBtn.texture_normal = null
		RunData.moeda_run -= sorteArma.preco
		if RunData.moeda_run < 0:
			RunData.moeda_run = 0
	else:
		var tween = create_tween().set_loops(3) # pisca 3 vezes
		tween.tween_property(%ArmaBtn, "modulate", Color.RED, 0.1)
		tween.tween_property(%ArmaBtn, "modulate", Color.WHITE, 0.1)



func _on_artefato_btn_pressed() -> void:
	if RunData.moeda_run >= sorte1.preco:
		RunData.artefatos_coletados.append(sorte1)
		%ArtefatoBtn.texture_normal = null
		RunData.moeda_run -= sorte1.preco
		if RunData.moeda_run < 0:
			RunData.moeda_run = 0
	else: 
		var tween = create_tween().set_loops(3) # pisca 3 vezes
		tween.tween_property(%ArtefatoBtn, "modulate", Color.RED, 0.1)
		tween.tween_property(%ArtefatoBtn, "modulate", Color.WHITE, 0.1)



func _on_artefato_btn_2_pressed() -> void:
	if RunData.moeda_run >= sorte2.preco:
		RunData.artefatos_coletados.append(sorte2)
		%ArtefatoBtn2.texture_normal = null
		RunData.moeda_run -= sorte2.preco
		if RunData.moeda_run < 0:
			RunData.moeda_run = 0
	else:
		var tween = create_tween().set_loops(3) # pisca 3 vezes
		tween.tween_property(%ArtefatoBtn2, "modulate", Color.RED, 0.1)
		tween.tween_property(%ArtefatoBtn2, "modulate", Color.WHITE, 0.1)
