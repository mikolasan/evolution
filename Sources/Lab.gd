extends Node2D

signal menu_pressed
signal goto_control_pressed
signal end_day_pressed

var player_shift: String
var ai_shift: String
var discard_pile
var chosen_card
var day_shift_cards = Cards.day_shift
var night_shift_cards = Cards.night_shift

func _ready():
	pass

func set_shift(shift):
	player_shift = shift
	$PlayerShift.text = player_shift + " shift"
	if shift == "day":
		ai_shift = "night"
	else:
		ai_shift = "day"
	$OpponentShift.text = ai_shift + " shift"

func on_menu_pressed():
	emit_signal("menu_pressed")


func on_goto_control_pressed():
	emit_signal("goto_control_pressed")


func on_end_day_pressed():
	emit_signal("end_day_pressed")
