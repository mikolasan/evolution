extends Node2D

signal shift_selected(shift)

func _ready():
	pass


func on_day_shift_pressed():
	emit_signal("shift_selected", "day")


func on_night_shift_pressed():
	emit_signal("shift_selected", "night")
