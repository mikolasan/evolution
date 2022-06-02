extends Node2D

func _ready():
	$Main.connect("start_pressed", self, "show_start_menu")
	$Start.connect("shift_selected", self, "on_shift_selected")
	$Lab.connect("menu_pressed", self, "show_menu")
	$Lab.connect("end_day_pressed", self, "next_turn")
	$Lab.connect("goto_control_pressed", self, "show_control")
	$Control.connect("apply_pressed", self, "show_lab")
	$Control.connect("menu_pressed", self, "show_menu")

#	$StateMachinePlayer.set_trigger("ready")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "Ready", "hide")
	$AnimationPlayer.play("Splash")


func on_shift_selected(shift):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "LabShow", "hide")
	$Lab.set_shift(shift)
	$Lab.update_scene()
	$Lab.show()

func show_main_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "MainMenuShow", "hide")
	$Main.show()

func show_start_menu():
	$AnimationPlayer.play("Start")

func _show_start_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "StartMenuShow", "hide")
	$Start.show()

func show_lab(control_data):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "LabShow", "hide")
	$Lab.next_day(control_data)
	$Lab.show()

func show_control(day, control_data):
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "ControlShow", "hide")
	$Control.update_scene(day, control_data)
	$Control.show()

func next_turn():
	pass

func on_state_machine_updated(state, delta):
	match state:
		"Splash":
			$AnimationPlayer.play("Logo")
		"Main":
			$AnimationPlayer.play("Show Main")
			show_main_menu()

func on_player_animation_finished(anim_name):
	match anim_name:
		"Logo":
			pass
		"Show Main":
			pass
