extends Area2D

var dano_bala
var pos_final
@onready var limite : RayCast2D = $RayCast2D
@onready var mira : Line2D = $Line2D
var e_critico :bool
var inimigos_dentro = []

func _ready() -> void:
	$TicTimer.start()

func _physics_process(delta: float) -> void:
	limite.force_raycast_update()
	if limite.is_colliding():
		pos_final = limite.get_collision_point()
		pos_final = to_local(pos_final)
	else:
		pos_final = limite.target_position
	mira.set_point_position(1, pos_final)


func start(dano, pos, critico):
	dano_bala = dano
	e_critico = critico
	limite.target_position = Vector2(1000,0)
	limite.force_raycast_update()
	if limite.is_colliding():
		pos_final = to_local(limite.get_collision_point())
	else:
		pos_final = limite.target_position
	mira.set_point_position(1, pos_final)
	mira.set_point_position(0, Vector2.ZERO)
	
	var direcao_mouse = get_global_mouse_position() - global_position
	
	if abs(direcao_mouse.y) > abs(direcao_mouse.x) and direcao_mouse.y < 0:
		z_index = 4 
	else:
		z_index = 6

func sumir_encolhendo(tempo: float):
	set_physics_process(false)
	
	var tween = create_tween()
	
	tween.tween_interval(0.2) 
	

	tween.tween_method(atualizar_origem, Vector2.ZERO, pos_final, tempo).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(queue_free)

func atualizar_origem(nova_origem: Vector2):
	mira.set_point_position(0, nova_origem)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		inimigos_dentro.append(area)


func _on_area_exited(area: Area2D) -> void:
	if inimigos_dentro.has(area):
		inimigos_dentro.erase(area)



func _on_tic_timer_timeout() -> void:
	for area in inimigos_dentro:
		if is_instance_valid(area) and area.has_method("take_damage"):
			
			var rolou_critico = randi_range(1, 100) <= RunData.chance_critico
			var dano_tick = dano_bala
			var cor = Color.WHITE
			
			if rolou_critico:
				dano_tick *= RunData.dano_critico
				cor = Color.YELLOW
				
			area.take_damage(dano_tick, cor, rolou_critico)
			
			if RunData.armas[0] != null:
				for upgrade in RunData.armas[0].upgrades_ativos:
					if upgrade.has_method("ao_causar_dano"):
						upgrade.ao_causar_dano(area, dano_tick, self)
