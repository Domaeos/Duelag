extends Label


var fade_timer: Timer
@export var message_delay = 5.0

func _ready() -> void:
	fade_timer = Timer.new()
	add_child(fade_timer) 
	fade_timer.wait_time = message_delay
	fade_timer.one_shot = true
	fade_timer.connect("timeout", _on_fade_timer_timeout)
	fade_timer.start()
	
func _on_fade_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a" , 0, 0.5).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(self.queue_free)
