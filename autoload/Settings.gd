extends Node
class_name Settings

signal changed

var language := "pt_br"
var mode := "time"
var time_limit := 60
var word_count := 50
var punctuation := false
var numbers := false
var seed := 0

func set_and_emit(prop: StringName, value) -> void:
    self.set(prop, value)
    emit_signal("changed")
