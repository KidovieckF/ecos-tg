extends Node


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
