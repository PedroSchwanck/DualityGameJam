extends Control

var level = "res://MenuScreen/history_scene.tscn"
@onready var creditos = $ColorRect

func _ready():
	pass

func _on_jogar_pressed():
	var _level = get_tree().change_scene_to_file(level)


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_creditos_pressed() -> void:
	creditos.show()


func _on_fechar_pressed() -> void:
	creditos.hide()
