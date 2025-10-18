extends Camera2D

var _shake_time: float = 0.0
var _shake_strength: float = 0.0
var _orig_offset: Vector2

func _ready() -> void:
    _orig_offset = offset

func _process(delta: float) -> void:
    if _shake_time > 0.0:
        _shake_time -= delta
        var t := max(_shake_time, 0.0)
        # ruído simples
        offset = _orig_offset + Vector2(randf() - 0.5, randf() - 0.5) * _shake_strength
        if t <= 0.0:
            offset = _orig_offset

func shake(duration: float = 0.25, strength: float = 8.0) -> void:
    _shake_time = duration
    _shake_strength = strength
