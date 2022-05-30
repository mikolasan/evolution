extends Node2D


func _ready():
	$Main.connect("start_pressed", $Start, "show")
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "StartupHide", "hide")
	
	$Main.show()
