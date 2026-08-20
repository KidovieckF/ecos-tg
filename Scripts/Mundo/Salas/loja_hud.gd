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
	%ArtefatoBtn.texture_normal = sorte1.icone
	sortear_artefato()
	sorte2 = artefatos[sorteado]
	%ArtefatoBtn2.texture_normal = sorte2.icone
	if randi_range(0,1) == 1:
		sortear_arma()
		sorteArma = armas[sorteadoArma]
		%ArmaBtn.texture_normal = sorteArma.textura
	

func sortear_artefato():
	sorteado =  randi_range(0, artefatos.size() - 1 )
	
func sortear_arma():
	sorteadoArma =  randi_range(0, armas.size() - 1 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_arma_btn_pressed() -> void:
	RunData.armas[0] = sorteArma
	%ArmaBtn.texture_normal = null


func _on_artefato_btn_pressed() -> void:
	RunData.artefatos_coletados.append(sorte1)
	%ArtefatoBtn.texture_normal = null


func _on_artefato_btn_2_pressed() -> void:
	RunData.artefatos_coletados.append(sorte2)
	%ArtefatoBtn2.texture_normal = null
