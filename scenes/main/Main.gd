extends Control

@onready var GS: GameState = get_node("/root/GS") as GameState
@onready var SET: Settings = get_node("/root/CFG") as Settings

var loader: WordLoader = WordLoader.new()

func _ready() -> void:
    var lang: String = SET.language
    var count: int = SET.word_count if SET.mode == "words" else 80
    var text: String = loader.build_text(lang, count, SET.seed)
    GS.reset(text)
