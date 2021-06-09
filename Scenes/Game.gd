extends Node

# Prefabs
onready var obstacle = preload("res://Scenes/Obstacle.tscn")
onready var flag = preload("res://Scenes/Flag.tscn")
onready var bear = preload("res://Scenes/Bear.tscn")
onready var human = preload("res://Scenes/Human.tscn")

# Nodes
onready var mountain = $Bodies
onready var bodies = $Bodies/YSort
onready var flags = $Bodies/Flags
onready var snow_border = $Background/SnowBorder
onready var white_rect = $Transition/WhiteRect

# Timers
onready var obstacles_timer = $Timers/SpawnObstacleTimer
onready var flags_timer = $Timers/SpawnFlags

# Tweens 
onready var transition_tween = $Transition/TransitionTween
onready var end_tween = $Transition/EndTween
onready var music_tween = $Transition/MusicTween

# Parameters
var global_speed = 100
var slope = 10

onready var music = $Music/MusicSound

var ended = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	mountain.rotation_degrees = slope
	transition_tween.interpolate_property(white_rect, "modulate", white_rect.modulate, Color(1,1,1,0), 1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	transition_tween.start()

func _process(_delta):
	pass
	#if Input.is_action_just_pressed("esc"):
	#	if !ended:
	#		ended = true
	#		end()

func _on_SpawnObstacleTimer_timeout():
	var kind_of_obstacle = round(rand_range(0,10))
	if kind_of_obstacle < 6:
		spawn_obstacle()
	elif kind_of_obstacle >= 6 and kind_of_obstacle < 10:
		spawn_human()
	elif kind_of_obstacle >= 10:
		spawn_bear()

func spawn_obstacle():
	var new_obstacle = obstacle.instance()
	new_obstacle.position.x = 384
	new_obstacle.position.y = rand_range(32, 120)
	bodies.add_child(new_obstacle)
	new_obstacle.owner = bodies

func spawn_bear():
	var new_bear = bear.instance()
	new_bear.position.x = 384
	new_bear.position.y = rand_range(32, 100)
	bodies.add_child(new_bear)
	new_bear.owner = bodies

func spawn_human():
	var new_human = human.instance()
	new_human.position.x = 384
	new_human.position.y = rand_range(32, 120)
	bodies.add_child(new_human)
	new_human.owner = bodies

func spawn_flag():
	var new_flag = flag.instance()
	new_flag.position.x = 384
	new_flag.position.y = 4
	flags.add_child(new_flag)
	new_flag.owner = flags

func increase_speed():
	if global_speed < 300:
		global_speed *= 1.01
		obstacles_timer.wait_time *= 0.99
		flags_timer.wait_time *= 0.99

func _on_SpawnFlags_timeout():
	spawn_flag()
	increase_speed()

func end():
	Memory.new_score($Bodies/YSort/Yeti.humans_eaten, $Bodies/YSort/Yeti.tricks_count)
	transition_tween.stop_all()
	end_tween.interpolate_property(white_rect, "modulate", white_rect.modulate, Color(1,1,1,1), 1, Tween.TRANS_LINEAR,Tween.EASE_OUT)
	end_tween.start()
	music_tween.interpolate_property(music, "volume_db", music.volume_db, -80, 4,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	music_tween.start()
	$Bodies/YSort/Yeti.end_of_avalanche()
	
func _on_EndTween_tween_all_completed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://YetiScenes/TitleMenu.tscn")
