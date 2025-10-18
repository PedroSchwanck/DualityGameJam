extends Node2D
@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager
@onready var bg_white: Sprite2D = $BG_White
@onready var bg_black: Sprite2D = $BG_Black

func _ready() -> void:
    PM.phase_changed.connect(_on_phase_changed)
    _apply(PM.phase)

func _on_phase_changed(p: int) -> void: _apply(p)

func _apply(p: int) -> void:
    var is_white := (p == PhaseManager.Phase.WHITE)
    bg_white.visible = is_white
    bg_black.visible = not is_white
