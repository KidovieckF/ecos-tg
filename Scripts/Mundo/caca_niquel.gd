extends CanvasLayer

var simbolos = ["🍒", "⭐", "💎", "🍎", "💀"]
var slot = 1
var girando = true
signal resultado_roleta(recompensa : String)
var tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	%EfeitoLabel.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_timer_timeout() -> void:
	var item = simbolos.pick_random()
	var fakeout
	if slot < 2:
		%Slot.text = item
	if slot < 3:
		item = simbolos.pick_random()
		fakeout = randi_range(1,2)
		if fakeout == 1:
			%Slot2.text = item
		else:
			%Slot2.text = %Slot.text
	if slot < 4:
		item = simbolos.pick_random()
		fakeout = randi_range(1,4)
		if %Slot2.text == %Slot.text:
			if fakeout > 1:
				%Slot3.text = %Slot2.text
			else:
				%Slot3.text = item
		else:
			%Slot3.text = item
	
	


func _on_parar_timeout() -> void:
	girando = false
	slot += 1
	if slot == 4:
		$Giro.stop()
		$Parar.stop()
		verifica_resultado()
		await get_tree().create_timer(2.0).timeout
		tween = create_tween()
		tween.tween_callback(queue_free)
	 

func verifica_resultado():
	var slot1 = %Slot.text
	var slot2 = %Slot2.text
	var slot3 = %Slot3.text
	print("O que o computador entendeu: ", slot1, slot2, slot3)
	if slot1 == slot2 and slot2 == slot3:
		%EfeitoLabel.visible = true
		match slot1: 
			"🍒":
				resultado_roleta.emit("multirao")
				# + 2 inimigos por onda
				%EfeitoLabel.text = "+2 inimigos por onda."
			"💎":
				resultado_roleta.emit("ultimato")
				# mini chefe no ultima onda
				%EfeitoLabel.text = "Inimigo mortal!"
			"⭐":
				resultado_roleta.emit("grandao")
				# aumenta em 100% o tamanho dos inimigos
				%EfeitoLabel.text = "Aumento de tamanho!"
			"🍎":
				resultado_roleta.emit("suculento")
				# aumenta em 10 a vida dos inimigos
				%EfeitoLabel.text = "Inimigos saudavéis"
			"💀":
				resultado_roleta.emit("morte")
				%EfeitoLabel.text = "Boa sorte."
				
func iniciar_roleta():
	visible = true
	$Giro.start()
	$Parar.start()
