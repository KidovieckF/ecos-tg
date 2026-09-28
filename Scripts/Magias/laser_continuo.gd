extends Area2D

var dano_bala
var pos_final
@onready var limite : RayCast2D = $RayCast2D
@onready var mira : Line2D = $Line2D
@onready var laser : Panel = $Panel
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
	laser.size.x = pos_final.x

func start(dano, pos, critico):
	dano_bala = dano
	e_critico = critico
	limite.target_position = Vector2(1000,0)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		inimigos_dentro.append(area)


func _on_area_exited(area: Area2D) -> void:
	if inimigos_dentro.has(area):
		inimigos_dentro.erase(area)



func _on_tic_timer_timeout() -> void:
	print("teste")
	for area in inimigos_dentro:
		if is_instance_valid(area) and area.has_method("take_damage"):
			var cor = Color.WHITE
			if e_critico: cor = Color.YELLOW
			area.take_damage(dano_bala, cor, e_critico)
			
			if RunData.armas[0] != null:
				for upgrade in RunData.armas[0].upgrades_ativos:
					if upgrade.has_method("ao_causar_dano"):
						upgrade.ao_causar_dano(area, dano_bala, self)
