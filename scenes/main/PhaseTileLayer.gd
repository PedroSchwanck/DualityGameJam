extends TileMap
class_name PhaseTileLayer

# Pega a instância do autoload "PH" e tipa como PhaseManager
@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

@export var layer_type: String = "white_solid"
# valores válidos: "white_solid", "black_solid", "gray_solid", "white_hint", "black_hint"

# Defina aqui quais layers/masks usar quando a colisão estiver ATIVA
@export var active_collision_layer: int = 1
@export var active_collision_mask:  int = 1

# Opacidade opcional para as camadas de "hint" (pontilhado)
@export var hint_alpha: float = 0.35

func _ready() -> void:
    PM.phase_changed.connect(_on_phase_changed)
    _apply_by_phase(PM.phase)

func _on_phase_changed(p: int) -> void:
    _apply_by_phase(p)

func _apply_by_phase(p: int) -> void:
    match layer_type:
        "white_solid":
            visible = true
            _set_collision_enabled(p == PhaseManager.Phase.WHITE)

        "black_solid":
            visible = true
            _set_collision_enabled(p == PhaseManager.Phase.BLACK)

        "gray_solid":
            visible = true
            _set_collision_enabled(true)

        "white_hint":
            # Mostra hint da cor OPOSTA (fase preta)
            visible = (p == PhaseManager.Phase.BLACK)
            _set_collision_enabled(false)
            _apply_hint_alpha()

        "black_hint":
            # Mostra hint da cor OPOSTA (fase branca)
            visible = (p == PhaseManager.Phase.WHITE)
            _set_collision_enabled(false)
            _apply_hint_alpha()

func _set_collision_enabled(on: bool) -> void:
    if on:
        collision_layer = active_collision_layer
        collision_mask  = active_collision_mask
    else:
        # Zera para efetivamente "desligar" colisão desta TileMap
        collision_layer = 0
        collision_mask  = 0

func _apply_hint_alpha() -> void:
    # Ajusta a opacidade da TileMap de "hint" (apenas visual)
    if has_method("modulate"):
        modulate.a = hint_alpha
