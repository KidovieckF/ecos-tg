extends Control

var esperando_tecla = false
var screen_control : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_unhandled_input(false)
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		%viewBtn.button_pressed = false
	else:
		%viewBtn.button_pressed = true

	%keyBindBtn.text = "Configuração de teclas"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_view_btn_toggled(toggled_on: bool) -> void:
	var window = get_window()
	screen_control = toggled_on
	
	if screen_control:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		


func _on_key_bind_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/keyBind.tscn")


func _on_voltar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/Menu_inicial.tscn")
