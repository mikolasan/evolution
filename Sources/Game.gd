extends Node2D

func _ready():
	$Main.connect("start_pressed", self, "show_start_menu")
	$Start.connect("shift_selected", self, "on_shift_selected")
	$Lab.connect("menu_pressed", self, "show_menu")
	$Lab.connect("end_day_pressed", self, "next_turn")
	$Lab.connect("goto_control_pressed", self, "show_control")
	$Results.connect("result_shown", self, "on_result_shown")
	$Results.connect("next_pressed", self, "on_next_pressed")
	$Control.connect("apply_pressed", self, "show_results")
	$Control.connect("menu_pressed", self, "show_menu")
	$Results.connect("menu_pressed", self, "show_menu")

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

func show_lab():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "LabShow", "hide")
	$Lab.show()

func show_results(control_data):
	$Lab.control_data = control_data
	$Results.show_player(control_data)
	$Lab.apply_constant_card_effects()
	$AnimationPlayer.play("Results")

func on_result_shown(player):
	if player == "player":
		$Lab.play_opponent_shift()
		$Lab.apply_population_modifiers($Lab.control_data)
		$Lab.apply_end_of_day_effects()
		$Results.show_opponent($Lab.control_data)
	else:
		# winning condition
		var game_end = $Lab.check_winning_condition()
		if game_end:
			$Results.get_node("Next").hide()
			$Results.show_final_result(game_end.flag)

func on_next_pressed(player):
	if player == "player":
		$Lab.play_opponent_shift()
		$Lab.apply_population_modifiers($Lab.control_data)
		$Lab.apply_end_of_day_effects()
		$Results.show_opponent($Lab.control_data)
	else:
		$Lab.next_day($Lab.control_data)
		show_lab()

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

func _input(event):
	if event is InputEventKey and event.scancode == KEY_SPACE:
		if $AnimationPlayer.current_animation == "Start":
			$AnimationPlayer.advance(8.5)
		elif $Results.visible and $Results.shown:
			$AnimationPlayer.play("Next day")
