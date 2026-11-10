extends Node2D

@onready var hud: Control = $CamadaInterface/HudTentativa
@onready var protagonista: ControladorProtagonista = $Protagonista

var estado_tentativa: EstadoTentativa = EstadoTentativa.new()


func _ready() -> void:
	protagonista.vida_alterada.connect(hud.mostrar_vida)
	protagonista.morreu.connect(_ao_morrer)
	hud.mostrar_vida(protagonista.vida_atual, protagonista.vida_maxima)
	hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
	hud.mostrar_interacao("Setas: mover    Espaço: pular    J: atacar")
	for inseto in get_tree().get_nodes_in_group("insetos"):
		inseto.derrotado.connect(_ao_derrotar_inseto)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_accept") and protagonista.vida_atual <= 0:
		get_tree().reload_current_scene()


func _ao_derrotar_inseto(recompensa_pontos: int) -> void:
	estado_tentativa.conceder_pontos_mutacao(recompensa_pontos)
	hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
	hud.mostrar_interacao("Inseto derrotado: +%d pontos de mutação" % recompensa_pontos)


func _ao_morrer() -> void:
	hud.mostrar_interacao("A planta morreu. Pressione Espaço para tentar novamente.")
