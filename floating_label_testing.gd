extends Node3D

var active_message = {}
@onready var message_container = $Rogue/CharacterText/SubViewport/Container
var array_test = [
	"Hello", "Kal Vas Flam", "Brap brap"
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var text_label = preload("res://floating_label.tscn")
	var private_label = preload("res://floating_label_private.tscn")
	var text_node
	
	var random_text = randi_range(0, 1)
	print(random_text)
	if random_text == 1:
		text_node = text_label.instantiate()
	else :
		text_node = private_label.instantiate()
	
	var random = randi_range(0, 2)
	text_node.text = array_test[random]

	message_container.add_child(text_node)
