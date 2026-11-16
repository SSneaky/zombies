extends Control

@onready var back_button: Button = $BackButton
@onready var map_button: Button = $HBoxContainer/MapButton
@onready var ui_manager: UIManager = $"../.."
@onready var party_list: VBoxContainer = $VBoxContainer


func _ready() -> void:
	map_button.pressed.connect(_on_map_pressed)
	back_button.pressed.connect(_on_back_pressed)
	NetworkGuy.party_changed.connect(_refresh_party)
	visibility_changed.connect(_refresh_party)

func _refresh_party() -> void:
	map_button.disabled = not multiplayer.is_server()
	for child in party_list.get_children():
		child.queue_free()
	for member in NetworkGuy.get_party():
		var label := Label.new()
		label.text = member.name + (" (HOST)" if member.is_host else "")
		party_list.add_child(label)
		

func _on_map_pressed() -> void:
	NetworkGuy.start_game("res://scenes/node_3d.tscn")

func _on_back_pressed() -> void: 
	NetworkGuy.leave_party()
	ui_manager.pop()
