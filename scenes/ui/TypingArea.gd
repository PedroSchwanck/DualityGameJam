extends Control

@onready var label: RichTextLabel = $VBox/RichTextLabel
# Agora o autoload chama GS (instância), mas o tipo é GameState (classe).
@onready var GS: GameState = get_node("/root/GS") as GameState

func _ready() -> void:
    label.bbcode_enabled = true
    GS.text_ready.connect(_on_text_ready)
    GS.stats_updated.connect(func(_s: Dictionary) -> void:
        _render_text()
    )
    _render_text()

func _on_text_ready(_text: String) -> void:
    _render_text()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        var e := event as InputEventKey

        if GS.state == GameState.RunState.IDLE:
            GS.start()

        if e.keycode == KEY_BACKSPACE:
            GS.handle_backspace()
            _render_text()
            return

        if e.unicode == 0:
            return

        var ch: String = String.chr(e.unicode)
        if ch == "\r":
            ch = "\n"

        GS.handle_input_char(ch)
        _render_text()

func _render_text() -> void:
    var t: String = GS.target_text
    var pos: int = GS.pos

    var s := PackedStringArray()
    for i in t.length():
        var ch: String = t[i]
        if i < pos:
            if GS.errors.has(i):
                s.push_back("[color=#ff5555]" + ch + "[/color]")
            else:
                s.push_back("[color=#6ee7b7]" + ch + "[/color]")
        elif i == pos:
            s.push_back("[color=#ffd866]" + ch + "[/color]")
        else:
            s.push_back(ch)

    label.bbcode_text = "".join(s)
