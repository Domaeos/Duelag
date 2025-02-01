extends PanelContainer

@onready var username_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/Username
@onready var last_login_label: Label = $HBoxContainer/MarginContainer/VBoxContainer/LastLogin
@onready var avatar: TextureRect = $HBoxContainer/AvatarContainer/Avatar

func populate_fields():
	if Global.account:
		username_label.text = Global.account.username
		last_login_label.text = "Last login: " + Global.account.last_login
