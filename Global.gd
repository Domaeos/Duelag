extends Node

var poisoned_colour = Color(0.3, 0.68, 0.22)
var health_colour = Color(0.912, 0.099, 0.225)
var grid_size = 2.0

var spelldictionary = {
	"lightning" : {
		"words_of_power": "An Ort Grav",
		"duration": 1.0,
		"damage": 5,
		"cost": 15,
		"position": Vector3(0.4, 4.5, 1.0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_1"
	},
	"greater_heal": {
		"words_of_power": "In Vas Mani",
		"duration": 1.0,
		"damage": -25,
		"cost": 15,
		"position": Vector3(0, 0, 0),
		"scale": Vector3(0.5,0.5, 0.5),
		"animation": "mystery_2",
		"self": true,
	},
	"cure" : {
		"words_of_power": "An Nox",
		"duration": 0.5,
		"damage": 0,
		"cost": 5,
		"position": Vector3(0, 0, 0),
		"scale": Vector3(0.5, 0.5, 0.5),
		"animation": "mystery_3",
		"self": true,
	},
	"flamestrike" : {
		"words_of_power": "Kal Vas Flam",
		"duration": 0.5,
		"damage": 30,
		"cost": 30,
		"position": Vector3(-0.5, 2, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "fire_1"
	},
	"poison" : {
		"words_of_power": "In Nox",
		"duration": 1.0,
		"damage": 0,
		"cost": 10,
		"scale": Vector3(1, 1, 1),
		"position": Vector3(0, 2.0, 0),
		"animation": "smoke_3"
	},
	"spark": {
		"words_of_power": "Smoking",
		"duration": 1.0,
		"damage": 20,
		"cost": 15,
		"position": Vector3(0, 2.0, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_4"
	}
}
