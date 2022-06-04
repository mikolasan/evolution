extends Node2D

signal result_shown(player)

onready var hunger_texture: Texture = load("res://Assets/meter_hunger.png")
onready var happiness_texture: Texture = load("res://Assets/meter_happiness.png")
onready var discipline_texture: Texture = load("res://Assets/meter_discipline.png")
onready var training_texture: Texture = load("res://Assets/meter_training.png")
onready var population_texture: Texture = load("res://Assets/meter_population.png")

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
const MINUS_COLOR = Color("010000")

var data
var result_sequence = []
var shown: bool = false
var flashing_objects = []

func _ready():
	pass

func show_player(control_data):
	$StateMachinePlayer.set_trigger("player")
	$Card.hide()
	$OpponentPicture.hide()
	data = control_data
	update_scene(control_data, control_data.selected_card)

func update_scene(control_data, card):
	$Population.text = str(control_data.values.population)

	var traits = control_data.traits
	if traits.empty():
		$Traits.text = "<Nothing>"
	else:
		$Traits.text = PoolStringArray(traits).join("\n")
	
	$Card.set_card(0, card)
	
	var old_values = {}
	if card.one_time_effect:
		if typeof(card.one_time_effect) == TYPE_OBJECT:
			if not ("one_time_effect_meter" in card):
				return
				
			result_sequence.append({
				"type": "One time card effect",
				"meter_label_text": card.one_time_effect_meter,
				"meter_change_text": card.one_time_effect_description,
				"impact": card.one_time_effect_impact,
			})
		elif typeof(card.one_time_effect) == TYPE_STRING:
			var regex = RegEx.new()
			regex.compile("(?<meter>\\w+): (?<op>[\\+\\-x])(?<value>\\d+);*")
			for result in regex.search_all(card.one_time_effect):
				var meter = result.get_string("meter")
				var op = result.get_string("op")
				var v = result.get_string("value")
				var impact
				var new_value = data.values[meter]
				var old_value
				match op:
					"+":
						impact = "positive"
						old_value = new_value - int(v)
					"-":
						impact = "negative"
						old_value = new_value + int(v)
					"x":
						impact = "positive"
						old_value = new_value / int(v)
				old_values[meter] = old_value
				result_sequence.append({
					"type": "One time card effect",
					"meter_label_text": meter,
					"meter_change_text": op + v,
					"impact": impact,
				})

	if card.constant_effect:
		if typeof(card.constant_effect) == TYPE_OBJECT:
			result_sequence.append({
				"type": "Constant effects",
				"meter_label_text": card.constant_effect_meter,
				"meter_change_text": card.constant_effect_description,
				"impact": card.constant_effect_impact,
			})
	
	var values = control_data.values
	$Tween.remove_all()
	for meter in ["hunger", "happiness", "discipline", "training"]:
		var old_value = old_values[meter] if meter in old_values else null
		update_scale(meter, old_value, values[meter])
	$Tween.start()
	
	var population_modifiers = control_data.population_modifiers
	for meter in ["hunger", "happiness", "discipline"]:
		update_modifiers(meter, population_modifiers[meter], values[meter])
		var diff = population_modifiers[meter][values[meter] - 1]
		if diff == 0: continue
		result_sequence.append({
			"type": "Population update based on score",
			"meter_label_text": "population",
			"meter_change_text": str(diff),
			"impact": "positive" if diff > 0 else "negative",
		})
	
	start_sequence()

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

func update_scale(scale_name, value, new_value):
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
		var tile_id = i + 1
		var tile = scale.get_node(str(tile_id))
		tile.color = scale_colors[i] if new_value >= tile_id else OFF_COLOR
		if not value: continue
		#printt("update scale", scale_name, value, new_value)
		if ((new_value > value and tile_id > value and tile_id <= new_value)
				or (new_value < value and tile_id > new_value and tile_id <= value)):
			#print("Animate " + tile.get_path())
			if new_value < value:
				tile.color = MINUS_COLOR
#			flashing_objects.append(tile)
			var ret = $Tween.interpolate_property(
				tile,
				"modulate:a",
				1.0,
				0.0,
				1,
				Tween.TRANS_BOUNCE,
				Tween.EASE_IN_OUT
			)

func show_opponent(control_data):
	$StateMachinePlayer.set_trigger("opponent")
	$AnimationPlayer.play("Show opponent")
	update_scene(control_data, control_data.opponent_card)

func set_positive_impact():
	$Particles.gravity = Vector2(0, -98)
	$Particles.direction = Vector2(0, -1)

func set_negative_impact():
	$Particles.gravity = Vector2(0, 98)
	$Particles.direction = Vector2(0, 1)

func set_meter(meter):
	match meter:
		"hunger":
			$Particles.texture = hunger_texture
		"happiness":
			$Particles.texture = happiness_texture
		"discipline":
			$Particles.texture = discipline_texture
		"training":
			$Particles.texture = training_texture
		"population":
			$Particles.texture = population_texture

func start_sequence():
	if result_sequence.empty():
		if $StateMachinePlayer.get_current() == "Player":
			$Tween.stop_all()
			$Tween.reset_all()
#			for obj in flashing_objects:
#				obj.modulate = Color("ffffffff")
#			flashing_objects = []
			emit_signal("result_shown", "player")
			shown = true
		else:
			$Tween.stop_all()
			$Tween.reset_all()
#			for obj in flashing_objects:
#				obj.modulate = Color("ffffffff")
#			flashing_objects = []
			emit_signal("result_shown", "opponent")
		return
	
	var result = result_sequence.pop_front()
	set_meter(result.meter_label_text)
	if result.impact == "positive":
		set_positive_impact()
	else:
		set_negative_impact()
	$Title.text = result.type
	$MeterLabel.text = result.meter_label_text
	$MeterChange.text = result.meter_change_text
	
	$SequenceTimer.start(2)

func on_timer_timeout():
	start_sequence()

func transition_to_next_day():
	shown = false

func on_tween_step(object, key, elapsed, value):
	pass
#	printt(elapsed, value)

func show_opponent_card():
	print("open_card")
	$Card.open_card()

func hide_opponent_card():
	print("close_card")
	$Card.close_card()
