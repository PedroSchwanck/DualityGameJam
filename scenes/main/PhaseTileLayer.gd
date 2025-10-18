extends TileMap
class_name PhaseTileLayer

@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

@export var layer_type: String = "white_solid"  # "white_solid","black_solid","gray_solid","white_hint","black_hint"
@export var active_collision_layer: int = 1
@export var active_collision_mask:  int = 1

func _ready() -> void:
    PM.phase_changed.connect(_on_phase_changed)
    _apply_by_phase(PM.phase)

func _on_phase_changed(p: int) -> void:
    _apply_by_phase(p)

func _apply_by_phase(p: int) -> void:
    match layer_type:
        "white_solid":
            visible = true
            _set_collision(p == PhaseManager.Phase.WHITE)
        "black_solid":
            visible = true
            _set_collision(p == PhaseManager.Phase.BLACK)
        "gray_solid":
            visible = true
            _set_collision(true)
        "white_hint":
            visible = (p == PhaseManager.Phase.BLACK) # mostra pontilhado branco na fase preta
            _set_collision(false)
        "black_hint":
            visible = (p == PhaseManager.Phase.WHITE) # mostra pontilhado preto na fase branca
            _set_collision(false)

func _set_collision(on: bool) -> void:
    if on:
        collision_layer = active_collision_layer
        collision_mask  = active_collision_mask
    else:
        collision_layer = 0
        collision_mask  = 0
