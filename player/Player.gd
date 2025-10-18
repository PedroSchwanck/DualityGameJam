extends CharacterBody2D
class_name PlayerController

@onready var anim: AnimatedSprite2D = $Anim
# Autoload da fase (nome do autoload = "PH"; classe = PhaseManager)
@onready var PM: PhaseManager = get_node("/root/PH") as PhaseManager

# Ações (mapeadas no Input Map do projeto)
const ACT_LEFT := "move_left"
const ACT_RIGHT := "move_right"
const ACT_JUMP := "jump"
const ACT_TOGGLE := "toggle_phase"

# -------------------------------
# Parâmetros de movimento (tunable)
# -------------------------------
@export var GRAVITY: float = 2400.0
@export var MAX_SPEED: float = 250.0            # velocidade base no chão
@export var MAX_SPEED_RUN: float = 360.0        # após "run charge"
@export var ACCEL: float = 3000.0               # aceleração horizontal
@export var DECEL: float = 3500.0               # desaceleração no chão
@export var AIR_CONTROL: float = 0.75           # fração da ACCEL no ar
@export var JUMP_VELOCITY: float = -720.0
@export var JUMP_CUT: float = 0.5               # soltar o pulo corta altura
@export var MAX_FALL_SPEED: float = 1400.0      # clamp para queda

@export var COYOTE_TIME: float = 0.10           # tolerância após sair do chão
@export var JUMP_BUFFER: float = 0.10           # buffer antes de tocar o chão
@export var RUN_CHARGE_TIME: float = 0.60       # tempo na mesma direção p/ boost

# -------------------------------
# Estado interno
# -------------------------------
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _run_charge_timer: float = 0.0
var _last_dir: int = 0
var _respawn_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Conecta mudanças de fase (se quiser responder visualmente)
	if PM:
		PM.phase_changed.connect(_on_phase_changed)
	_apply_phase_visual()

	# Respawn inicial (se existe um Marker2D em grupo "level_start")
	var start := get_tree().get_first_node_in_group("level_start")
	if start and start is Node2D:
		_respawn_pos = (start as Node2D).global_position

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_update_ground_timers(delta)
	_horizontal_move(delta)
	_handle_jump(delta)
	_phase_toggle_if_requested()

	# Limitar velocidade de queda (qualidade de vida)
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	_update_animation()
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _update_ground_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = COYOTE_TIME
	else:
		_coyote_timer = max(0.0, _coyote_timer - delta)

	if _jump_buffer_timer > 0.0:
		_jump_buffer_timer = max(0.0, _jump_buffer_timer - delta)

func _horizontal_move(delta: float) -> void:
	# Direção solicitada
	var dir: int = int(Input.is_action_pressed(ACT_RIGHT)) - int(Input.is_action_pressed(ACT_LEFT))

	# Run charge (no chão, mesma direção por um tempo)
	if is_on_floor():
		if dir != 0 and dir == _last_dir:
			_run_charge_timer = min(RUN_CHARGE_TIME, _run_charge_timer + delta)
		elif dir != 0 and dir != _last_dir:
			_run_charge_timer = 0.0
		elif dir == 0:
			_run_charge_timer = 0.0
	_last_dir = dir

	var target_max: float = MAX_SPEED_RUN if _run_charge_timer >= RUN_CHARGE_TIME else MAX_SPEED
	var target_speed: float = target_max * float(dir)

	if dir != 0:
		var a: float = ACCEL if is_on_floor() else ACCEL * AIR_CONTROL
		velocity.x = move_toward(velocity.x, target_speed, a * delta)
	else:
		# Desaceleração forte no chão; no ar, uma leve desaceleração
		var decel: float = DECEL if is_on_floor() else DECEL * 0.2
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

func _handle_jump(delta: float) -> void:
	# Buffer do botão de pulo
	if Input.is_action_just_pressed(ACT_JUMP):
		_jump_buffer_timer = JUMP_BUFFER

	# Executa pulo se tem buffer e coyote
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0

	# Jump cut: soltar o pulo durante subida reduz a altura
	if Input.is_action_just_released(ACT_JUMP) and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

func _phase_toggle_if_requested() -> void:
	if Input.is_action_just_pressed(ACT_TOGGLE) and PM:
		PM.toggle_phase()
		_apply_phase_visual()

func _apply_phase_visual() -> void:
	# Aqui você pode alterar modulate/cor do sprite conforme a fase, se quiser.
	# Ex.: anim.modulate = Color.WHITE/Color.BLACK, ou trocar material.
	pass

func _update_animation() -> void:
	# Define base de animação conforme fase (white/black)
	var base: String = "white"
	if PM and PM.phase == PhaseManager.Phase.BLACK:
		base = "black"

	# Direção (espelhamento)
	if velocity.x != 0.0:
		anim.flip_h = velocity.x < 0.0

	var on_air: bool = not is_on_floor()
	var speed: float = abs(velocity.x)

	var anim_name: String = ""
	if on_air:
		anim_name = "jump_" + base
	elif speed > 5.0:
		anim_name = "run_" + base
	else:
		anim_name = "idle_" + base

	if anim and (not anim.is_playing() or anim.animation != anim_name):
		if anim.has_animation(anim_name):
			anim.play(anim_name)

# -------------------------------
# Respawn / utilitários
# -------------------------------
func set_respawn(pos: Vector2) -> void:
	_respawn_pos = pos

func kill_and_respawn() -> void:
	# Camera shake (se tua Camera2D tiver o método)
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.shake(0.18, 10.0)
	global_position = _respawn_pos
	velocity = Vector2.ZERO
	_reset_timers()

func _reset_timers() -> void:
	_run_charge_timer = 0.0
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0

func _on_phase_changed(_p: int) -> void:
	# Reaja à troca de fase se quiser (efeitos, som etc.)
	pass
