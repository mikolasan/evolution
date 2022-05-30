extends Node2D

signal menu_pressed

var player_shift: String

func _ready():
	pass

func set_shift(shift):
	player_shift = shift
	$PlayerShift.text = shift + " shift"


func on_menu_pressed():
	emit_signal("menu_pressed")
