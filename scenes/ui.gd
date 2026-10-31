extends Control

@onready var pause_menu: PauseMenu = %PauseMenu
@onready var game_over_screen: GameOverScreen = $CanvasLayer/GameOverScreen
@onready var start_menu: Control = $CanvasLayer/StartMenu
@onready var map_select: Control = $CanvasLayer/MapSelect

var current_map = null

func _ready() -> void:
	current_map = get_tree().get_current_scene().name
	print(current_map)
