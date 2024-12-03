extends Sprite3D
@export var char_label: RichTextLabel
@export var max_messages:= 3

var message_array = Array([], TYPE_STRING, "", null)
var timer_array = Array([], TYPE_OBJECT, "Timer", null)
var current_index: int = 0
var message_delay_time = 2.0
var my_theme = preload("res://Ohead_theme.tres")

func _ready() -> void:
	for i in range(0, max_messages):
		message_array.append("")
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.wait_time = 2.0
		timer.timeout.connect(func(): _on_timeout(i))
		timer_array.append(timer)
		
	char_label = $SubViewport/OHeadText


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("call_local")
func _on_timeout(index):
	message_array[index] = ""
	
func _on_player_show_text(message: String) -> void:
	message_array.pop_front()
	message_array.append("[b][center]" + message + "[/center][/b]")

	var complete_message = "\n".join(message_array)
	char_label.text = complete_message
		
