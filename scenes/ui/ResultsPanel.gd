extends Panel

@onready var summary: Label = $VBox/Summary
@onready var again: Button = $VBox/Again
@onready var GS: GameState = get_node("/root/GS") as GameState

func _ready() -> void:
    hide()
    again.pressed.connect(func() -> void:
        hide()
    )
    GS.state_changed.connect(func(s: int) -> void:
        if s == GameState.RunState.FINISHED:
            _refresh()
            show()
        else:
            hide()
    )

func _refresh() -> void:
    var st := GS.get_stats()
    var wpm: int = int(round(st.get("net_wpm", 0.0)))
    var acc: int = int(round(float(st.get("accuracy", 1.0)) * 100.0))
    var tm: int = int(round(st.get("elapsed", 0.0)))
    var errs: int = int(st.get("errors", 0))
    summary.text = "WPM: %d | ACC: %d%% | Tempo: %ds | Erros: %d" % [wpm, acc, tm, errs]
