extends Node3D

@export var grid_size: float = 2.0  # Size of each grid cell
@export var grid_extent: int = 10  # How far the grid extends in each direction
@export var grid_color: Color = Color(0.2, 0.8, 0.2, 0.8)  # Grid line color
@export var line_thickness: float = 0.05  # Thickness of grid lines

var line_material: StandardMaterial3D

func _ready():
	# Create a line material
	line_material = StandardMaterial3D.new()
	line_material.albedo_color = grid_color
	line_material.unshaded = true

	# Generate the grid lines
	_draw_grid()

func _draw_grid():
	var mesh = ImmediateMesh.new()

	# Add grid lines on the XZ plane
	mesh.surface_begin(Mesh.PRIMITIVE_LINES, line_material)
	for x in range(-grid_extent, grid_extent + 1):
		# Vertical lines (along Z-axis)
		mesh.surface_add_vertex(Vector3(x * grid_size, 0, -grid_extent * grid_size))
		mesh.surface_add_vertex(Vector3(x * grid_size, 0, grid_extent * grid_size))

	for z in range(-grid_extent, grid_extent + 1):
		# Horizontal lines (along X-axis)
		mesh.surface_add_vertex(Vector3(-grid_extent * grid_size, 0, z * grid_size))
		mesh.surface_add_vertex(Vector3(grid_extent * grid_size, 0, z * grid_size))
	mesh.surface_end()

	# Add the mesh instance to the scene
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = line_material
	add_child(mesh_instance)
