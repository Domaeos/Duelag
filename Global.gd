extends Node

const API_ADDR = "http://127.0.0.1:8000/"
const SAVE_PATH = "user://account_data.dat" 

var grid_size = 2.0
var my_player: CharacterBody3D
	
var active_players = {
	
}

var account

var spelldictionary = {
	"fizzle" : {
		"words_of_power": "El Zappo",
		"duration": 0.5,
		"damage": 1,
		"cost": 5,
		"position": Vector3(0, 4.5, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_1",
	},
	"shield" : {
		"words_of_power": "shield",
		"duration": 0.5,
		"damage": 1,
		"cost": 5,
		"position": Vector3(0, 4.5, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_2",
		"self": true,
	},
	"lightning" : {
		"words_of_power": "An Ort Grav",
		"duration": 1.5,
		"damage": 120,
		"cost": 15,
		"position": Vector3(0, 4.5, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_1"
	},
	"greater_heal": {
		"words_of_power": "In Vas Mani",
		"duration": 3.0,
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
		"duration": 3.5,
		"damage": 30,
		"cost": 22,
		"position": Vector3(-0.5, 2, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "fire_1"
	},
	"poison" : {
		"words_of_power": "In Nox",
		"duration": 1.2,
		"damage": 0,
		"cost": 10,
		"scale": Vector3(1, 1, 1),
		"position": Vector3(0, 2.0, 0),
		"animation": "smoke_3"
	},
	"spark": {
		"words_of_power": "Scintilla",
		"duration": 2.5,
		"damage": 20,
		"cost": 15,
		"position": Vector3(0, 2.0, 0),
		"scale": Vector3(1, 1, 1),
		"animation": "electric_4"
	}
}
