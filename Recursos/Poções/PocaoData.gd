extends Resource
class_name PocaoData

@export var nome : String = "Elixir Misterioso"
@export_multiline var descricao : String = "Aumenta seus atributos temporariamente."
@export var icone : Texture2D
@export var preco : int = 15

@export_enum("dano", "speed", "vida_max", "atk_speed", "cura_instantanea") var tipo_buff : String = "dano"

@export var valor_buff : float = 0.25

@export var salas_duracao : int = 3

@export var cor_aura : Color = Color(1.0, 0.4, 0.4)
