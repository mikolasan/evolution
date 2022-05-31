extends Node2D

signal start_pressed

func _ready():
	pass


func on_start_pressed():
	emit_signal("start_pressed")


func on_exit_pressed():
	get_tree().quit()
