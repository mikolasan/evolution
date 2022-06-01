extends Node2D

signal menu_pressed
signal apply_pressed

const RED_COLOR = Color("d10000")
const ORANGE_COLOR = Color("d14000")
const YELLOW_COLOR = Color("d1a700")
const LIME_COLOR = Color("a3d100")
const GREEN_COLOR = Color("33d100")
const scale_colors = [
	RED_COLOR,
	ORANGE_COLOR,
	YELLOW_COLOR,
	LIME_COLOR,
	GREEN_COLOR
]
const OFF_COLOR = Color("3a3a3a")

var marked_to_discard = []
var data = {
	selected_card = null
}

func _ready():
	for i in $Hand.get_child_count():
		var card_object = get_card_object(i)
		card_object.connect("card_selected", self, "on_card_selected", [i])
	$Status.text = "Drawing cards for new hand..."

func on_apply_pressed():
	for discard_id in marked_to_discard:
		data.hand.remove(discard_id)
	marked_to_discard = []
	
	data.selected_card.effect.call_func(data.values, data.traits)
	if data.selected_card.constant:
		data.constant_cards.append(data.selected_card)
	data.hand.erase(data.selected_card)
	
	emit_signal("apply_pressed", data)

func on_menu_pressed():
	emit_signal("menu_pressed")

func update_scene(day, control_data):
	data = control_data
	
	$Day.text = str(day)
	var values = control_data.values
	$Population.text = str(values.population)

	var population_modifiers = control_data.population_modifiers
	for meter in ["hunger", "happiness", "discipline"]:
		update_modifiers(meter, population_modifiers[meter], values[meter])
	for meter in ["hunger", "happiness", "discipline", "training"]:
		update_scale(meter, values[meter])

	var traits = control_data.traits
	var hand = control_data.hand
	for i in $Hand.get_child_count():
		var card_object = get_card_object(i)
		if i >= hand.size():
			card_object.hide()
		var card = hand[i]
		card_object.set_card(i, card)
	
	data.selected_card = null
	marked_to_discard = []
	$Status.text = "Select a card to play at this " + control_data.player_shift
	$Apply.disabled = true

func get_card_object(card_id):
	return $Hand.get_node("Card" + str(card_id + 1))

func set_card_state(card_id, state):
	var card_object = get_card_object(card_id)
	card_object.set_state(state)

func update_modifiers(scale_name, values, scale_value):
	var modifiers
	match scale_name:
		"hunger":
			modifiers = $GridContainer/HungerContainer/AffectPopulation
		"happiness":
			modifiers = $GridContainer/HappinessContainer/AffectPopulation
		"discipline":
			modifiers = $GridContainer/DisciplineContainer/AffectPopulation
	
	for i in range(modifiers.get_child_count()):
		var label = modifiers.get_node(str(i + 1))
		label.text = str(values[i])
		label.add_color_override("font_color", Color("ffffff") if scale_value == (i+1) else Color("828282"))

func update_scale(scale_name, value):
	var scale
	match scale_name:
		"hunger":
			scale = $GridContainer/HungerContainer/Scale
		"happiness":
			scale = $GridContainer/HappinessContainer/Scale
		"discipline":
			scale = $GridContainer/DisciplineContainer/Scale
		"training":
			scale = $TrainingLabel/Scale
	
	for i in range(scale.get_child_count()):
		var tile = scale.get_node(str(i + 1))
		tile.color = scale_colors[i] if value >= (i + 1) else OFF_COLOR

func on_card_selected(card_id):
	if data.selected_card != null and data.selected_card == data.hand[card_id]:
		data.selected_card = null
		set_card_state(card_id, "")
		for discard_id in marked_to_discard:
			set_card_state(discard_id, "")	
		marked_to_discard = []
		$Status.text = "Select a card to play at this " + data.player_shift
		$Apply.disabled = true
	elif data.selected_card == null:
		data.selected_card = data.hand[card_id]
		set_card_state(card_id, "Action")
		$Status.text = "Select two cards to discard"
		$Apply.disabled = true
	else:
		if marked_to_discard.has(card_id):
			marked_to_discard.erase(card_id)
			set_card_state(card_id, "")
		elif marked_to_discard.size() < 2:
			marked_to_discard.append(card_id)
			set_card_state(card_id, "Discard")
		if marked_to_discard.size() == 2:
			$Status.text = "You are done for this " + data.player_shift + ". Press Apply"
			$Apply.disabled = false
		else:
			$Status.text = "Select two cards to discard"
			$Apply.disabled = true
