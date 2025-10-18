extends Node2D
class_name Spike

@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager
@onready var area: Area2D = $Hit
@onready var sprite: CanvasItem = $Sprite2D

enum SpikeColor { WHITE, BLACK, RED, GRAY }
@export var color_type: SpikeColor = SpikeColor.RED

func _ready() -> void:
    if area:
        area.body_entered.connect(_on_body_entered)
    PM.phase_changed.connect(func(_p:int): _apply_phase_state())
    _apply_phase_state()

func _on_body_entered(b: Node) -> void:
    if not (b is CharacterBody2D): return
    match color_type:
        SpikeColor.GRAY: return
        SpikeColor.RED: _kill(b); return
        SpikeColor.WHITE:
            if PM.phase == PhaseManager.Phase.WHITE: _kill(b)
        SpikeColor.BLACK:
            if PM.phase == PhaseManager.Phase.BLACK: _kill(b)

func _kill(player: CharacterBody2D) -> void:
    if "kill_and_respawn" in player:
        player.kill_and_respawn()

func _apply_phase_state() -> void:
    var active := match color_type:
        SpikeColor.GRAY: false
        SpikeColor.RED: true
        SpikeColor.WHITE: PM.phase == PhaseManager.Phase.WHITE
        SpikeColor.BLACK: PM.phase == PhaseManager.Phase.BLACK
        _ : true
    if area:
        area.monitoring = (color_type != SpikeColor.GRAY)
        area.set_deferred("monitorable", area.monitoring)
    if sprite:
        sprite.modulate.a = 1.0 if active else 0.35 # “pontilhado/ghost” visual
