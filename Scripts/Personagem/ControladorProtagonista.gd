extends CharacterBody2D
class_name ControladorProtagonista

signal vida_alterada(vida_atual: int, vida_maxima: int)
signal morreu

@export var velocidade: float = 280.0
@export var forca_pulo: float = 460.0
@export var vida_maxima: int = 100
@export var dano_ataque: int = 10
@export var alcance_ataque: float = 58.0
@export var intervalo_ataque: float = 0.45
@export var resistencia_dano: int = 0

var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var vida_atual: int
var _tempo_ate_atacar: float = 0.0
var _direcao_visual: float = 1.0
var _morto: bool = false

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	add_to_group("protagonista")
	vida_atual = vida_maxima
	vida_alterada.emit(vida_atual, vida_maxima)


func _physics_process(delta: float) -> void:
	if _morto:
		return

	_tempo_ate_atacar = maxf(_tempo_ate_atacar - delta, 0.0)
	var direcao := Input.get_axis("ui_left", "ui_right")
	velocity.x = direcao * velocidade
	if direcao != 0.0:
		_direcao_visual = signf(direcao)
		visual.flip_h = _direcao_visual < 0.0

	if not is_on_floor():
		velocity.y += gravidade * delta
	elif Input.is_action_just_pressed("ui_accept"):
		velocity.y = -forca_pulo

	move_and_slide()
	if Input.is_action_just_pressed("atacar"):
		_tentar_atacar()


func receber_dano(dano: int) -> void:
	if _morto or dano <= 0:
		return

	var dano_recebido := maxi(dano - resistencia_dano, 1)
	vida_atual = maxi(vida_atual - dano_recebido, 0)
	vida_alterada.emit(vida_atual, vida_maxima)
	if vida_atual == 0:
		_morto = true
		velocity = Vector2.ZERO
		morreu.emit()


func _tentar_atacar() -> void:
	if _tempo_ate_atacar > 0.0:
		return

	_tempo_ate_atacar = intervalo_ataque
	for inseto in get_tree().get_nodes_in_group("insetos"):
		var distancia := inseto.global_position - global_position
		if absf(distancia.x) > alcance_ataque or absf(distancia.y) > 48.0:
			continue
		if signf(distancia.x) != _direcao_visual:
			continue
		inseto.receber_dano(dano_ataque)
