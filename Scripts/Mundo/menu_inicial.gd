extends Control

const TEXTURAS_NUVENS = [
	preload("res://sprites/Menu_Principal/Nuvem1.png"),
	preload("res://sprites/Menu_Principal/Nuvem2.png"),
	preload("res://sprites/Menu_Principal/Nuvem3.png"),
	preload("res://sprites/Menu_Principal/Nuvem4.png")
]


@onready var nuvens_container = $GridContainer/Tela/NuvensContainer
@onready var fade_overlay = $Transicao/Fade

#Titulo
var tempo_flutuacao: float = 0.0
var pos_y_inicial_titulo: float = 0.0
const AMPLITUDE_FLUTUACAO: float = 6.0 
const VELOCIDADE_FLUTUACAO: float = 2.0 

var tempo_para_proxima_nuvem: float = 0.0
var transicionando: bool = false



func _ready() -> void:
	_pre_popular_nuvens()
	tempo_para_proxima_nuvem = randf_range(2.0, 4.0)
	$AnimatedSprite2D.play("default")
	
	if SaveManager.tem_run_salva():
		if %IniciarBtn: %IniciarBtn.text = "Continuar"
		if %NovaRunBtn: %NovaRunBtn.visible = true
	else:
		if %IniciarBtn: %IniciarBtn.text = "Começar"
		if %NovaRunBtn: %NovaRunBtn.visible = false
		
	if %TutorialCheckBox:
		%TutorialCheckBox.button_pressed = SaveManager.eh_primeira_vez_tutorial()


func _process(delta: float) -> void:
	_atualizar_nuvens(delta)
	if %Titulo:
		tempo_flutuacao += delta * VELOCIDADE_FLUTUACAO
		%Titulo.position.y = pos_y_inicial_titulo + sin(tempo_flutuacao) * AMPLITUDE_FLUTUACAO


func _pre_popular_nuvens() -> void:
	if nuvens_container == null: return
	var largura_tela = get_viewport_rect().size.x
	for i in range(5):
		var x_sorteado = randf_range(50.0, largura_tela - 50.0)
		_criar_nuvem(x_sorteado)

func _criar_nuvem(posicao_x: float) -> void:
	if nuvens_container == null: return
	
	var nuvem = Sprite2D.new()
	
	nuvem.texture = TEXTURAS_NUVENS.pick_random()
	
	var altitude_y = randf_range(25.0, 110.0)
	nuvem.position = Vector2(posicao_x, altitude_y)
	
	var escala = randf_range(0.75, 1.3)
	nuvem.scale = Vector2(escala, escala)
	
	nuvem.z_index = randi_range(0, 3)
	
	nuvem.modulate = Color(1.0, 1.0, 1.0, randf_range(0.8, 1.0))
	
	var vel_base = randf_range(25.0, 50.0)
	var velocidade_final = vel_base * escala
	nuvem.set_meta("velocidade", velocidade_final)
	
	nuvens_container.add_child(nuvem)

func _atualizar_nuvens(delta: float) -> void:
	if nuvens_container == null: return
	var largura_tela = get_viewport_rect().size.x
	
	for nuvem in nuvens_container.get_children():
		var vel = nuvem.get_meta("velocidade", 35.0)
		nuvem.position.x += vel * delta
		
		if nuvem.position.x > largura_tela + 350.0:
			nuvem.queue_free()
			
	tempo_para_proxima_nuvem -= delta
	if tempo_para_proxima_nuvem <= 0.0:
		_criar_nuvem(-300.0)
		tempo_para_proxima_nuvem = randf_range(2.5, 5.0)

func _on_iniciar_btn_pressed() -> void:
	if transicionando:
		return
	transicionando = true
	
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	_desativar_botoes()
	
	var destino = "res://Cenas/Mundo/LobbyPrincipal.tscn"
	var eh_carregamento = false
	
	if SaveManager.tem_run_salva():
		var dados = SaveManager.carregar_run_salva()
		destino = dados.get("cena_atual", "res://Cenas/Mundo/Mundo.tscn")
		eh_carregamento = true
	else:
		RunData.resetar_run()
		SaveManager.registrar_inicio_run()
		
	if %TutorialCheckBox and %TutorialCheckBox.button_pressed:
			destino = "res://Cenas/Cutscenes/cs_01_chegada_floresta.tscn"
		
	
	_executar_transicao_para_cena(destino)

func _on_nova_run_btn_pressed() -> void:
	if transicionando:
		return
	transicionando = true
	
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	_desativar_botoes()
	
	SaveManager.deletar_run_salva()
	RunData.resetar_run()
	SaveManager.registrar_inicio_run()
	
	var destino = "res://Cenas/Mundo/LobbyPrincipal.tscn"
	
	if %TutorialCheckBox and %TutorialCheckBox.button_pressed:
		destino = "res://Cenas/Cutscenes/cs_01_chegada_floresta.tscn"
	
	_executar_transicao_para_cena(destino)
	
func _desativar_botoes() -> void:
	if %IniciarBtn: %IniciarBtn.disabled = true
	if %NovaRunBtn: %NovaRunBtn.disabled = true
	if %ConfigsBtn: %ConfigsBtn.disabled = true
	if %HistoricoBtn: %HistoricoBtn.disabled = true
	if %SairBtn: %SairBtn.disabled = true
	if %TutorialCheckBox: %TutorialCheckBox.disabled = true
	
func _executar_transicao_para_cena(cena_alvo: String) -> void:
	if fade_overlay:
		fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	var duracao = 1.4
	var alvo_y = -get_viewport_rect().size.y
	
	tween.tween_property(self, "position:y", alvo_y, duracao)
	
	if fade_overlay:
		tween.tween_property(fade_overlay, "color:a", 1.0, duracao)
		
	tween.chain().tween_callback(func():
		get_tree().change_scene_to_file(cena_alvo)
	)
	
func _on_configs_btn_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().change_scene_to_file("res://Cenas/Mundo/configs.tscn")


func _on_sair_btn_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().quit()


func _on_historico_btn_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().change_scene_to_file("res://Cenas/Huds/Hud_historico.tscn")
