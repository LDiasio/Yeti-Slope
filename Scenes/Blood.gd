extends CPUParticles2D

onready var yeti = get_parent().get_parent()

func _ready():
	emitting = true

func _process(_delta):
	if is_instance_valid(yeti):
		global_position = yeti.food_container.global_position

func _on_EndTimer_timeout():
	queue_free()
