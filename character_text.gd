extends Sprite3D
@export var char_label: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	char_label = find_child("OHeadText")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_show_text(message: String) -> void:
	if char_label:
		char_label.text = "[b]" + message + "[/b]"
	pass # Replace with function body.
