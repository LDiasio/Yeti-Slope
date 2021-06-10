extends Node2D

onready var time_between_shakes = 2

func _ready():
	$AnimationPlayer.play("Cutscene")
	$Timer.start(8.95)

func _physics_process(delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.x -= (2) * delta

func _on_Timer_timeout():
	$Camera.small_shake()
	if $Music.playing == false:
		$Music.play()
	_more_shakes()

func _more_shakes():
	$Timer.start(time_between_shakes)
	time_between_shakes = time_between_shakes -0.1

func _on_AnimationPlayer_animation_finished(Cutscene):
	get_tree().change_scene("res://YetiScenes/TitleMenu.tscn")
