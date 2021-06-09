extends MarginContainer

onready var gui_humans_eaten = 0
onready var gui_health_change = 0
onready var gui_health = 10

# Players
onready var human_player = $VBoxContainer/HBoxContainer/HumansPlayer
onready var health_palyer = $VBoxContainer/HealthContainer/HealthPlayer

#func on_Yeti__update_humans_eaten(gui_health):
	#$HealthBar.value = gui_health

func _on_Yeti_update_humans_eaten():
	gui_humans_eaten += 1
	$VBoxContainer/HBoxContainer/NumberLabel.text = String(gui_humans_eaten)
	human_player.play("Eat")
	
#func _on_Yeti_update_gui_health(gui_health_change):
#	gui_health += gui_health_change
	#$CenterContainer/HealthBar.value = gui_health 

func update_health(new_health):
	$VBoxContainer/HealthContainer/HealthCount.text = str(new_health)
	health_palyer.play("Health")
	
