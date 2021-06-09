extends Node

var played = false

var eaten = 0
var tricks = 0

func play():
	played = true

func new_score(new_eaten, new_tricks):
	if new_eaten > eaten:
		eaten = new_eaten
	if new_tricks > tricks:
		tricks = new_tricks
