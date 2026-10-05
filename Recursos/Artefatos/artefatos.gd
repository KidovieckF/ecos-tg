extends Resource
class_name Artefato_data

@export var nome : String
@export var descricao : String
@export var icone : Texture2D
@export var preco : int
@export var arma_requerida : String = ""

#Variaveis especificas: Artefato 
@export var tiro_pela_culatra : bool = false
@export var cristal_corrompido : bool = false
@export var prensa_hidraulica : bool = false
@export var cura_parado : float = 0.0
@export var speed_ao_critar : float = 0.0
@export var cura_queimadura_pct : float = 0.0
@export var tem_chapeu: int = 0
@export var tem_egide: int = 0

@export var chance_critico_add : float = 0
@export var dano_add : float = 0
@export var dano_mult : float = 0
@export var vida_max_add : float = 0
@export var vida_max_mult : float = 0
@export var speed_add : float = 0
@export var speed_mult : float = 0
@export var reducao_dano: float = 0
@export var atk_speed_mult : float = 0
@export var tamanho_magia_mult : float = 0
@export var limite : int
@export var raridade : String


func efeito() -> void:
	pass
