extends Node

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func greenhouse_effect_func(values, traits):
	if values.hunger <= 1:
		values.hunger = values.hunger + 1

var day_shift = [
	{
		"title":"Hermaphroditism",
		"type": "Reproduction",
		"description": "Population is not affected if Distress card targets only one gender",
		"one_time_effect": "training: +1; population: +10",
		"constant_effect": "hermaphroditism",
	},

	{
		"title":"Androdioecy",
		"type": "Reproduction",
		"description": "Version of hermaphroditism. Population is not affected if Distress card targets only one gender",
		"one_time_effect": "training: +1; population: +10",
		"constant_effect": "hermaphroditism",
	},

	{
		"title":"Gynodioecy",
		"type": "Reproduction",
		"description": "Version of hermaphroditism. Population is not affected if Distress card targets only one gender",
		"one_time_effect": "training: +1; population: +10",
		"constant_effect": "hermaphroditism",
	},

	{
		"title":"Trioecy",
		"type": "Reproduction",
		"description": "Version of hermaphroditism. Population is not affected if Distress card targets only one gender",
		"one_time_effect": "training: +1; population: +10",
		"constant_effect": "hermaphroditism",
	},

	{
		"title":"Fragmentation",
		"type": "Reproduction",
		"description": "Vulnerable to changing environments, parasites",
		"one_time_effect": "training: +1; population: +10",
		"constant_effect": "fragmentation",
	},

	{
		"title":"Gills",
		"type": "Breath",
		"description": "Breathe underwater, always covered with moist on the ground",
		"one_time_effect": "training: +1",
		"constant_effect": "gills",
	},

	{
		"title":"Skin Breathing",
		"type": "Breath",
		"description": "Cutaneous respiration which is breathe with skin, so simply speaking no lungs involved",
		"one_time_effect": "training: +1",
		"constant_effect": "thin skin",
	},

	{
		"title":"Lungs",
		"type": "Breath",
		"description": "Breathe with oxygen",
		"one_time_effect": "training: +1",
		"constant_effect": "lungs",
	},

	{
		"title":"Immune response",
		"type": "Immune",
		"description": "Viruses has no affect",
		"one_time_effect": "happiness: +1; discipline +1",
		"constant_effect": "immune",
	},

	{
		"title":"Greenhouse effect",
		"type": "Environment Impact",
		"description": "+1 hunger if it equals 1 or less. Constant",
		"one_time_effect": null,
		"constant_effect": funcref(self, "greenhouse_effect_func"),
		"constant_effect_description": "+1 hunger if it equals 1 or less",
		"constant_effect_meter": "hunger",
		"constant_effect_impact": "positive",
	},

	{
		"title":"Photosynthesis",
		"type": "Nutrition",
		"description": "Chloroplast. Convert light into chemical energy. +2 hunger",
		"one_time_effect": "hunger: +2",
		"constant_effect": null,
	},

	{
		"title":"Terrestial",
		"type": "Locomotion",
		"description": "Leave water and live on the ground",
		"one_time_effect": "training: +1",
		"constant_effect": "terrestial",
	},

	{
		"title":"Herding",
		"type": "Trait",
		"description": "Live together (forest)",
		"one_time_effect": "discipline: +2",
		"constant_effect": null,
	},

	{
		"title":"Herbivore",
		"type": "Nutrition",
		"description": "Eat plants +1 Hunger",
		"one_time_effect": "hunger: +1",
		"constant_effect": null,
	},

	{
		"title":"Frugivore",
		"type": "Nutrition",
		"description": "Eat fruits",
		"one_time_effect": "hunger: +1; happiness: +1",
		"constant_effect": null,
	},

	{
		"title":"Xylophagous",
		"type": "Nutrition",
		"description": "Diet consists of wood",
		"one_time_effect": "hunger: +3",
		"constant_effect": "xylophagous",
	},

	{
		"title":"Predator",
		"type": "Nutrition",
		"description": "Eat other animals, scavenging sometimes, +2 Hunger",
		"one_time_effect": "hunger: +2",
		"constant_effect": null,
	},

	{
		"title":"Mimicry",
		"type": "Deterrent",
		"description": "Antipredator adaptation. +10 population",
		"one_time_effect": "discipline: +1; population: +10",
		"constant_effect": null,
	},

	{
		"title":"Camouflage",
		"type": "Deterrent",
		"description": "Antipredator adaptation. +10 population",
		"one_time_effect": "discipline: +1; population: +10",
		"constant_effect": null,
	},

	{
		"title":"Spine",
		"type": "Locomotion",
		"description": "The population grew a backbone or possibly spinal column",
		"one_time_effect": "training: +1",
		"constant_effect": "vertebrate",
	},

	{
		"title":"Thorns",
		"type": "Deterrent",
		"description": "Population protected from predators",
		"one_time_effect": "discipline: +2",
		"constant_effect": "deterrent",
	},

	{
		"title":"Spores",
		"type": "Reproduction",
		"description": "Seeds/eggs/spores whichever applies to the current spices",
		"one_time_effect": "training: +1",
		"constant_effect": null,
	}
]

func virus_func(values, traits):
	if "immune" in traits: return
	if traits.empty(): return
	
	var k = rng.randi_range(0, traits.size() - 1)
	traits.pop_at(k)

func plague_func(values, traits):
	if not ('lungs' in traits):
		return
	if values.population <= 10:
		values.population = 1
	else:
		values.population = 10
	values.happiness = values.happiness - 2

func hematophagy_func(values, traits):
	values.hunger = values.hunger - 1

func genetic_recombination_func(values, traits):
	var new_traits = ["fluorescent", "infertile", "immortal", "hairy", "Benjamin Button"]
	var k = rng.randi_range(0, new_traits.size() - 1)
	var new_trait = new_traits[k]
	traits.append(new_trait)

var night_shift = [
	{
		"title":"Asteroid",
		"type": "Environment Impact",
		"description": "Someone got hurt. Dust everywhere in the air, now it's harder to find food",
		"one_time_effect": "population: -20; hunger: -2",
		"constant_effect": null,
	},

	{
		"title":"Virus",
		"type": "Immune",
		"description": "Virus incorporates its DNA into the host system and alters it. Randomly remove one trait. Does nothing if the population is immune",
		"one_time_effect": funcref(self, "virus_func"),
		"constant_effect": null,
	},

	{
		"title":"Plague",
		"type": "Breath",
		"description": "Population becomes 10 or 1 if current population was 10. Not affecting if population has no lungs",
		"one_time_effect": funcref(self, "plague_func"),
		"constant_effect": null,
		"one_time_effect_description": "Population becomes 10 or 1 if current population was 10",
		"one_time_effect_meter": "population",
		"one_time_effect_impact": "negative",
	},

	{
		"title":"Ice Age",
		"type": "Environment Impact",
		"description": "Cold weather is no joke. Population decreases by 20, hunger grows",
		"one_time_effect": "hunger: -2, population: -20",
		"constant_effect": null,
	},

	{
		"title":"Hematophagy",
		"type": "Nutrition",
		"description": "Vampire trait - has to consume blood to feed their hunger. Hunger -1 on every day",
		"one_time_effect": "happiness: +2",
		"constant_effect": funcref(self, "hematophagy_func"),
		"constant_effect_description": "Hunger -1 on every day",
		"constant_effect_meter": "hunger",
		"constant_effect_impact": "negative",
	},

	{
		"title":"GMO",
		"type": "Interference",
		"description": "Genetic recombination. It's time to apply extracurricular DNA samples of pink hair and scaly tail",
		"one_time_effect": funcref(self, "genetic_recombination_func"),
		"constant_effect": null,
	},

	{
		"title":"Appulse",
		"type": "Environment Impact",
		"description": "Parade of the planets. Once in a million years Mercury, Venus, Mars, Jupiter and Saturn all lined up in Space which causes a gravitational effect equal to influence of x10 Moons. Discipline -2",
		"one_time_effect": "discipline: -3",
		"constant_effect": null,
	},

	{
		"title":"Giants",
		"type": "Locomotion",
		"description": "Slow, but mighty",
		"one_time_effect": "hunger: -1",
		"constant_effect": "giants",
	},

	{
		"title":"Parasites",
		"type": "Nutrition",
		"description": "They make you to eat more",
		"one_time_effect": "hunger: -2",
		"constant_effect": null,
	},

	{
		"title":"Global warming",
		"type": "Environment Impact",
		"description": "You are a small worm on this planet, how are you going to change climate alone? It's depressing",
		"one_time_effect": "happiness: -3",
		"constant_effect": null,
	},

	{
		"title":"Heterotrophism",
		"type": "Nutrition",
		"description": "Cannot produce nutrition by itself, must consume plants or animals",
		"one_time_effect": "hunger: -1",
		"constant_effect": null,
	},

	{
		"title":"Global flood",
		"type": "Environment Impact",
		"description": "You jump on a boat, but after that you are in the new place without old friends",
		"one_time_effect": "happiness: -1; discipline: -1",
		"constant_effect": null,
	},
	
	# copy of the deck (1)
#	{
#		"title":"Asteroid",
#		"type": "Environment Impact",
#		"description": "Someone got hurt. Dust everywhere in the air, now it's harder to find food",
#		"one_time_effect": "population: -20; hunger: -2",
#		"constant_effect": null,
#	},

	{
		"title":"Virus",
		"type": "Immune",
		"description": "Virus incorporates its DNA into the host system and alters it. Randomly remove one trait. Does nothing if the population is immune",
		"one_time_effect": funcref(self, "virus_func"),
		"constant_effect": null,
	},

	{
		"title":"Plague",
		"type": "Breath",
		"description": "Population becomes 10 or 1 if current population was 10. Not affecting if population has no lungs",
		"one_time_effect": funcref(self, "plague_func"),
		"constant_effect": null,
		"one_time_effect_description": "Population becomes 10 or 1 if current population was 10",
		"one_time_effect_meter": "population",
		"one_time_effect_impact": "negative",
	},

	{
		"title":"Ice Age",
		"type": "Environment Impact",
		"description": "Cold weather is no joke. Population decreases by 20, hunger grows",
		"one_time_effect": "hunger: -2, population: -20",
		"constant_effect": null,
	},

	{
		"title":"Hematophagy",
		"type": "Nutrition",
		"description": "Vampire trait - has to consume blood to feed their hunger. Hunger -1 on every day",
		"one_time_effect": "happiness: +2",
		"constant_effect": funcref(self, "hematophagy_func"),
		"constant_effect_description": "Hunger -1 on every day",
		"constant_effect_meter": "hunger",
		"constant_effect_impact": "negative",
	},

	{
		"title":"GMO",
		"type": "Interference",
		"description": "Genetic recombination. It's time to apply extracurricular DNA samples of pink hair and scaly tail",
		"one_time_effect": funcref(self, "genetic_recombination_func"),
		"constant_effect": null,
	},

	{
		"title":"Appulse",
		"type": "Environment Impact",
		"description": "Parade of the planets. Once in a million years Mercury, Venus, Mars, Jupiter and Saturn all lined up in Space which causes a gravitational effect equal to influence of x10 Moons. Discipline -2",
		"one_time_effect": "discipline: -3",
		"constant_effect": null,
	},

	{
		"title":"Giants",
		"type": "Locomotion",
		"description": "Slow, but mighty",
		"one_time_effect": "hunger: -1",
		"constant_effect": "giants",
	},

	{
		"title":"Parasites",
		"type": "Nutrition",
		"description": "They make you to eat more",
		"one_time_effect": "hunger: -2",
		"constant_effect": null,
	},

	{
		"title":"Global warming",
		"type": "Environment Impact",
		"description": "You are a small worm on this planet, how are you going to change climate alone? It's depressing",
		"one_time_effect": "happiness: -3",
		"constant_effect": null,
	},

	{
		"title":"Heterotrophism",
		"type": "Nutrition",
		"description": "Cannot produce nutrition by itself, must consume plants or animals",
		"one_time_effect": "hunger: -1",
		"constant_effect": null,
	},

	{
		"title":"Global flood",
		"type": "Environment Impact",
		"description": "You jump on a boat, but after that you are in the new place without old friends",
		"one_time_effect": "happiness: -1; discipline: -1",
		"constant_effect": null,
	},
	
	# copy of the deck (2)
#
#	{
#		"title":"Asteroid",
#		"type": "Environment Impact",
#		"description": "Someone got hurt. Dust everywhere in the air, now it's harder to find food",
#		"one_time_effect": "population: -20; hunger: -2",
#		"constant_effect": null,
#	},

	{
		"title":"Virus",
		"type": "Immune",
		"description": "Virus incorporates its DNA into the host system and alters it. Randomly remove one trait. Does nothing if the population is immune",
		"one_time_effect": funcref(self, "virus_func"),
		"constant_effect": null,
	},

	{
		"title":"Plague",
		"type": "Breath",
		"description": "Population becomes 10 or 1 if current population was 10. Not affecting if population has no lungs",
		"one_time_effect": funcref(self, "plague_func"),
		"constant_effect": null,
		"one_time_effect_description": "Population becomes 10 or 1 if current population was 10",
		"one_time_effect_meter": "population",
		"one_time_effect_impact": "negative",
	},

	{
		"title":"Ice Age",
		"type": "Environment Impact",
		"description": "Cold weather is no joke. Population decreases by 20, hunger grows",
		"one_time_effect": "hunger: -2, population: -20",
		"constant_effect": null,
	},

	{
		"title":"Hematophagy",
		"type": "Nutrition",
		"description": "Vampire trait - has to consume blood to feed their hunger. Hunger -1 on every day",
		"one_time_effect": "happiness: +2",
		"constant_effect": funcref(self, "hematophagy_func"),
		"constant_effect_description": "Hunger -1 on every day",
		"constant_effect_meter": "hunger",
		"constant_effect_impact": "negative",
	},

	{
		"title":"GMO",
		"type": "Interference",
		"description": "Genetic recombination. It's time to apply extracurricular DNA samples of pink hair and scaly tail",
		"one_time_effect": funcref(self, "genetic_recombination_func"),
		"constant_effect": null,
	},

	{
		"title":"Appulse",
		"type": "Environment Impact",
		"description": "Parade of the planets. Once in a million years Mercury, Venus, Mars, Jupiter and Saturn all lined up in Space which causes a gravitational effect equal to influence of x10 Moons. Discipline -2",
		"one_time_effect": "discipline: -3",
		"constant_effect": null,
	},

	{
		"title":"Giants",
		"type": "Locomotion",
		"description": "Slow, but mighty",
		"one_time_effect": "hunger: -1",
		"constant_effect": "giants",
	},

	{
		"title":"Parasites",
		"type": "Nutrition",
		"description": "They make you to eat more",
		"one_time_effect": "hunger: -2",
		"constant_effect": null,
	},

	{
		"title":"Global warming",
		"type": "Environment Impact",
		"description": "You are a small worm on this planet, how are you going to change climate alone? It's depressing",
		"one_time_effect": "happiness: -3",
		"constant_effect": null,
	},

	{
		"title":"Heterotrophism",
		"type": "Nutrition",
		"description": "Cannot produce nutrition by itself, must consume plants or animals",
		"one_time_effect": "hunger: -1",
		"constant_effect": null,
	},

	{
		"title":"Global flood",
		"type": "Environment Impact",
		"description": "You jump on a boat, but after that you are in the new place without old friends",
		"one_time_effect": "happiness: -1; discipline: -1",
		"constant_effect": null,
	},

]

func get_new_deck(shift):
	var deck = day_shift if shift == "day" else night_shift
	return deck.duplicate(true)

func draw_cards(n, deck):
	if deck.size() < n:
		push_error("the deck is small")
		return []

	var hand = []
	for i in range(n):
		var k = rng.randi_range(0, deck.size() - 1)
		var card = deck.pop_at(k)
		hand.append(card)
	return hand


