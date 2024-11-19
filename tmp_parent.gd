extends Node3D

func _ready():
	var mesh_instance = $cliff_block_rock # Replace with the actual path to your mesh node
	if mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		print("AABB Size: ", aabb.size)
		print("AABB Position: ", aabb.position)
	else:
		print("No mesh found.")
