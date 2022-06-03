extends Node2D

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

var data
var result_sequence = []
var shown: bool = false

func _ready():
	pass

func update_scene(control_data):
	data = control_data
	
	var values = control_data.values
	$Population.text = str(values.population)

	var traits = control_data.traits
	if traits.empty():
		$Traits.text = "<Nothing>"
	else:
		$Traits.text = PoolStringArray(traits).join("\n")
	
	$Card.set_card(0, control_data.selected_card)
	
	if control_data.selected_card.one_time_effect:
		if typeof(control_data.selected_card.one_time_effect) == TYPE_OBJECT:
			if not ("one_time_effect_meter" in control_data.selected_card):
				return
				
			result_sequence.append({
				"type": "One time card effect",
				"meter_label_text": control_data.selected_card.one_time_effect_meter,
				"meter_change_text": control_data.selected_card.one_time_effect_description,
				"impact": control_data.selected_card.one_time_effect_impact,
			})
		elif typeof(control_data.selected_card.one_time_effect) == TYPE_STRING:
			var regex = RegEx.new()
			regex.compile("(?<meter>\\w+): (?<op>[\\+\\-x])(?<value>\\d+);*")
			for result in regex.search_all(control_data.selected_card.one_time_effect):
				var meter = result.get_string("meter")
#				$MeterLabel.text = meter
				var op = result.get_string("op")
				var v = result.get_string("value")
#				$MeterChange.text = op + v
				var impact
				match op:
					"+":
						impact = "positive"
					"-":
						impact = "negative"
					"x":
						impact = "positive"
				result_sequence.append({
					"type": "One time card effect",
					"meter_label_text": meter,
					"meter_change_text": op + v,
					"impact": impact,
				})

	if control_data.selected_card.constant_effect:
		if typeof(control_data.selected_card.constant_effect) == TYPE_OBJECT:
			result_sequence.append({
				"type": "One time card effect",
				"meter_label_text": control_data.selected_card.constant_effect_meter,
				"meter_change_text": control_data.selected_card.constant_effect_description,
				"impact": control_data.selected_card.constant_effect_impact,
			})
			
	for meter in ["hunger", "happiness", "discipline", "training"]:
		update_scale(meter, values[meter])
		
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
		shown = true
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
	
	$Timer.start(2)

func on_timer_timeout():
	start_sequence()

func transition_to_next_day():
	shown = false
