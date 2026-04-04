extends StaticBody2D

func abrir_porta():
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	pass

func fechar_porta():
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
