extends Node2D
class_name Checkpoint

@onready var area: Area2D = $Area
@onready var sprite: CanvasItem = $Sprite2D if has_node("Sprite2D") else null

var _activated := false

func _ready() -> void:
    if area:
        area.body_entered.connect(_on_body_entered)
    _update_visual()

func _on_body_entered(b: Node) -> void:
    if _activated:
        return
    if b is CharacterBody2D and "set_respawn" in b:
        (b as Node).call("set_respawn", global_position)
        _activated = true
        _update_visual()

func _update_visual() -> void:
    if sprite:
        sprite.modulate = Color(0.6, 1.0, 0.6, 1.0) if _activated else Color(1, 1, 1, 0.7)
