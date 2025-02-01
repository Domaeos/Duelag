# auth.gd
extends Node

# Constants
const REQUEST_TYPES = {
	LOGIN = "LOGIN",
	REGISTER = "REGISTER",
	REFRESH = "REFRESH"
}

# Node References
@export var username: LineEdit
@export var password: LineEdit
@export var confirm_password: LineEdit
@export var email: LineEdit
@export var remember_me: CheckBox
@export_file("*.tscn") var logged_in_scene

@onready var request_node = $HTTPRequest
@onready var info_node = get_parent().get_node_or_null("LoginPanel")

# State Management
var login_requests = {}
var login_details = {}

# HTTP Request Management
class RequestBuilder:
	static func create_headers(request_id: String) -> Array:
		return [
			"Content-Type: application/json",
			"User-Agent: Godot-Server",
			"X-Request-ID: " + request_id
		]
	
	static func generate_request_id(type: String) -> String:
		return type + str(randi())

func _ready() -> void:
	pass

# Action Handlers
func action_request(action: String) -> void:
	match action:
		"Verify":
			rpc_id(1, "send_refresh_request", Global.account.email, Global.account.refresh_token)
		"Login":
			login_details.email = email.text
			rpc_id(1, "send_login_request", email.text, password.text)
		"Register":
			rpc_id(1, "send_register_request", email.text, username.text, password.text)

# RPC Functions
@rpc("reliable", "any_peer")
func send_refresh_request(email: String, token: String) -> void:
	var request_id = RequestBuilder.generate_request_id(REQUEST_TYPES.REFRESH)
	login_requests[request_id] = multiplayer.get_remote_sender_id()
	
	var headers = RequestBuilder.create_headers(request_id)
	var body = { "refresh_token": token }
	
	request_node.request(Global.API_ADDR + "users/refresh", 
						headers, 
						HTTPClient.METHOD_POST, 
						JSON.stringify(body))

@rpc("reliable", "any_peer")
func send_register_request(email: String, username: String, password: String) -> void:
	var request_id = RequestBuilder.generate_request_id(REQUEST_TYPES.REGISTER)
	login_requests[request_id] = multiplayer.get_remote_sender_id()
	
	var headers = RequestBuilder.create_headers(request_id)
	var body = { 
		"email": email, 
		"password": password, 
		"username": username 
	}
	
	request_node.request(Global.API_ADDR + "users/register", 
						headers, 
						HTTPClient.METHOD_POST, 
						JSON.stringify(body))

@rpc("reliable", "any_peer")
func send_login_request(email: String, password: String) -> void:
	var request_id = RequestBuilder.generate_request_id(REQUEST_TYPES.LOGIN)
	login_requests[request_id] = multiplayer.get_remote_sender_id()
	
	var headers = RequestBuilder.create_headers(request_id)
	var body = { "email": email, "password": password }
	
	request_node.request(Global.API_ADDR + "users/login", 
						headers, 
						HTTPClient.METHOD_POST, 
						JSON.stringify(body))

# Helper Functions
func parse_request_type(request_id: String) -> String:
	var regex = RegEx.new()
	regex.compile("([A-Z]+)(\\d+)")
	var result = regex.search(request_id)
	return result.get_string(1) if result else ""

func parse_headers(headers: PackedStringArray) -> Dictionary:
	var header_dict = {}
	for header in headers:
		var parts = header.split(": ", 1)
		if parts.size() == 2:
			header_dict[parts[0]] = parts[1]
	return header_dict

# Response Handlers
func _on_http_request_request_completed(result: int, response_code: int, 
									  headers: PackedStringArray, 
									  body: PackedByteArray) -> void:
	var parsed_headers = parse_headers(headers)
	var request_id = parsed_headers.get("x-request-id", "")
	var request_type = parse_request_type(request_id)
	var peer_id = int(login_requests.get(request_id, 0))
	
	if result != HTTPRequest.RESULT_SUCCESS:
		rpc_id(peer_id, "pass_error", {"code": 500, "detail": "Internal server error"})
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	handle_response(response_code, request_type, json, peer_id)

func handle_response(response_code: int, request_type: String, 
					json: Dictionary, peer_id: int) -> void:
	match response_code:
		200:
			match request_type:
				REQUEST_TYPES.LOGIN:
					rpc_id(peer_id, "login_verified", 
						   json["access_token"], 
						   json["refresh_token"], 
						   json["username"])
				REQUEST_TYPES.REFRESH:
					rpc_id(peer_id, "token_refreshed", 
						   json["access_token"], 
						   json["refresh_token"])
		201:
			if request_type == REQUEST_TYPES.REGISTER:
				rpc_id(peer_id, "register_complete")
		401, 400:
			rpc_id(peer_id, "pass_error", 
				   {"code": response_code, "detail": json["detail"]})
			

# Account Management
func save_account_data(data: Dictionary) -> bool:
	var file = FileAccess.open(Global.SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_line(JSON.stringify(data))
		file.close()
		return true
	return false

func get_current_time() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d:%02d" % [
		datetime.year, datetime.month, datetime.day,
		datetime.hour, datetime.minute, datetime.second
	]

# RPC Response Handlers
@rpc("authority", "call_remote")
func pass_error(error: Dictionary) -> void:
	if info_node:
		info_node.handle_error(error)

@rpc("authority", "call_remote")
func login_verified(access_token: String, refresh_token: String, 
				   username: String) -> void:
	var account = {
		"email": email.text,
		"access_token": access_token,
		"refresh_token": refresh_token,
		"username": username,
		"last_login": get_current_time()
	}
	Global.account = account
	
	if remember_me.button_pressed:
		save_account_data(account)
		
	_change_scene(logged_in_scene)
	

@rpc("authority", "call_remote")
func token_refreshed(access_token: String, refresh_token: String) -> void:
	Global.account.access_token = access_token
	Global.account.refresh_token = refresh_token
	Global.account.last_login = get_current_time()
	
	if remember_me.button_pressed:
		save_account_data(Global.account)
		
	_change_scene(logged_in_scene)

@rpc("authority", "call_remote")
func register_complete() -> void:
	info_node.info_label.text = "[center]Success![/center]"
	info_node.message_label.visible = true
	info_node.message_label.text = "Welcome to the Duelag! Please verify your email before attempting to login"
	info_node.info_label.trigger_flash()
	info_node.timer.start()
	
func _change_scene(scene_file: String):
	get_tree().change_scene_to_file(scene_file)
