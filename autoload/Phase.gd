extends Node
class_name PhaseManager

signal phase_changed(new_phase: int) # 0 = WHITE, 1 = BLACK
enum Phase { WHITE, BLACK }

var _phase: int = Phase.WHITE
var phase: int:
    set(value):
        if value == _phase: return
        _phase = value
        phase_changed.emit(_phase)
    get: return _phase

func toggle_phase() -> void:
    phase = Phase.BLACK if phase == Phase.WHITE else Phase.WHITE

func set_phase(p: int) -> void:
    phase = p
