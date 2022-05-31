extends Node2D

signal menu_pressed
signal apply_pressed

func _ready():
	pass


func on_apply_pressed():
	emit_signal("apply_pressed")

func on_menu_pressed():
	emit_signal("menu_pressed")
