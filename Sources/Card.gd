extends Control

signal card_selected
signal card_revealed(card_id)

var card_id: int
onready var table_position = get_rect().position

func _ready():
	pass

func get_color_for_type(type):
	var color
	match type:
		"Environment Impact":
			color = Color("0b39d6")
		"Deterrent":
			color = Color("379538")
		"Trait":
			color = Color("643795")
		"Interference":
			color = Color("8a3795")

		"Reproduction":
			color = Color("d60ba3")
		"Breath":
			color = Color("379538")
		"Immune":
			color = Color("643795")
		"Nutrition":
			color = Color("8a3795")
		"Locomotion":
			color = Color("373f95")

		_:
			color = Color("ca4949")

	return color

# Card example:
#  "title":"Global flood",
#  "type": "Environment Impact",
#  "description": "You jump on a boat, but after that you are in the new place without old friends",
#  "one_time_effect": "happiness: -1; discipline: -1",
#  "constant_effect": null,
func set_card(card_id, card):
	self.card_id = card_id
	var container = $MarginContainer/VBoxContainer
	container.get_node("Title").text = card.title
	get_node("HeaderBack").color = get_color_for_type(card.type)
	container.get_node("Type").text = card.type
	container.get_node("Description").text = card.description
	set_state("")
	
	if card.one_time_effect and typeof(card.one_time_effect) == TYPE_STRING:
		var regex = RegEx.new()
		regex.compile("(?<meter>\\w+): (?<op>[\\+\\-x])(?<value>\\d+);*")
		for result in regex.search_all(card.one_time_effect):
			var meter = result.get_string("meter")
			var op = result.get_string("op")
			var value = result.get_string("value")
			match meter:
				"happiness":
					$HappinessIcon/Label.text = op + value
				"hunger":
					$HungerIcon/Label.text = op + value
				"discipline":
					$DisciplineIcon/Label.text = op + value
				"training":
					$TrainingIcon/Label.text = op + value
				"population":
					pass
	
	$BackSide.hide()

func close_card():
	$BackSide.show()

func open_card():
	$BackSide.hide()

func set_state(state):
	$StateBack.visible = state != ""
	$StateBack/State.text = state

func on_card_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("card_selected")

func reveal(deck_position, deck_size):
	$BackSide.show()
	var tween = get_node("Tween")
	
	var x_scale = deck_size.x / rect_size.x
	var y_scale = deck_size.y / rect_size.y
	var deck_scale = Vector2(x_scale, y_scale)
	rect_scale = deck_scale
	tween.interpolate_property(self,
		"rect_scale",
		deck_scale,
		Vector2(1.0, 1.0),
		1,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	rect_position = deck_position
	tween.interpolate_property(self,
		"rect_position",
		deck_position,
		table_position,
		1,
		Tween.TRANS_QUAD,
		Tween.EASE_IN_OUT
	)
	tween.start()

func on_tween_completed(object, key):
	if key.get_subname(0) == "rect_position":
		$BackSide.hide()
		emit_signal("card_revealed")

func on_tween_step(object, key, elapsed, value):
	pass
#	if key.get_subname(0) == "rect_scale":
#		print(elapsed, value)
