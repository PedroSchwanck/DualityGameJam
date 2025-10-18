extends CharacterBody2D
class_name PlayerController

@onready var anim: AnimatedSprite2D = $Anim
# Pega a instância do autoload "PH" e tipa como PhaseManager
@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

# Ações (configure no Mapa de Entrada)
const ACT_LEFT := "move_left"
const ACT_RIGHT := "move_right"
const ACT_JUMP := "jump"
const ACT_TOGGLE := "toggle_phase"

# Física e “feel”
const GRAVITY: float = 2400.0
const MAX_SPEED: float = 250.0
const MAX_SPEED_RUN: float = 360.0
const ACCEL: float = 3000.0
const DECEL: float = 3500.0
const JUMP_VELOCITY: float = -720.0
const JUMP_CUT: float = 0.5

const COYOTE_TIME: float = 0.10
const JUMP_BUFFER: float = 0.10
const RUN_CHARGE_TIME: float = 0.60
const AIR_CONTROL: float = 0.75

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _run_charge_timer: float = 0.0
var _last_dir: int = 0

func _ready() -> void:
    PM.phase_changed.connect(_on_phase_changed)
    _apply_phase_visual()

func _physics_process(delta: float) -> void:
    # Gravidade
    if not is_on_floor():
        velocity.y += GRAVITY * delta
        _coyote_timer = max(0.0, _coyote_timer - delta)
    else:
        _coyote_timer = COYOTE_TIME

    # Direção horizontal
    var dir: int = int(Input.is_action_pressed(ACT_RIGHT)) - int(Input.is_action_pressed(ACT_LEFT))
    var target_speed: float = (MAX_SPEED_RUN if _run_charge_timer >= RUN_CHARGE_TIME else MAX_SPEED) * float(dir)

    if dir != 0:
        var a: float = ACCEL if is_on_floor() else ACCEL * AIR_CONTROL
        velocity.x = move_toward(velocity.x, target_speed, a * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, DECEL * delta)

    # Run charge
    if dir != 0 and dir == _last_dir and is_on_floor():
        _run_charge_timer = min(RUN_CHARGE_TIME, _run_charge_timer + delta)
    elif dir != 0 and dir != _last_dir and is_on_floor():
        _run_charge_timer = 0.0
    elif dir == 0:
        _run_charge_timer = 0.0
    _last_dir = dir

    # Jump buffer
    if Input.is_action_just_pressed(ACT_JUMP):
        _jump_buffer_timer = JUMP_BUFFER
    else:
        _jump_buffer_timer = max(0.0, _jump_buffer_timer - delta)

    # Pulo (coyote + buffer)
    if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
        velocity.y = JUMP_VELOCITY
        _jump_buffer_timer = 0.0
        _coyote_timer = 0.0

    # Jump cut
    if Input.is_action_just_released(ACT_JUMP) and velocity.y < 0.0:
        velocity.y *= JUMP_CUT

    # Alternar fase/cor
    if Input.is_action_just_pressed(ACT_TOGGLE):
        PM.toggle_phase()
        _apply_phase_visual()

    _update_animation(dir)
    move_and_slide()

func _update_animation(dir: int) -> void:
    if dir != 0:
        anim.flip_h = dir < 0
    var is_air: bool = not is_on_floor()
    var cur: int = PM.phase
    var base: String = "black" if cur == PhaseManager.Phase.BLACK else "white"
    if is_air:
        anim.play("jump_" + base)
    elif abs(velocity.x) > 5.0:
        anim.play("run_" + base)
    else:
        anim.play("idle_" + base)

func _apply_phase_visual() -> void:
    # Ajustes visuais opcionais ao trocar de fase (flash, modulate, etc.)
    pass

func kill_and_respawn() -> void:
    var start := get_tree().get_first_node_in_group("level_start")
    if start and start is Node2D:
        global_position = (start as Node2D).global_position
    velocity = Vector2.ZERO
    _run_charge_timer = 0.0
    _coyote_timer = 0.0
    _jump_buffer_timer = 0.0

func _on_phase_changed(_p: int) -> void:
    pass
