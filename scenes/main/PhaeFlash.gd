extends ColorRect

@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

# Intensidade e duração do flash
@export var flash_alpha: float = 0.35
@export var flash_time: float = 0.12

func _ready() -> void:
    visible = false
    PM.phase_changed.connect(_on_phase_changed)

func _on_phase_changed(p: int) -> void:
    # Cor do flash = cor OPOSTA ao fundo atual
    var is_white := (p == PhaseManager.Phase.WHITE)
    color = Color(0,0,0,1) if is_white else Color(1,1,1,1)

    visible = true
    modulate.a = 0.0
    var tw := get_tree().create_tween()
    tw.tween_property(self, "modulate:a", flash_alpha, flash_time)
    tw.tween_property(self, "modulate:a", 0.0, flash_time * 0.8)
    tw.tween_callback(func(): visible = false)
