extends Node3D

signal spawned(spawnling)
@export var spawn_scene: PackedScene

func spawn(reference = spawn_scene):
	var spawnling = reference.instantiate()
	add_child(spawnling, true)
	spawnling.position = position
	spawned.emit(spawnling)
	return spawnling
