extends Control
class_name UIManager

signal screen_changed(base: StringName, top: StringName)
signal pause_changed(is_paused: bool)

@onready var justonemore: CanvasLayer = $CanvasLayer
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

const PAUSING: Array[StringName] = [&"PauseMenu", &"GameOverScreen"]

@export var start_path: String = ""


var current_map_path: String = ""
var base_screen: StringName = &""
var _screens: Dictionary = {}
var _screen_history: Array[StringName] = []

func _ready() -> void:
	current_map_path = start_path
	for child in justonemore.get_children():
		if child is Control:
			_screens[child.name] = child
			child.visible = false
		print(_screens)
		set_base(&"StartMenu")

func set_base(screen: StringName) -> void:
	if not _screens.has(screen):
		push_error("ion know %s, playa" % screen)
		return
	clear_screen(false)
	if base_screen != &"":
		_screens[base_screen].visible = false
	base_screen = screen
	_screens[base_screen].visible = true
	_apply_state()

func push(screen: StringName) -> void:
	if not _screens.has(screen):
		push_error("why does push() lowk not see %s" % screen)
		return
	if top() == screen:
		return
	if not _screen_history.is_empty():
		_screens[top()].visible = false
	_screen_history.append(screen)
	_screens[screen].visible = true
	_apply_state()

func pop() -> void:
	if _screen_history.is_empty():
		return
	_screens[_screen_history.pop_back()].visible = false
	if not _screen_history.is_empty():
		_screens[top()].visible = true
	_apply_state()

func clear_screen(apply := true) -> void:
	for s in _screen_history:
		_screens[s].visible = false
	_screen_history.clear()
	if apply:
		_apply_state()

func top() -> StringName:
	return _screen_history.back() if not _screen_history.is_empty() else &""

func change_map(path: String) -> void:
	current_map_path = path
	clear_screen(false)
	get_tree().change_scene_to_file(path)
	set_base(&"StartMenu" if path == start_path else &"")

func restart() -> void:
	clear_screen()
	get_tree().reload_current_scene()

func _apply_state() -> void:
	var paused := _screen_history.any(func(s): return s in PAUSING)
	var was_paused := get_tree().paused
	get_tree().paused = paused
	
	var want_cursor := base_screen == &"StartMenu" or not _screen_history.is_empty()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if want_cursor else Input.MOUSE_MODE_CAPTURED
	
	if paused != was_paused:
		pause_changed.emit(paused)
	screen_changed.emit(base_screen, top())

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("exit"):
		return
	if base_screen != &"PlayerHud":
		return
	get_viewport().set_input_as_handled()
	if top() == &"GameOverScreen":
		return
	if _screen_history.is_empty():
		push(&"PauseMenu")
	else:
		pop()

func _on_player_died() -> void:
	pass
	
