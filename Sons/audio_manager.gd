extends Node

const ARQUIVO_AUDIO_CONFIG = "user://audio_config.cfg"
var volume_master: float = 1.0
var volume_musica: float = 0.8
var volume_sfx: float = 1.0

const SFX_CHARGE = preload("res://Sons/Charging Power Up Sound Effect (Electrical Energy Power Audio) FREE 4K DOWNLOAD - NO COPYRIGHT.mp3")
const BGM_LOBBY = preload("res://Sons/Campfire.mp3")
const BGM_FASE = preload("res://Sons/Beyond the Forest.mp3")
const SFX_LASER = preload("res://Sons/Laser Gun Sound Effect.mp3")
const SFX_FOGO = preload("res://Sons/yodguard-fire-magic-6-378641.mp3")
const SFX_MAGIA_SWOOSH = preload("res://Sons/Fire.mp3")
const SFX_EXPLOSAO = preload("res://Sons/explosion_big.wav")
const SFX_MEGA_EXPLOSAO = preload("res://Sons/mega_explosion.wav")
const SFX_IMPACTO_CHAO = preload("res://Sons/Ground Crash Sound Effects.mp3")
const SFX_PORTAL = preload("res://Sons/portal.wav")
const SFX_BOTAO = preload("res://Sons/menu_select.wav")
const SFX_RUGIDO = preload("res://Sons/roar-8-bit.mp3")
const SFX_IHAAA = preload("res://Sons/comedy-male-yelling-yee-ha-sound-effects-free-download-mp3cut_j2j7iwO.mp3")
const SFX_PASSO_GRAMA = preload("res://Sons/footstep_grass.wav")
const SFX_GRAVITY = preload("res://Sons/gravity pulling sound effect.mp3")


var player_musica: AudioStreamPlayer
var tween_musica: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player_musica = AudioStreamPlayer.new()
	player_musica.bus = "Musica"
	player_musica.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player_musica)
	carregar_configuracoes_audio()


func tocar_sfx(stream: AudioStream, volume_db: float = 0.0, variar_pitch: bool = true) -> AudioStreamPlayer:
	if stream == null:
		return null
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	sfx_player.volume_db = volume_db
	
	if variar_pitch:
		sfx_player.pitch_scale = randf_range(0.92, 1.08)
		
	add_child(sfx_player)
	sfx_player.play()
	
	sfx_player.finished.connect(sfx_player.queue_free)
	return sfx_player

func tocar_sfx_com_duracao(stream: AudioStream, duracao: float, volume_db: float = 0.0, pitch: float = 1.0, inicio_segundo: float = 0.0) -> AudioStreamPlayer:
	if stream == null:
		return null
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	sfx_player.volume_db = volume_db
	sfx_player.pitch_scale = pitch
	add_child(sfx_player)
	
	sfx_player.play(inicio_segundo)
	
	var tween = create_tween()
	var tempo_fade = min(0.12, duracao * 0.3)
	var tempo_sustentacao = max(0.05, duracao - tempo_fade)
	
	tween.tween_interval(tempo_sustentacao)
	tween.tween_property(sfx_player, "volume_db", -40.0, tempo_fade)
	tween.tween_callback(sfx_player.queue_free)
	
	return sfx_player

func tocar_sfx_charge(stream: AudioStream, loop_start: float = 3.6, volume_db: float = 0.0) -> AudioStreamPlayer:
	if stream == null:
		return null
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.bus = "SFX"
	sfx_player.volume_db = volume_db
	add_child(sfx_player)
	sfx_player.play(0.0) # Começa do zero
	
	sfx_player.finished.connect(func():
		if is_instance_valid(sfx_player):
			sfx_player.play(loop_start)
	)
	
	return sfx_player


func tocar_musica(nova_musica: AudioStream, fade_tempo: float = 1.0, volume_alvo: float = -4.0) -> void:
	if nova_musica == null:
		return
	if player_musica.stream == nova_musica and player_musica.playing:
		return
		
	if "loop" in nova_musica:
		nova_musica.loop = true
		
	if tween_musica and tween_musica.is_running():
		tween_musica.kill()
		
	tween_musica = create_tween()
	
	if player_musica.playing:
		tween_musica.tween_property(player_musica, "volume_db", -40.0, fade_tempo)
		tween_musica.tween_callback(func():
			player_musica.stream = nova_musica
			player_musica.play()
		)
		tween_musica.tween_property(player_musica, "volume_db", volume_alvo, fade_tempo)
	else:
		player_musica.stream = nova_musica
		player_musica.volume_db = -40.0
		player_musica.play()
		tween_musica.tween_property(player_musica, "volume_db", volume_alvo, fade_tempo)

func parar_musica(fade_tempo: float = 1.0) -> void:
	if not player_musica.playing:
		return
	if tween_musica and tween_musica.is_running():
		tween_musica.kill()
	tween_musica = create_tween()
	tween_musica.tween_property(player_musica, "volume_db", -40.0, fade_tempo)
	tween_musica.tween_callback(player_musica.stop)
	
func carregar_configuracoes_audio() -> void:
	var config = ConfigFile.new()
	var err = config.load(ARQUIVO_AUDIO_CONFIG)
	if err == OK:
		volume_master = config.get_value("audio", "master", 1.0)
		volume_musica = config.get_value("audio", "musica", 0.8)
		volume_sfx = config.get_value("audio", "sfx", 1.0)
	
	definir_volume_master(volume_master, false)
	definir_volume_musica(volume_musica, false)
	definir_volume_sfx(volume_sfx, false)
	
func salvar_configuracoes_audio() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master", volume_master)
	config.set_value("audio", "musica", volume_musica)
	config.set_value("audio", "sfx", volume_sfx)
	config.save(ARQUIVO_AUDIO_CONFIG)
	
func definir_volume_master(valor: float, salvar: bool = true) -> void:
	volume_master = clamp(valor, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("Master")
	if idx != -1:
		if volume_master <= 0.01:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			AudioServer.set_bus_volume_db(idx, linear_to_db(volume_master))
	if salvar:
		salvar_configuracoes_audio()
		
func definir_volume_musica(valor: float, salvar: bool = true) -> void:
	volume_musica = clamp(valor, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("Musica")
	if idx != -1:
		if volume_musica <= 0.01:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			AudioServer.set_bus_volume_db(idx, linear_to_db(volume_musica))
	if salvar:
		salvar_configuracoes_audio()
		
func definir_volume_sfx(valor: float, salvar: bool = true) -> void:
	volume_sfx = clamp(valor, 0.0, 1.0)
	var idx = AudioServer.get_bus_index("SFX")
	if idx != -1:
		if volume_sfx <= 0.01:
			AudioServer.set_bus_mute(idx, true)
		else:
			AudioServer.set_bus_mute(idx, false)
			AudioServer.set_bus_volume_db(idx, linear_to_db(volume_sfx))
	if salvar:
		salvar_configuracoes_audio()
