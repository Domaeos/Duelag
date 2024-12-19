extends CanvasLayer

@onready var backdrop = $Backdrop
@onready var res_button = $Control/ResButton
@onready var res_button_label = $Label
@onready var world = get_parent().get_node_or_null("World")
var resurrect_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	resurrect_timer = Timer.new()
	resurrect_timer.wait_time = 3
	resurrect_timer.one_shot = true
	resurrect_timer.connect("timeout", _on_resurrect_timeout)
	add_child(resurrect_timer)
	
func _on_resurrect_timeout():
	pass

func _process(_delta: float) -> void:
	if resurrect_timer.is_stopped():
		res_button.disabled = false
		res_button_label.text = "Resurrect"
	else:
		res_button_label.text = str(ceil(resurrect_timer.time_left))


func show_menu():
	show()
	res_button.disabled = true
	resurrect_timer.start()
	backdrop.start_death_overlay()
	pass


func _on_res_button_pressed() -> void:
	world.rpc_id(1, "resurrect_player")
