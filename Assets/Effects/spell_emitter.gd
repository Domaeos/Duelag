extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_animated_sprite_2d_animation_finished() -> void:
	hide()
