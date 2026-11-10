extends CharacterBody2D
class_name Inseto

signal derrotado(recompensa_pontos: int)

@export var textura: Texture2D
@export var vida_maxima: int = 20
@export var velocidade: float = 75.0
@export var dano_ataque: int = 8
@export var alcance_ataque: float = 36.0
@export var intervalo_ataque: float = 1.2
@export var resistencia_dano: int = 0
@export var recompensa_pontos: int = 1
@export var distancia_percepcao: float = 240.0

var vida_atual: int
var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var _tempo_ate_atacar: float = 0.0
var _morto: bool = false

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	add_to_group("insetos")
	vida_atual = vida_maxima
	visual.texture = textura


func _physics_process(delta: float) -> void:
	if _morto:
		return

	_tempo_ate_atacar = maxf(_tempo_ate_atacar - delta, 0.0)
	var alvo := get_tree().get_first_node_in_group("protagonista") as ControladorProtagonista
	if is_instance_valid(alvo):
		_seguir_ou_atacar(alvo)
	else:
		velocity.x = 0.0

	if not is_on_floor():
		velocity.y += gravidade * delta

	move_and_slide()


func receber_dano(dano: int) -> void:
	if _morto or dano <= 0:
		return

	vida_atual = maxi(vida_atual - maxi(dano - resistencia_dano, 1), 0)
	if vida_atual == 0:
		_morto = true
		derrotado.emit(recompensa_pontos)
		queue_free()


func _seguir_ou_atacar(alvo: ControladorProtagonista) -> void:
	var distancia := alvo.global_position - global_position
	if absf(distancia.x) > distancia_percepcao or absf(distancia.y) > 52.0:
		velocity.x = 0.0
		return

	var direcao := signf(distancia.x)
	visual.flip_h = direcao < 0.0
	if absf(distancia.x) <= alcance_ataque:
		velocity.x = 0.0
		if _tempo_ate_atacar == 0.0:
			alvo.receber_dano(dano_ataque)
			_tempo_ate_atacar = intervalo_ataque
		return

	velocity.x = direcao * velocidade
