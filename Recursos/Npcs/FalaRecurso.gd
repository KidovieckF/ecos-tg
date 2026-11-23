extends Resource
class_name FalaRecurso

@export var nome_falante : String = ""
@export var foto : Texture2D
@export_multiline var falas : String
@export var respostas : Array[String]
@export var proximo_1 : Array[FalaRecurso]
@export var proximo_2 : Array[FalaRecurso]
@export var proximo_3 : Array[FalaRecurso]
@export var proximo_4 : Array[FalaRecurso]
@export var proximo_5 : Array[FalaRecurso]

@export_file("*.tres") var voltar_para : String = ""
@export var gatilho_acao : String = ""
@export var cena_para_abrir : PackedScene
