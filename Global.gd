extends Node

var poisoned_colour = Color(0.3, 0.68, 0.22)

var health_colour = Color(0.912, 0.099, 0.225)

var spelldictionary = {
	"lightning" : {
		"words_of_power": "Zap zap",
		"duration": 1.0,
		"damage": 5,
		"position": Vector3(0.4, 4.5, 1.0),
		"animation": "electric_1"
	},
	"flamestrike" : {
		"words_of_power": "Kal Vas Flam",
		"duration": 0.5,
		"damage": 5,
		"position": Vector3(-0.5, 2, 0),
		"animation": "fire_1"
	},
	"poison" : {
		"words_of_power": "In Nox",
		"duration": 1.0,
		"damage": 0,
		"position": Vector3(0, 2.0, 0),
		"animation": "smoke_3"
	},
	"spark": {
		"words_of_power": "Smoking",
		"duration": 1.0,
		"damage": 20,
		"position": Vector3(0, 2.0, 0),
		"animation": "electric_4"
	}
}
