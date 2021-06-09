extends Control

onready var game_scene = preload("res://Scenes/Game.tscn")

var scroll_speed = 5
onready var cursor = $Cursor
onready var click_player = $Cursor/ClickPlayer

onready var click_node = $CenterContainer/ClickNode
onready var skin_button = $CenterContainer/ClickNode/SkinButton
onready var button_sprite = $CenterContainer/ClickNode/SkinButton/ButtonSprite

# Players
onready var click_button_player = $CenterContainer/ClickNode/ClickButtonPlayer

# Tweens
onready var transition_tween = $TransitionTween
onready var start_tween = $StartTween
onready var music_tween = $MusicTween

var on_button = false
var clicked = false

onready var white_rect = $WhiteRect

onready var music = $Sounds/Music

onready var button_sound = $Sounds/ButtonSound

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Sounds/Music.play()
	transition_tween.interpolate_property(white_rect, "modulate", white_rect.modulate, Color(1,1,1,0),1,Tween.TRANS_LINEAR,Tween.EASE_OUT,0.1)
	transition_tween.start()
	if Memory.played:
		$Score/VBoxContainer/HumansEaten.text = "HUMANS EATEN: " + str(Memory.eaten)
		$Score/VBoxContainer/Tricks.text = "TRICKS: " + str(Memory.tricks)
		$Score.visible = true
		
func _physics_process(delta):
	$ParallaxBackground/ParallaxLayer5.motion_offset.x -= (scroll_speed + 1) * delta
	$ParallaxBackground/ParallaxLayer4.motion_offset.x -= (scroll_speed + 2) * delta
	$ParallaxBackground/ParallaxLayer3.motion_offset.x -= (scroll_speed + 3) * delta
	$ParallaxBackground/ParallaxLayer2.motion_offset.x -= (scroll_speed + 4) * delta
	
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	
	#cursor.position = get_global_mouse_position()
	#if Input.is_action_just_pressed("click"):
	#	click_player.stop()
	#	click_player.play("Click")
	#	if on_button and !clicked:
	#		clicked = true
	#		click_button_player.play("Click")
	#		button_sprite.play("On")
	#		button_sound.play()
	
	if Input.is_action_just_pressed("enter") or Input.is_action_just_pressed("jump"):
		if !clicked:
			clicked = true
			click_button_player.play("Click")
			button_sprite.play("On")
			button_sound.play()
			Memory.play()
	
	if on_button:
		skin_button.scale = lerp(skin_button.scale, Vector2(0.8,0.8), 0.1)
	elif !on_button:
		skin_button.scale = lerp(skin_button.scale, Vector2(1,1), 0.1)

func _on_ClickArea_area_entered(_area):
	#on_button = true
	pass

func _on_ClickArea_area_exited(_area):
	#on_button = false
	pass

func _on_ClickButtonPlayer_animation_finished(_anim_name):
	button_sprite.play("Off")
	transition_tween.stop_all()
	start_tween.interpolate_property(white_rect, "modulate", white_rect.modulate, Color(1,1,1,1), 1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	music_tween.interpolate_property(music, "volume_db", music.volume_db, -80, 4,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	start_tween.start()
	music_tween.start()

func _on_StartTween_tween_all_completed():
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(game_scene)
