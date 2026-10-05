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
	
	var pool_loja = RunData.artefatos_disponiveis.filter(func(a): 
		return a.arma_requerida == "" or (RunData.armas[0] != null and a.arma_requerida == RunData.armas[0].nome)
	)
	
	
	if pool_loja.size() > 0:
		var index_sorteado = sortear_artefato(pool_loja)
		sorte1 = pool_loja[index_sorteado]
		%ArtNome1.text = sorte1.nome
		%ArtefatoBtn.texture_normal = sorte1.icone
		%ArtPreco1.text = "$" + str(sorte1.preco)
		pool_loja.remove_at(index_sorteado)
	else:
		%ArtefatoBtn.visible = false
		
	if pool_loja.size() > 0:
		var index_sorteado = sortear_artefato(pool_loja)
		sorte2 = pool_loja[index_sorteado]
		%ArtNome2.text = sorte2.nome
		%ArtefatoBtn2.texture_normal = sorte2.icone
		%ArtPreco3.text = "$: " + str(sorte2.preco)
	else:
		%ArtefatoBtn2.visible = false
	
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
		
func sortear_artefato(pool_atual: Array) -> int:
	if pool_atual.size() == 0:
		return -1
		
	var chance = randi() % 100  # Rola o dado de 0 a 99
	var raridade_sorteada = ""
	
	if chance < 50: # 50% de chance
		raridade_sorteada = "Comum"
	elif chance < 80: # 30% de chance
		raridade_sorteada = "Incomum"
	elif chance < 90: # 10% de chance
		raridade_sorteada = "Raro" 
		
	var pool_filtrada = pool_atual.filter(func(a): return a.raridade == raridade_sorteada)
	
	if pool_filtrada.size() == 0:
		pool_filtrada = pool_atual
		
	var item_escolhido = pool_filtrada[randi_range(0, pool_filtrada.size() - 1)]
	
	return pool_atual.find(item_escolhido)

	
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
