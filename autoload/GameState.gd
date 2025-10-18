extends Node
class_name GameState

signal text_ready(text: String)
signal state_changed(state: int)
signal stats_updated(stats: Dictionary)

enum RunState { IDLE, COUNTDOWN, RUNNING, PAUSED, FINISHED }

var state: int = RunState.IDLE
var target_text: String = ""
var pos: int = 0

var started_at: float = 0.0
var finished_at: float = 0.0

var correct_chars: int = 0
var error_chars: int = 0
var errors: Dictionary = {} # índice -> caractere digitado errado

# Modo de jogo
var mode: String = "time" # "time" ou "words"
var time_limit: int = 60
var word_count: int = 50
var allow_forward_errors: bool = true  # avança mesmo com erro (estilo monkeytype)

func reset(run_text: String) -> void:
    target_text = run_text
    pos = 0
    started_at = 0.0
    finished_at = 0.0
    correct_chars = 0
    error_chars = 0
    errors.clear()
    state = RunState.IDLE
    emit_signal("text_ready", target_text)
    emit_signal("state_changed", state)
    emit_signal("stats_updated", get_stats())

func start() -> void:
    state = RunState.RUNNING
    var now: float = Time.get_unix_time_from_system()
    started_at = now
    emit_signal("state_changed", state)

func pause_toggle() -> void:
    if state == RunState.RUNNING:
        state = RunState.PAUSED
    elif state == RunState.PAUSED:
        state = RunState.RUNNING
    emit_signal("state_changed", state)

func finish() -> void:
    if finished_at == 0.0:
        var now: float = Time.get_unix_time_from_system()
        finished_at = now
    state = RunState.FINISHED
    emit_signal("state_changed", state)

func elapsed_seconds() -> float:
    if started_at == 0.0:
        return 0.0
    if state == RunState.RUNNING:
        return Time.get_unix_time_from_system() - started_at
    return finished_at - started_at

func handle_input_char(ch: String) -> void:
    if state != RunState.RUNNING:
        return
    if pos >= target_text.length():
        finish()
        return
    var expected: String = target_text[pos]
    if ch == expected:
        correct_chars += 1
    else:
        error_chars += 1
        errors[pos] = ch
    pos += 1
    if mode == "time" and elapsed_seconds() >= float(time_limit):
        finish()
    elif mode == "words" and pos >= target_text.length():
        finish()
    emit_signal("stats_updated", get_stats())

func handle_backspace() -> void:
    if state != RunState.RUNNING:
        return
    if pos <= 0:
        return
    pos -= 1
    if errors.has(pos):
        errors.erase(pos)
        error_chars = max(0, error_chars - 1)
    else:
        correct_chars = max(0, correct_chars - 1)
    emit_signal("stats_updated", get_stats())

func accuracy() -> float:
    var total: int = max(1, correct_chars + error_chars)
    return float(correct_chars) / float(total)

func gross_wpm() -> float:
    var mins: float = max(elapsed_seconds() / 60.0, 0.0001)
    var total_chars: int = max(pos, 0)
    return float(total_chars) / 5.0 / mins

func net_wpm() -> float:
    var mins: float = max(elapsed_seconds() / 60.0, 0.0001)
    var penalty: float = (float(error_chars) / 5.0) / mins
    return max(0.0, gross_wpm() - penalty)

func get_stats() -> Dictionary:
    return {
        "state": state,
        "elapsed": elapsed_seconds(),
        "pos": pos,
        "correct": correct_chars,
        "errors": error_chars,
        "accuracy": accuracy(),
        "gross_wpm": gross_wpm(),
        "net_wpm": net_wpm()
    }
