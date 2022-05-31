extends Node2D

func _ready():
	$Main.connect("start_pressed", self, "show_start_menu")
	$Start.connect("shift_selected", self, "on_shift_selected")
	$Lab.connect("menu_pressed", self, "show_menu")
	$Lab.connect("end_day_pressed", self, "next_turn")
	$Lab.connect("goto_control_pressed", self, "show_control")
	$Control.connect("apply_pressed", self, "show_lab")
	$Control.connect("menu_pressed", self, "show_menu")
	
	show_menu()

func on_shift_selected(shift):
	$Lab.set_shift(shift)
	show_lab()

func show_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "MainMenuShow", "hide")
	$Main.show()
	
func show_start_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "StartMenuShow", "hide")
	$Start.show()

func show_lab():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "LabShow", "hide")
	$Lab.show()

func show_control():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "ControlShow", "hide")
	$Control.show()
	
func next_turn():
	pass
