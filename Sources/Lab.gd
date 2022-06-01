extends Node2D

signal menu_pressed
signal goto_control_pressed(day, control_data)
signal end_day_pressed

var player_shift: String
var ai_shift: String
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
	day = day + 1
	
	update_scene()

func update_scene():
	update_labels()

func set_shift(shift):
	player_shift = shift
	control_data.player_shift = shift
	$PlayerShift.text = player_shift + " shift"
	ai_shift = get_opponent_shift()
	$OpponentShift.text = ai_shift + " shift"

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
