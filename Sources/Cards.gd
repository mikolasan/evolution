extends Node

func double_population(values, traits):
	values.population = values.population * 2

func greenhouse_effect_func(values, traits):
	if values.hunger <= 1:
		values.hunger = values.hunger + 1

func chloroplast_func(values, traits):
	values.hunger = values.hunger + 2

func herbivore_func(values, traits):
	values.hunger = values.hunger + 1

func frugivore_func(values, traits):
	values.hunger = values.hunger + 1
	values.happiness = values.happiness + 1

func predator_func(values, traits):
	values.hunger = values.hunger + 2

func mimicry_func(values, traits):
	values.population = values.population + 10

func camouflage_func(values, traits):
	values.population = values.population + 10


var day_shift = [
	{
		"title":"Hermaphroditism",
		"trait": "reproduction",
		"type": " ",
		"description": "Population is not affected if Distress card targets only one gender",
		"constant": true,
	},

	{
		"title":"Androdioecy (Hermaphroditism)",
		"trait": "reproduction",
		"type": " ",
		"description": "Population is not affected if Distress card targets only one gender. Instant effect: double the population",
		"constant": true,
		"effect": funcref(self, "double_population"),
	},

	{
		"title":"Gynodioecy (Hermaphroditism)",
		"trait": "reproduction",
		"type": " ",
		"description": "Population is not affected if Distress card targets only one gender. Instant effect: double the population",
		"constant": true,
		"effect": funcref(self, "double_population"),
	},

	{
		"title":"Trioecy (Hermaphroditism)",
		"trait": "reproduction",
		"type": " ",
		"description": "Population is not affected if Distress card targets only one gender. Instant effect: double the population",
		"constant": true,
		"effect": funcref(self, "double_population"),
	},

	{
		"title":"Fragmentation",
		"trait": "reproduction",
		"type": " ",
		"description": "Vulnerable to changing environments, parasites",
		"constant": true,
	},

	{
		"title":"Gills",
		"trait": "breath",
		"type": "dna",
		"description": "Breathe underwater, always covered with moist on the ground",
		"constant": true,
	},

	{
		"title":"Cutaneous respiration",
		"trait": "breath",
		"type": "dna",
		"description": "Breathe with skin, no lungs. Thin skin",
		"constant": true,
	},

	{
		"title":"Lungs",
		"trait": "breath",
		"type": "dna",
		"description": "Breathe with oxygen",
		"constant": true,
	},

	{
		"title":"Immune response",
		"trait": "immune",
		"type": "dna",
		"description": "Viruses has no affect",
		"constant": true,
	},

	{
		"title":"Greenhouse effect",
		"trait": " ",
		"type": "planet",
		"description": "+1 hunger if it equals 1 or less. Constant",
		"constant": true,
		"effect": funcref(self, "greenhouse_effect_func"),
	},

	{
		"title":"Chloroplast (Photosynthesis)",
		"trait": "nutrition",
		"type": "class definitive",
		"description": "Convert light into chemical energy. +2 hunger",
		"constant": false,
		"effect": funcref(self, "chloroplast_func"),
	},

	{
		"title":"Go ashore",
		"trait": " ",
		"type": "class definitive",
		"description": "Leave water and live on the ground",
		"constant": true,
	},

	{
		"title":"Herd instinct",
		"trait": " ",
		"type": " ",
		"description": "Live together (forest)",
		"constant": true,
	},

	{
		"title":"Herbivore",
		"trait": " ",
		"type": " ",
		"description": "Eat plants +1 Hunger",
		"constant": false,
		"effect": funcref(self, "herbivore_func"),
	},

	{
		"title":"Frugivore",
		"trait": " ",
		"type": " ",
		"description": "Eat fruits +1 Hunger, +1 Happiness",
		"constant": false,
		"effect": funcref(self, "frugivore_func"),
	},

	{
		"title":"Xylophagous",
		"trait": " ",
		"type": " ",
		"description": " ",
		"constant": true,
	},

	{
		"title":"Predator",
		"trait": " ",
		"type": " ",
		"description": "Eat other animals, scavenging sometimes, +2 Hunger",
		"constant": false,
		"effect": funcref(self, "predator_func"),
	},

	{
		"title":"Mimicry",
		"trait": " ",
		"type": " ",
		"description": "Antipredator adaptation. +10 population",
		"constant": false,
		"effect": funcref(self, "mimicry_func"),
	},

	{
		"title":"Camouflage",
		"trait": " ",
		"type": " ",
		"description": "Antipredator adaptation. +10 population",
		"constant": false,
		"effect": funcref(self, "camouflage_func"),
	},

	{
		"title":"Spine",
		"trait": "locomotion",
		"type": "class definitive",
		"description": " ",
		"constant": true,
	},

	{
		"title":"Thorns",
		"trait": " ",
		"type": "deterrent",
		"description": "Population protected from predators",
		"constant": true,
	},

	{
		"title":"Seeds/eggs/spores",
		"trait": "reproduction",
		"type": "",
		"description": "",
		"constant": true,
	}
]


func asteroid_func(values, traits):
	values.population = values.population - 10
	values.hunger = values.hunger - 2

func plague_func(values, traits):
	if not ('lungs' in traits):
		return
	if values.population <= 10:
		values.population = 1
	else:
		values.population = 10

func ice_age_func(values, traits):
	values.hunger = values.hunger - 2
	if 'giant' in traits:
		values.population = 0

func henatophagy_func(values, traits):
	values.hunger = values.hunger - 1

func appulse_func(values, traits):
	values.discipline = values.discipline  - 2

func giant_func(values, traits):
	values.hunger = values.hunger - 1
	traits.append("giant")

func parasites_func(values, traits):
	values.hunger = values.hunger - 1

func global_warming(values, traits):
	values.happiness = values.happiness - 1

func heterotrophism_func(values, traits):
	values.hunger = values.hunger - 1

func global_flood_func(values, traits):
	values.happiness = values.happiness - 1
	values.discipline = values.discipline  - 1

var night_shift = [
	{
		"title":"Asteroid",
		"trait": "",
		"type": "Distress",
		"description": "-10 population -2 hunger",
		"constant": false,
		"effect": funcref(self, "asteroid_func"),
	},

	{
		"title":"Virus",
		"trait": "immune",
		"type": " ",
		"description": " ",
		"constant": false,
	},

	{
		"title":"Plague",
		"trait": "breath",
		"type": " ",
		"description": "Population becomes 10 or 1 if current population was 10. Not affecting if population has no lungs",
		"constant": false,
		"effect": funcref(self, "plague_func"),
	},

	{
		"title":"Ice Age",
		"trait": "locomotion",
		"type": " ",
		"description": "Giants die, -2 hunger",
		"constant": false,
		"effect": funcref(self, "ice_age_func"),
	},

	{
		"title":"Hematophagy",
		"trait": "nutrition",
		"type": "dna",
		"description": "Vampire trait - has to consume blood to feed their hunger. Hunger -1 on every day",
		"constant": true,
		"effect": funcref(self, "henatophagy_func"),
	},

	{
		"title":"Genetic recombination",
		"trait": "immune",
		"type": "dna",
		"description": " ",
		"constant": true,
	},

	{
		"title":"Appulse (Parade of the planets)",
		"trait": " ",
		"type": " ",
		"description": "Once in a million years Mercury, Venus, Mars, Jupiter and Saturn all lined up in Space which causes a gravitational effect equal to influence of x10 Moons. Discipline -2",
		"constant": false,
		"effect": funcref(self, "appulse_func"),
	},

	{
		"title":"Giant",
		"trait": "locomotion",
		"type": "dna",
		"description": "Slow, but mighty -1 hunger ",
		"constant": true,
		"effect": funcref(self, "giant_func"),
	},

	{
		"title":"Parasites",
		"trait": "nutrition",
		"type": " ",
		"description": "-1 hunger",
		"constant": false,
		"effect": funcref(self, "parasites_func"),
	},

	{
		"title":"Global warming",
		"trait": " ",
		"type": " ",
		"description": "-1 happiness",
		"constant": true,
		"effect": funcref(self, "global_warming_func"),
	},

	{
		"title":"Heterotrophism",
		"trait": "nutrition",
		"type": " ",
		"description": "Cannot produce nutrition by itself, must consume plants or animals. -1 hunger",
		"constant": false,
		"effect": funcref(self, "heterotrophism_func"),
	},

	{
		"title":"Global flood",
		"trait": "",
		"type": "",
		"description": "-1 happiness, -1 discipline",
		"constant": false,
		"effect": funcref(self, "global_flood_func"),
	},

]

func _ready():
	pass
