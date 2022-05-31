extends Control

signal card_selected

var card_id: int

func _ready():
	pass

func get_color_for_trait(trait):
	var color
	match trait:
		"reproduction":
			color = Color("c0ca49")
		"breath":
			color = Color("379538")
		"immune":
			color = Color("643795")
		"nutrition":
			color = Color("8a3795")
		"locomotion":
			color = Color("373f95")
		_:
			color = Color("ca4949")
	return color

func get_color_for_type(type):
	var color
	match type:
		"dna":
			color = Color("")
		"class defenitive":
			color = Color("")
		"planet":
			color = Color("")
		_:
			color = Color("")
		
	return color

# Card example:
#   "title":"Global flood",
#   "trait": "",
#   "type": "",
#   "description": "-1 happiness, -1 discipline",
#   "constant": false,
#   "effect": funcref(self, "global_flood_func"),
func set_card(card_id, card):
	self.card_id = card_id
	var container = $MarginContainer/VBoxContainer
	container.get_node("Title").text = card.title
	get_node("Background").color = get_color_for_trait(card.trait)
#	container.get_node("TypeAccent").color = get_color_for_type(card.type)
	container.get_node("Type").text = card.type
	container.get_node("Description").text = card.description
	set_state("")

func set_state(state):
	$State.text = state

func on_card_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("card_selected")
