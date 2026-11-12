extends CharacterBody2D
class_name Inseto

const EfeitoImpacto = preload("res://Scripts/Combate/EfeitoImpacto.gd")

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
@export var forca_recuo_horizontal: float = 220.0
@export var forca_recuo_vertical: float = 90.0
@export var duracao_recuo: float = 0.14

var vida_atual: int
var gravidade: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var _tempo_ate_atacar: float = 0.0
var _tempo_recuo: float = 0.0
var _tween_luz_dano: Tween
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
	if _tempo_recuo > 0.0:
		_tempo_recuo = maxf(_tempo_recuo - delta, 0.0)
	else:
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


func receber_impacto(dano: int, origem: Vector2) -> void:
	if _morto or dano <= 0:
		return

	_mostrar_impacto_dano()
	receber_dano(dano)
	if _morto:
		return

	var direcao_recuo := signf(global_position.x - origem.x)
	if is_zero_approx(direcao_recuo):
		direcao_recuo = -1.0 if visual.flip_h else 1.0
	velocity.x = direcao_recuo * forca_recuo_horizontal
	velocity.y = -forca_recuo_vertical
	_tempo_recuo = duracao_recuo


func _mostrar_impacto_dano() -> void:
	var efeito := EfeitoImpacto.new()
	get_tree().current_scene.add_child(efeito)
	efeito.global_position = global_position + Vector2(0.0, -10.0)
	efeito.z_index = 10
	efeito.iniciar(Color(1.0, 0.78, 0.28), 26.0, 10)

	if is_instance_valid(_tween_luz_dano) and _tween_luz_dano.is_running():
		_tween_luz_dano.kill()
	visual.modulate = Color(1.0, 0.86, 0.48)
	_tween_luz_dano = create_tween()
	_tween_luz_dano.tween_property(visual, "modulate", Color.WHITE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _seguir_ou_atacar(alvo: ControladorProtagonista) -> void:
	var distancia := alvo.global_position - global_position
	if absf(distancia.x) > distancia_percepcao or absf(distancia.y) > 52.0:
		velocity.x = 0.0
		return

	var direcao := signf(distancia.x)
	if not is_zero_approx(direcao):
		visual.flip_h = direcao > 0.0
	if absf(distancia.x) <= alcance_ataque:
		velocity.x = 0.0
		if _tempo_ate_atacar == 0.0:
			alvo.receber_impacto(dano_ataque, global_position)
			_tempo_ate_atacar = intervalo_ataque
		return

	velocity.x = direcao * velocidade
