extends Control
class_name UIManager

signal scene_changed(path: String)
signal screen_changed(old_screen: StringName, new_screen: StringName)
signal is_paused(bool)

@onready var justonemore: CanvasLayer = $CanvasLayer
@onready var game_over_screen: GameOverScreen = $CanvasLayer/GameOverScreen
@onready var start_menu: Control = $CanvasLayer/StartMenu
@onready var map_select: Control = $CanvasLayer/MapSelect
@onready var options_menu: Control = $CanvasLayer/OptionsMenu

@export var start_path: String = " "


var current_map_path: String = " "
var current_screen: StringName = &""
var _screens := {}
var _screen_history: Array[StringName] = []

func _ready() -> void:
	clear_screen()
	show_screen(&"StartMenu")
	print(_screens)

func change_map(path: String):
	current_map_path = path
	get_tree().change_scene_to_file(path)
	scene_changed.emit(path)
	clear_screen()
	if current_map_path != " " or not start_path:
		show_screen(&"PlayerHud")
		toggle_pause(false, false)
	if current_map_path == start_path:
		show_screen(&"StartMenu")
		toggle_pause(false, true)

func clear_screen() -> void:
	for child in justonemore.get_children():
		if child is Control:
			_screens[child.name] = child
			child.visible = false
	print("clear")

func show_screen(screen_name: StringName, push_history := true) -> void:
	if not _screens.has(screen_name):
		push_error("no screen named %s" % screen_name)
		return
	if screen_name == current_screen:
		return
	var old := current_screen
	if old != &"":
		_screens[old].visible
		if push_history:
			_screen_history.append(old)
	current_screen = screen_name
	_screens[screen_name].visible = true
	screen_changed.emit(old, screen_name)
	print("swapping " + old + " for " + screen_name)
	
func go_back() -> void:
		if _screen_history.is_empty():
			return
		show_screen(_screen_history.pop_back(), false)

func toggle_pause(pause_state: bool, mouse_state: bool):
	get_tree().paused = pause_state
	if mouse_state:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif not mouse_state:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		return
	is_paused.emit(pause_state)

func _input(event: InputEvent) -> void:
	if not current_map_path == " " or start_path:
		if event.is_action_pressed("exit") and not get_tree().paused:
			show_screen(&"PauseMenu")
			toggle_pause(true, true)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("exit") and get_tree().paused:
			clear_screen()
			show_screen(&"PlayerHud")
			toggle_pause(false, false)
			get_viewport().set_input_as_handled()
	else:
		pass
