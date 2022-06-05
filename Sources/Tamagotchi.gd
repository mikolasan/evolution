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

var animate_cards = []
var marked_to_discard = []
var data = {
	selected_card = null
}
var last_hint_trigger = null

func _ready():
	for i in $Hand.get_child_count():
		var card_object = get_card_object(i)
		card_object.connect("card_selected", self, "on_card_selected", [i])
		card_object.connect("card_revealed", self, "on_card_revealed", [i])
	$Status.text = "Drawing cards for new hand..."

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = get_local_mouse_position()
#		printt("input", mouse_position)

func on_apply_pressed():
	for discard_id in marked_to_discard:
		data.hand.remove(discard_id)
	marked_to_discard = []

	data.old_values = data.values.duplicate()
	data.old_traits = data.traits.duplicate()
	if data.selected_card.one_time_effect:
		if typeof(data.selected_card.one_time_effect) == TYPE_OBJECT:
			data.selected_card.one_time_effect.call_func(data.values, data.traits)
		elif typeof(data.selected_card.one_time_effect) == TYPE_STRING:
			var regex = RegEx.new()
			regex.compile("(?<meter>\\w+): (?<op>[\\+\\-x])(?<value>\\d+);*")
			for result in regex.search_all(data.selected_card.one_time_effect):
				var meter = result.get_string("meter")
				var op = result.get_string("op")
				var v = int(result.get_string("value"))
				var old_value = data.values[meter]
				var new_value
				match op:
					"+":
						new_value = old_value + v
					"-":
						new_value = old_value - v
					"x":
						new_value = old_value * v
				data.values[meter] = new_value

	if data.selected_card.constant_effect:
		if typeof(data.selected_card.constant_effect) == TYPE_OBJECT:
			data.constant_cards.append(data.selected_card)
		elif typeof(data.selected_card.constant_effect) == TYPE_STRING:
			data.traits.append(data.selected_card.constant_effect)
	data.hand.erase(data.selected_card)

	$Apply.disabled = true
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
	animate_cards = []
	var hand = control_data.hand
	var new_cards = control_data.new_cards
	for i in $Hand.get_child_count():
		var card_object = get_card_object(i)
		card_object.show()
		if i >= hand.size():
			if not new_cards.empty():
				var card = new_cards.pop_front()
				hand.append(card)
				animate_cards.append(i)
				card_object.hide()
			else:
				card_object.hide()
				continue
		var card = hand[i]
		card_object.set_card(i, card)

	data.selected_card = null
	marked_to_discard = []
	$Status.text = "Select a card to play at this " + control_data.player_shift
	$Apply.disabled = true
	$Hint.hide()
	last_hint_trigger = null
	
	animate_card_drawing()

func animate_card_drawing():
	if animate_cards.empty(): return
	var card_id = animate_cards.pop_front()
	var card_object = get_card_object(card_id)
	card_object.show()
	card_object.reveal($Deck.rect_position, $Deck.rect_size)

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

func on_card_revealed(card_id):
	animate_card_drawing()

const h_offset = 10
const v_offset = 10

func show_hint(hint_area, message):
	if message == "": return
	
	var hint = $Hint
	hint.text = message
	hint.rect_size.y = hint.get_line_height() * hint.get_line_count()
	hint.show()
	
	var card_size = hint.rect_size
	var mouse_position = hint_area.get_global_mouse_position()
	var p = mouse_position + Vector2(-(card_size.x/2.0), v_offset)
	var window_size = $Background.rect_size
	if p.x + card_size.x > window_size.x:
		p.x = window_size.x - card_size.x - h_offset
	elif p.x < 0:
		p.x = h_offset
	if p.y + card_size.y > window_size.y:
		p.y = mouse_position.y - card_size.y - v_offset
#	printt("show_hint", hint_area.get_path(), mouse_position, card_size, p, window_size)
	hint.rect_position = p

	last_hint_trigger = hint_area

func hide_hint(hint_area):
	var mouse_position = hint_area.get_local_mouse_position()
#	printt("hide_hint", hint_area.get_path(), mouse_position, hint_area.rect_size)
	
	if not Rect2(Vector2(), hint_area.rect_size).has_point(mouse_position):
		$Hint.hide()
		last_hint_trigger = null

func on_hunger_mouse_entered():
	var message = """When you have 5 Hunger at the end of opponent's turn, then Discipline increases by 1.
	Number below the square shows how the current value will affect population at the end of opponnet's turn"""
	show_hint($HungerIcon/HintArea, message)

func on_hunger_mouse_exited():
	hide_hint($HungerIcon/HintArea)

func on_happiness_mouse_entered():
	var message = """When you have 5 Happiness at the end of opponent's turn, then Discipline increases by 2.
	Number below the square shows how the current value will affect population at the end of opponnet's turn"""
	show_hint($HappinessIcon/HintArea, message)

func on_happiness_mouse_exited():
	hide_hint($HappinessIcon/HintArea)

func on_discipline_mouse_entered():
	var message = """When you have 5 Discipline at the end of opponent's turn, then Training increases by 1.
	Number below the square shows how the current value will affect population at the end of opponnet's turn"""
	show_hint($DisciplineIcon/HintArea, message)

func on_discipline_mouse_exited():
	hide_hint($DisciplineIcon/HintArea)

func on_training_mouse_entered():
	var message = """When Training reaches 5, then the day shift wins and the game ends"""
	show_hint($TrainingIcon/HintArea, message)

func on_training_mouse_exited():
	hide_hint($TrainingIcon/HintArea)

func on_population_mouse_entered():
	var message = "Population over 80 requires more food than exists in the environment, which causes hunger to grow (-1) every turn"
	show_hint($PopulationLabel/HintArea, message)

func on_population_mouse_exited():
	hide_hint($PopulationLabel/HintArea)

func on_end_shift_mouse_entered():
	var message = """When the button is active you can apply your chooice of cards.
		You need to select one card for the main action,select two cards to discard and then your shift can be over (this button will become active)"""
	show_hint($Apply/HintArea, message)

func on_end_shift_mouse_exited():
	hide_hint($Apply/HintArea)

func on_hint_timer_timeout():
	var mouse_position = get_local_mouse_position()
