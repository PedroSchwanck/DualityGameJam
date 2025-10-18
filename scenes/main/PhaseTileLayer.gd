extends TileMap
class_name PhaseTileLayer

@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

@export var layer_type: String = "gray_solid"  # "white_solid","black_solid","gray_solid","white_hint","black_hint"
@export var active_collision_layer: int = 1
@export var active_collision_mask:  int = 1
@export var hint_alpha: float = 0.35  # opacidade opcional para os hints

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
			# mostra pontilhado branco quando a fase é preta (oposta)
			visible = (p == PhaseManager.Phase.BLACK)
			_set_collision(false)
			_apply_hint_alpha()

		"black_hint":
			# mostra pontilhado preto quando a fase é branca (oposta)
			visible = (p == PhaseManager.Phase.WHITE)
			_set_collision(false)
			_apply_hint_alpha()

func _set_collision(on: bool) -> void:
	if on:
		set("collision_layer", active_collision_layer)
		set("collision_mask",  active_collision_mask)
	else:
		# Zerar efetivamente desliga a colisão desse TileMap
		set("collision_layer", 0)
		set("collision_mask",  0)

func _apply_hint_alpha() -> void:
	# Apenas visual (se quiser deixar os hints mais “fantasmas”)
	modulate.a = hint_alpha
