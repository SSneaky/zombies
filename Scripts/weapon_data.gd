class_name WeaponData
extends Resource

@export var weapon_name: String = 'Blick'
@export var damage: int = 25
@export var fire_cooldown: float = 0.25
@export var automatic: bool = false
@export var pellets: int = 1
@export var spread_degrees: float = 0.0
@export var max_range: float = 100.0
@export var mag_size: int = 12
@export var starting_reserve: int = 24
@export var max_reserve: int = 120
@export var ammo_type: String = "9mm"
@export var reload_time: float = 1.5
@export var recoil_kick: float = 0.06
@export var model_scene: PackedScene
@export var shot_sound: AudioStream
@export var reload_sound: AudioStream
@export var empty_sound: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
