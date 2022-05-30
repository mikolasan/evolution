extends Node2D

func _ready():
	$Main.connect("start_pressed", self, "show_start_menu")
	$Start.connect("shift_selected", self, "on_shift_selected")
	$Lab.connect("menu_pressed", self, "show_menu")
	
	show_menu()

func on_shift_selected(shift):
	show_lab()
	$Lab.set_shift(shift)

func show_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "MainMenuShow", "hide")
	$Main.show()
	
func show_start_menu():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "StartMenuShow", "hide")
	$Start.show()

func show_lab():
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "LabShow", "hide")
	$Lab.show()
