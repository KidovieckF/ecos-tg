extends AnimatedSprite2D

func _ready():
	print("Testekabum")
	play("default")
	animation_finished.connect(queue_free)
