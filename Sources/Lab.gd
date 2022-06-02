extends Node2D

signal menu_pressed
signal goto_control_pressed(day, control_data)
signal end_day_pressed

var player_shift: String
var opponent_shift: String
var discard_pile = []
var selected_card = {}
var constant_cards = []
var day_shift_cards = Cards.day_shift
var night_shift_cards = Cards.night_shift
const INITIAL_POPULATION = 100
const INITIAL_HUNGER = 2
const INITIAL_HAPPINESS = 1
const INITIAL_DISCIPLINE = 1
const INITIAL_TRAINING = 0

var values = {
	population = INITIAL_POPULATION,
	hunger = INITIAL_HUNGER,
	happiness = INITIAL_HAPPINESS,
	discipline = INITIAL_DISCIPLINE,
	training = INITIAL_TRAINING,
}
var meters_affect_population = {
	hunger = [-20, -10, 0, 20, 10],
	happiness = [10, 20, 30, 20, 10],
	discipline = [0, 0, 5, 10, 20],
}
var hand = []
var opponent_hand = []
const HAND_MAX_N_CARDS = 5

var traits = []
var day: int
var day_deck = []
var night_deck = []

var control_data = {
	values = values,
	population_modifiers = meters_affect_population,
	traits = traits,
	hand = hand,
	selected_card = selected_card,
	discard_pile = discard_pile,
	constant_cards = constant_cards
}

func _ready():
	reset_game()
	update_labels()

func reset_game():
	values = {
		population = INITIAL_POPULATION,
		hunger = INITIAL_HUNGER,
		happiness = INITIAL_HAPPINESS,
		discipline = INITIAL_DISCIPLINE,
		training = INITIAL_TRAINING,
	}
	day = 1
	day_deck = Cards.get_new_deck("day")
	night_deck = Cards.get_new_deck("night")

func update_labels():
	$Population.text = str(control_data.values.population)
	$Day.text = str(day)

func next_day(data):
	control_data = data
	apply_constant_card_effects()
	apply_population_modifiers(control_data)
	play_opponent_shift()
	day = day + 1
	update_scene()

func update_scene():
	update_labels()

func set_shift(shift):
	player_shift = shift
	control_data.player_shift = shift
	$PlayerShift.text = player_shift + " shift"
	opponent_shift = get_opponent_shift()
	$OpponentShift.text = opponent_shift + " shift"

func on_menu_pressed():
	emit_signal("menu_pressed")

func on_goto_control_pressed():
	var cards = Cards.draw_cards(HAND_MAX_N_CARDS - hand.size(), get_deck(player_shift))
	for card in cards:
		hand.append(card)
	emit_signal("goto_control_pressed", day, control_data)

func on_end_day_pressed():
	emit_signal("end_day_pressed")

func get_deck(shift):
	if shift == "day":
		return day_deck
	else:
		return night_deck

func get_opponent_shift():
	if player_shift == "day":
		return "night"
	else:
		return "day"

func apply_constant_card_effects():
	var cards = control_data.constant_cards
	for card in cards:
		if typeof(card.constant_effect) == TYPE_OBJECT:
			card.constant_effect.call_func(control_data.values, control_data.traits)

func apply_population_modifiers(data):
	var population = data.values.population
	var modifiers = data.population_modifiers
	for meter in data.values:
		if meter in modifiers:
			var meter_value = data.values[meter]
			if meter_value > 0 and meter_value <= 5:
				population = population + modifiers[meter][meter_value - 1]
	data.values.population = population

func test_card(card, data):
	var impact = 0
	
	var data_before = data.duplicate(true)
	
	if card.one_time_effect:
		if typeof(card.one_time_effect) == TYPE_OBJECT:
			card.one_time_effect.call_func(data.values, data.traits)
		elif typeof(card.one_time_effect) == TYPE_STRING:
			var regex = RegEx.new()
			regex.compile("(?<meter>\\w+): (?<op>[\\+\\-x])(?<value>\\d+);*")
			for result in regex.search_all(card.one_time_effect):
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

	if card.constant_effect:
		if typeof(card.constant_effect) == TYPE_OBJECT:
			card.constant_effect.call_func(data.values, data.traits)
		elif typeof(card.constant_effect) == TYPE_STRING:
			data.traits.append(card.constant_effect)
	apply_population_modifiers(data)

	var meters = [
		{ "meter": "population", "weight": 1 },
		{ "meter": "hunger", "weight": 1 },
		{ "meter": "happiness", "weight": 1 },
		{ "meter": "discipline", "weight": 1 },
		{ "meter": "training", "weight": 1 },
	]
	for config in meters:
		var diff = data[config.meter] - data_before[config.meter]
		var weighted_diff = diff * config.weight
		impact = impact + abs(diff)
	
	return impact

class CardSorter:
	static func sort_descending(a, b):
		if a.impact > b.impact:
			return true
		return false

func play_opponent_shift():
	var cards = Cards.draw_cards(HAND_MAX_N_CARDS - opponent_hand.size(), get_deck(opponent_shift))
	for card in cards:
		opponent_hand.append(card)

	# apply each card in test mode
	for card in opponent_hand:
		var data = control_data.duplicate(true)
		card.impact = test_card(card, data)

	# sort cards in the hand
	opponent_hand.sort_custom(CardSorter, "sort_descending")
	
	var selected_card = opponent_hand.pop_front()
	
	# discard 2 cards
	if opponent_hand.size() > 1: opponent_hand.pop_back()
	if opponent_hand.size() > 1: opponent_hand.pop_back()

	# the following actions happen at the end of player's turn
	# so only once, do not need to repeat it here
	# but Im going to keep it here for the balance in the Universe
#	apply_constant_card_effects()
#	apply_population_modifiers(control_data)
