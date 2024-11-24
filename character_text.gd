extends Sprite3D
@export var char_label: RichTextLabel
@export var max_messages:= 3

var message_array = Array([], TYPE_STRING, "", null)
var timer_array = Array([], TYPE_OBJECT, "Timer", null)
var current_index: int = 0
var message_delay_time = 2.0
var my_theme = preload("res://Ohead_theme.tres")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0, max_messages):
		message_array.append("")
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.wait_time = 2.0
		timer.timeout.connect(func(): _on_timeout(i))
		message_array.append(timer)
		
	char_label = find_child("OHeadText")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timeout(index):
	message_array[index] = ""
	pass
	
func _on_player_show_text(message: String) -> void:
	message_array.pop_front()
	message_array.append("[b][center]" + message + "[/center][/b]")
	print("NEW ARRAY: ", message_array)

	var complete_message = "\n".join(message_array)
	
	if char_label:
		char_label.text = complete_message
		
	

func _on_text_timer_timeout() -> void:
	char_label.text = ""
	pass # Replace with function body.
