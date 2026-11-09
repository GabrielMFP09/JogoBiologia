extends Node2D

@onready var hud: Control = $CamadaInterface/HudTentativa


func _ready() -> void:
	hud.mostrar_interacao("Setas: mover    Espaço: pular")
