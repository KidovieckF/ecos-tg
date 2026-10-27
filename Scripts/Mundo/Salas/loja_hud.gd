extends Control

@export var armas : Array[ArmaRecurso] = []
@export var artefatos : Array[Artefato_data] = []
var sorteado
var sorteadoArma
var sorte1 :Artefato_data
var sorte2 :Artefato_data
var sorte3 :Artefato_data

var sorteArma : ArmaRecurso

func _ready() -> void:
	sorte1 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
	
	if sorte1 != null:
		%ArtNome1.text = sorte1.nome
		%ArtefatoBtn.texture_normal = sorte1.icone
		%ArtPreco1.text = "$" + str(sorte1.preco)
		%ArtefatoBtn.tooltip_text = sorte1.nome + "\n" + sorte1.descricao
	else:
		%ArtefatoBtn.visible = false
		%ArtNome1.visible = false
		%ArtPreco1.visible = false

	var tentativas = 0
	sorte2 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
	while sorte2 == sorte1 and RunData.artefatos_disponiveis.size() > 1 and tentativas < 10:
		sorte2 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
		tentativas += 1
		
	if sorte2 != null and sorte2 != sorte1:
		%ArtNome2.text = sorte2.nome
		%ArtefatoBtn2.texture_normal = sorte2.icone
		%ArtPreco3.text = "$: " + str(sorte2.preco)
		%ArtefatoBtn2.tooltip_text = sorte2.nome + "\n" + sorte2.descricao
	else:
		%ArtefatoBtn2.visible = false
		%ArtNome2.visible = false
		%ArtPreco3.visible = false

	var mostrar_arma = randi_range(0, 1)
	if mostrar_arma == 1:
		sortear_arma()
		sorteArma = armas[sorteadoArma]
		%PrecoArma.text = "$: " + str(sorteArma.preco)
		%DescricaoArma.text = str(sorteArma.nome)
		%ArmaBtn.texture_normal = sorteArma.textura
		%ArmaBtn.tooltip_text = sorteArma.nome
	elif mostrar_arma == 0:
		%PrecoArma.visible = false
		%ArmaBtn.visible = false
		%DescricaoArma.text = "Nenhuma arma em estoque."
		%ComprarBtn.visible = false


	
func sortear_arma():
	sorteadoArma =  randi_range(0, armas.size() - 1 )


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
		RunData.adicionar_artefato(sorte1)
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
		RunData.adicionar_artefato(sorte2)
		%ArtefatoBtn2.texture_normal = null
		RunData.moeda_run -= sorte2.preco
		if RunData.moeda_run < 0:
			RunData.moeda_run = 0
	else:
		var tween = create_tween().set_loops(3) # pisca 3 vezes
		tween.tween_property(%ArtefatoBtn2, "modulate", Color.RED, 0.1)
		tween.tween_property(%ArtefatoBtn2, "modulate", Color.WHITE, 0.1)
