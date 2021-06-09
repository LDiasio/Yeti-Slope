extends KinematicBody2D

# Prefabs
onready var trail = preload("res://Scenes/Trail.tscn")
onready var snow_trail = preload("res://Scenes/YetiTrail.tscn")
onready var human = preload("res://Scenes/HumanFood.tscn")
onready var blood = preload("res://Scenes/Blood.tscn")

# Outside nodes
onready var game = get_parent().get_parent().get_parent()
onready var trails = get_parent().get_parent().get_node("Trails")
onready var snow_trails = get_parent().get_parent().get_node("SnowTrails")
onready var camera = get_parent().get_parent().get_parent().get_node("Camera")

# Colors
var damage_color = Color(3,0,0,1)
var trick_color = Color(3,3,3,1)

# Nodes
onready var jump_skin = $JumpSkin
onready var angle_skin = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin
onready var damage_skin = $JumpSkin/IdleSkin/EatSkin/DamageSkin
onready var trick_skin = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix/Tricks
onready var trick_fix = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix
onready var sprite = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix/Tricks/DeadNode/YetiSprite
onready var between_sprite = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix/Tricks/DeadNode/BetweenYetiSprite
onready var food_container = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix/Tricks/DeadNode/FoodContainer
onready var end_avalanche = $EndAvalancheTween
onready var blood_node = $BloodNode

# Sounds
onready var snow_sound = $Sounds/Snow/Snow
onready var angle_sound = $Sounds/Tricks/AngleSound
onready var back_sound = $Sounds/Tricks/BackSound
onready var rotate_sound = $Sounds/Tricks/RotateSound
onready var turn_sound = $Sounds/Tricks/TurnSound
onready var upside_sound = $Sounds/Tricks/UpsideSound

# Areas
onready var damage_area = $JumpSkin/IdleSkin/EatSkin/DamageSkin/AngleSkin/TricksFix/Tricks/DeadNode/DamageArea

# Players
onready var damage_player = $Players/DamagePlayer
onready var trick_player = $Players/TrickPlayer
onready var perform_trick_player = $Players/PerformTrickPlayer
onready var eat_player = $Players/EatPlayer
onready var dead_player = $Players/DeadPlayer

# Timers
onready var between_frame_timer = $Timers/BetweenFrameTimer
onready var left_timer = $Timers/LeftTimer
onready var right_timer = $Timers/RightTimer
onready var up_timer = $Timers/UpTimer
onready var down_timer = $Timers/DownTimer

# Parameters
var acceleration = 400
var local_speed : float = 100
var velocity = Vector2.ZERO

var health = 10
var max_health = 10
var alive = true

# Jump
var on_floor = true
var jump_velocity = Vector2.ZERO
var jump_strength = 200
var gravity = 300

# Tricks
enum {IDLE, BACK, TURN, ROTATE, ANGLE, UPSIDE}
var trick = IDLE
var trick_action = false
var trick_completed = false
var right_click = false
var left_click = false
var up_click = false
var down_click = false

var left_pressed = false
var right_pressed = false
var up_pressed = false
var down_pressed = false

var end_screen = false

var humans_eaten = 0
var tricks_count = 0

######################################################
### CORE CYCLE ###
##################

func _ready():
	pass
	#get_tree().call_group("gui", "update_health", health)

func _physics_process(delta):
	position.y = clamp(position.y, 10, 180)
	global_position.y = clamp(global_position.y, 0, 180)
	if alive:
		global_position.x = clamp(global_position.x, 0, 320)
	jump_skin.position.y = clamp(jump_skin.position.y, -200, 0)
	
	food_container.global_rotation = 0
	food_container.global_scale = Vector2(1,1)
	
	tricks()
	movement(delta)
	jump(delta)
	apply_gravity(delta)
	color_correct()
	spawn_snow_trail()
	snow_sound_volume()
	
	if global_position.x <= 0 and !alive:
		if !end_screen:
			end_screen = true
			game.end()

#######################################################
### MOVEMENT ###
################

func movement(delta):
	var axis = get_input_axis()
	if axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
	else:
		apply_movement(axis * acceleration * delta)
	velocity = move_and_slide(velocity)

	if axis.x > 0 and axis.y < 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, -15, 0.05)
	elif axis.x > 0 and axis.y > 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, 15, 0.05)
	elif axis.x > 0 and axis.y == 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, 10, 0.05)
		
	elif axis.x < 0 and axis.y > 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, 15, 0.05)
	elif axis.x < 0 and axis.y < 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, -15, 0.05)
	elif axis.x < 0 and axis.y == 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, -10, 0.05)
	
	elif axis.x == 0 and axis.y > 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, 10, 0.05)
	elif axis.x == 0 and axis.y < 0:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, -10, 0.05)
	
	if axis.x != 0 and axis.y == 0:
		angle_skin.scale.x = lerp(angle_skin.scale.x, 0.9, 0.05)
	elif axis.x != 0 and axis.y != 0:
		angle_skin.scale.x = lerp(angle_skin.scale.x, 0.8, 0.05)
		
	if axis.y != 0 and axis.x == 0:
		angle_skin.scale.y = lerp(angle_skin.scale.y, 1.1, 0.05)
	elif axis.y != 0 and axis.x != 0:
		angle_skin.scale.y = lerp(angle_skin.scale.y, 1.2, 0.05)
	
	elif axis == Vector2.ZERO:
		angle_skin.rotation_degrees = lerp(angle_skin.rotation_degrees, 0, 0.05)
		angle_skin.scale = lerp(angle_skin.scale, Vector2(1,1), 0.05)

func get_input_axis():
	var axis = Vector2.ZERO
	if alive:
		axis.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		axis.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	else:
		axis = Vector2.ZERO
	return axis.normalized()

func jump(delta):
	if on_floor and Input.is_action_pressed("jump") and alive:
		on_floor = false
		damage_area.get_node("DamageCollision").set_deferred("disabled", true)
		jump_velocity.y -= jump_strength
		jump_sound()
		#jump_sound.play()
		left_click = false
		left_pressed = false
		left_timer.stop()
		
		right_click = false
		right_pressed = false
		right_timer.stop()
		
		up_click = false
		up_pressed = false
		up_timer.stop()
		
		down_click = false
		down_pressed = false
		down_timer.stop()
	
	if on_floor:
		jump_velocity = Vector2.ZERO
		
	jump_skin.position += jump_velocity * delta
	
	if jump_skin.position.y >= 0 and !on_floor:
		camera.land_shake()
		on_floor = true
		land_sound()
		damage_area.get_node("DamageCollision").set_deferred("disabled", false)
		if trick_action and !trick_completed:
			trick_action = false
			trick_completed = true
			trick = IDLE
			get_damage()
	
	if abs(jump_velocity.y) != 0:
		jump_skin.scale = lerp(jump_skin.scale, Vector2(0.7,1.3), 0.1)
	elif abs(jump_velocity.y) == 0:
		jump_skin.scale = lerp(jump_skin.scale, Vector2(1,1), 0.1)

################################################
### FORCES ###
##############

func apply_gravity(delta):
	if !on_floor:
		jump_velocity.y += gravity * delta

func apply_friction(amount):
	if alive:
		if velocity.length() > amount:
			velocity -= velocity.normalized() * amount
		else:
			velocity = Vector2.ZERO

func apply_movement(acceleration_amount):
	velocity += acceleration_amount
	if velocity.length() >= local_speed:
		velocity = velocity.normalized() * local_speed

##############################################################
### TRICKS ###
##############

func tricks():
	if (!on_floor and trick == IDLE and !trick_action and (jump_velocity.y <= 0 or jump_skin.position.y < 16) and Input.is_action_pressed("jump")) and alive:
		if up_click:
			up_click = false
			trick = ANGLE
			trick_action = true
			trick_completed = false
			perform_trick_player.play("Push")
			set_between_frame()
			sprite.play("Trick1")
			trick_player.play("Angle")
			angle_sound.pitch_scale = rand_range(0.9,1.1)
			angle_sound.play()
			#trick_sound.play()
		elif Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
			left_click = false
			right_click = false
			trick = ROTATE
			trick_action = true
			trick_completed = false
			perform_trick_player.play("Push")
			set_between_frame()
			sprite.play("Trick3")
			trick_player.play("Rotate")
			rotate_sound.pitch_scale = rand_range(0.9,1.1)
			rotate_sound.play()
		elif left_click and !Input.is_action_pressed("move_right"):
			left_click = false
			trick = BACK
			trick_action = true
			trick_completed = false
			perform_trick_player.play("Push")
			set_between_frame()
			sprite.play("Trick2")
			trick_player.play("Back")
			back_sound.pitch_scale = rand_range(0.9,1.1)
			back_sound.play()
			#trick_sound.play()
			#trick_sound.play()
		elif right_click and !Input.is_action_pressed("move_left"):
			right_click = false
			trick = TURN
			trick_action = true
			trick_completed = false
			perform_trick_player.play("Push")
			set_between_frame()
			sprite.play("Trick4")
			trick_player.play("Turn")
			turn_sound.pitch_scale = rand_range(0.9,1.1)
			turn_sound.play()
			#trick_sound.play()
		elif down_click:
			down_click = false
			trick = UPSIDE
			trick_action = true
			trick_completed = false
			perform_trick_player.play("Push")
			set_between_frame()
			sprite.play("Trick5")
			trick_player.play("Upside")
			upside_sound.pitch_scale = rand_range(0.9,1.1)
			upside_sound.play()
			#trick_sound.play()
	if on_floor and trick == IDLE:
		trick_action = false
	if !on_floor:
		if Input.is_action_pressed("move_left"):
			if !left_pressed:
				left_pressed = true
				left_timer.start()
		else:
			left_pressed = false
			left_timer.stop()
		
		if Input.is_action_pressed("move_right"):
			if !right_pressed:
				right_pressed = true
				right_timer.start()
		else:
			right_pressed = false
			right_timer.stop()
		
		if Input.is_action_pressed("move_up"):
			if !up_pressed:
				up_pressed = true
				up_timer.start()
		else:
			up_pressed = false
			up_timer.stop()
				
		if Input.is_action_pressed("move_down"):
			if !down_pressed:
				down_pressed = true
				down_timer.start()
		else:
			down_pressed = false
			down_timer.stop()
			
	elif on_floor:

		
		left_click = false
		left_pressed = false
		left_timer.stop()
		
		right_click = false
		right_pressed = false
		right_timer.stop()
		
		up_click = false
		up_pressed = false
		up_timer.stop()
		
		down_click = false
		down_pressed = false
		down_timer.stop()

func set_between_frame():
	between_sprite.animation = sprite.animation
	between_sprite.stop()
	between_sprite.frame = sprite.frame
	between_sprite.visible = true
	between_frame_timer.start()

func trick_complete():
	trick_completed = true
	perform_trick_player.play("Push")
	set_between_frame()
	sprite.play("Idle")
	
	tricks_count += 1
	if health < max_health:
		health += 1
	if health >= max_health:
		health = max_health
	get_tree().call_group("gui", "update_health", health)

func _on_TrickPlayer_animation_finished(_anim_name):
	trick = IDLE
	left_click = false
	left_pressed = false
	left_timer.stop()
	
	right_click = false
	right_pressed = false
	right_timer.stop()
	
	up_click = false
	up_pressed = false
	up_timer.stop()
	
	down_click = false
	down_pressed = false
	down_timer.stop()

func _on_BetweenFrameTimer_timeout():
	between_sprite.visible = false

##############
### DAMAGE ###
###########################################################

func _on_DamageArea_area_entered(area):
	if area.is_in_group("obstacles"):
		var obstacle = area.get_parent().get_parent().get_parent().get_parent()
		get_damage()
		if obstacle.kind == 0:
			rock_sound()
		elif obstacle.kind == 1:
			tree_sound()
		elif obstacle.kind == 2:
			snowman_sound()
		obstacle.get_damage()
		health_damage(1)
		#emit_signal("update_gui_health",-1)
		#hit_sound.play()
	elif area.is_in_group("bears"):
		var bear = area.get_parent().get_parent().get_parent().get_parent()
		var new_impact = (bear.position - position).normalized() * bear.impact
		get_bear_damage(new_impact)
		bear.get_damage()
		health_damage(2)
		#emit_signal("update_gui_health",-2)
		bounce_sound()
		bear_sound()
		#hit_sound.play()
	elif area.is_in_group("humans"):
		var new_human = area.get_parent()
		new_human.eat()
		roar_sound()
		var rand_cry = round(rand_range(0,1))
		if rand_cry == 0:
			male_cry_sound()
		elif rand_cry == 1:
			female_sound()
	elif area.is_in_group("flag"):
		health_damage(1)
		bounce_damage(150)
		
func get_damage():
	damage_player.play("Damage")
	camera.small_shake()
	damage_skin.modulate = damage_color
	
	trick = IDLE
	left_click = false
	left_pressed = false
	left_timer.stop()
	
	right_click = false
	right_pressed = false
	right_timer.stop()
	
	up_click = false
	up_pressed = false
	up_timer.stop()
	
	down_click = false
	down_pressed = false
	down_timer.stop()

func bounce_damage(new_impact):
	damage_player.play("Damage")
	camera.small_shake()
	bounce_sound()
	damage_skin.modulate = damage_color
	velocity.y += new_impact
	if velocity.x < -200:
		velocity.x = -200
	elif velocity.x > 200:
		velocity.x = 200
	if velocity.y < -200:
		velocity.y = -200
	elif velocity.y > 200:
		velocity.y = 200 
	
	trick = IDLE
	left_click = false
	left_pressed = false
	left_timer.stop()
	
	right_click = false
	right_pressed = false
	right_timer.stop()
	
	up_click = false
	up_pressed = false
	up_timer.stop()
	
	down_click = false
	down_pressed = false
	down_timer.stop()


func get_bear_damage(new_impact):
	damage_player.play("Damage")
	camera.small_shake()
	damage_skin.modulate = damage_color
	velocity -= new_impact
	if velocity.x < -200:
		velocity.x = -200
	elif velocity.x > 200:
		velocity.x = 200
	if velocity.y < -200:
		velocity.y = -200
	elif velocity.y > 200:
		velocity.y = 200 
	
	trick = IDLE
	left_click = false
	left_pressed = false
	left_timer.stop()
	
	right_click = false
	right_pressed = false
	right_timer.stop()
	
	up_click = false
	up_pressed = false
	up_timer.stop()
	
	down_click = false
	down_pressed = false
	down_timer.stop()

#################################################
### EAT ###
###########

func eat_humans(kind_of_human, human_pos):
	var new_human = human.instance()
	new_human.get_node("HumanSprite").play(str(kind_of_human))
	food_container.add_child(new_human)
	new_human.owner = food_container
	new_human.global_position = human_pos + Vector2(0,-9)

signal update_humans_eaten

func swallow():
	munch_sound()
	crush_sound()
	eat_player.stop()
	eat_player.play("Eat")
	var new_blood = blood.instance()
	blood_node.add_child(new_blood)
	new_blood.owner = blood_node
	emit_signal("update_humans_eaten")
	humans_eaten += 1
	#crunch_sound.play()
	

##############################################
### EFFECTS ###
###############

func trail_effect():
	var new_trail = trail.instance()
	var new_alpha 
	var movement_alpha = (abs(velocity.x) / local_speed) / 1.5
	var jump_alpha = (abs(jump_velocity.y) / jump_strength) / 1.5
	if movement_alpha >= jump_alpha:
		new_alpha = movement_alpha
	elif jump_alpha >= movement_alpha:
		new_alpha = jump_alpha
	
	new_trail.modulate.a = new_alpha
	new_trail.get_node("Skin").scale = sprite.global_scale
	new_trail.get_node("Skin").rotation_degrees = sprite.global_rotation_degrees - game.slope 
	new_trail.get_node("Skin/YetiSprite").frame = sprite.frame
	new_trail.get_node("Skin/YetiSprite").stop()
	new_trail.position = position + jump_skin.position + trick_fix.position
	trails.add_child(new_trail)
	new_trail.owner = trails

func _on_TrailTimer_timeout():
	if (velocity.x > 0 and velocity.length() > 0) or jump_velocity.length() > 0:
		trail_effect()
	
func color_correct():
	damage_skin.modulate = lerp(damage_skin.modulate, Color(1,1,1,1), 0.1)
	trick_skin.modulate = lerp(trick_skin.modulate, Color(1,1,1,1), 0.1)

func spawn_snow_trail():
	if on_floor:
		var new_snow_trail = snow_trail.instance()
		new_snow_trail.position = position + Vector2(0,-1)
		new_snow_trail.rotation_degrees = sprite.global_rotation_degrees - game.slope - trick_skin.rotation_degrees
		snow_trails.add_child(new_snow_trail)

##############################################
### SOUNDS ###
###############


func roar_sound():
	var sounds = $Sounds/RoarSounds.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func crush_sound():
	var sounds = $Sounds/CrushSounds.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func munch_sound():
	var sounds = $Sounds/MunchSounds.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func jump_sound():
	var sounds = $Sounds/JumpSounds.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func land_sound():
	var sounds = $Sounds/LandSounds.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func bounce_sound():
	var sounds = $Sounds/Bounce.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func bear_sound():
	var sounds = $Sounds/BearSound.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func rock_sound():
	var sounds = $Sounds/Rock.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func tree_sound():
	var sounds = $Sounds/Tree.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func snowman_sound():
	var sounds = $Sounds/Snowman.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func male_cry_sound():
	var sounds = $Sounds/MaleCry.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func female_sound():
	var sounds = $Sounds/FemaleCry.get_children()
	var current_sound = sounds[round(rand_range(0,sounds.size()-1))]
	current_sound.pitch_scale = rand_range(0.8,1.2)
	current_sound.play()

func snow_sound_volume():
	if on_floor:
		snow_sound.volume_db = -2
	else:
		snow_sound.volume_db = -80

func _on_LeftTimer_timeout():
	left_click = true

func _on_RightTimer_timeout():
	right_click = true

func _on_UpTimer_timeout():
	up_click = true

func _on_DownTimer_timeout():
	down_click = true

func health_damage(new_damage):
	if health > 0:
		health -= new_damage
	if health <= 0:
		health = 0
		alive = false
		dead_player.play("Dead")
		velocity.x = - 200
		velocity.y = 0
		
	get_tree().call_group("gui", "update_health", health)

func end_of_avalanche():
	snow_sound.stop()
	end_avalanche.interpolate_property($Sounds/Avalanche/Avalanche, "volume_db", $Sounds/Avalanche/Avalanche.volume_db, -80, 3,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	end_avalanche.start()
