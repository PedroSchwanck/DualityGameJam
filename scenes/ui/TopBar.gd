extends HBoxContainer

@onready var wpm_label: Label = $WPM
@onready var acc_label: Label = $ACC
@onready var time_label: Label = $TIME
@onready var restart_btn: Button = $Restart

@onready var GS: GameState = get_node("/root/GS") as GameState
@onready var SET: Settings = get_node("/root/CFG") as Settings

var loader: WordLoader = WordLoader.new()

func _ready() -> void:
    restart_btn.pressed.connect(_on_restart)
    GS.stats_updated.connect(_update_labels)
    _update_labels(GS.get_stats())

func _on_restart() -> void:
    var lang: String = SET.language
    var count: int = SET.word_count if SET.mode == "words" else 80
    var text: String = loader.build_text(lang, count, SET.seed)
    GS.reset(text)

func _update_labels(stats: Dictionary) -> void:
    var wpm: int = int(round(stats.get("net_wpm", 0.0)))
    var acc: int = int(round(float(stats.get("accuracy", 1.0)) * 100.0))
    var t: int = int(round(stats.get("elapsed", 0.0)))

    wpm_label.text = "WPM: %d" % wpm
    acc_label.text = "ACC: %d%%" % acc
    time_label.text = "t: %ds" % t
