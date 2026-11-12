extends Node2D

var _cor: Color = Color.WHITE
var _raio: float = 28.0
var _quantidade_raios: int = 10
var _progresso: float = 0.0


func iniciar(cor: Color, raio: float, quantidade_raios: int) -> void:
	_cor = cor
	_raio = raio
	_quantidade_raios = quantidade_raios
	queue_redraw()

	var tween := create_tween()
	tween.tween_method(_atualizar_progresso, 0.0, 1.0, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "rotation", 0.35, 0.28)
	tween.tween_callback(queue_free)


func _atualizar_progresso(valor: float) -> void:
	_progresso = valor
	queue_redraw()


func _draw() -> void:
	var transparencia := 1.0 - _progresso
	var raio_atual := lerpf(_raio * 0.25, _raio, _progresso)
	var cor_principal := _cor
	cor_principal.a *= transparencia
	var cor_luz := Color(1.0, 0.96, 0.82, transparencia)

	draw_arc(Vector2.ZERO, raio_atual * 0.55, 0.0, TAU, 32, cor_principal, maxf(0.1, 2.5 * transparencia), true)
	draw_arc(Vector2.ZERO, raio_atual * 0.3, 0.0, TAU, 24, cor_luz, maxf(0.1, 1.5 * transparencia), true)

	for indice in range(_quantidade_raios):
		var angulo := TAU * float(indice) / float(_quantidade_raios)
		var direcao := Vector2.from_angle(angulo)
		var distancia_inicio := raio_atual * (0.18 if indice % 2 == 0 else 0.32)
		var distancia_fim := raio_atual * (0.7 if indice % 2 == 0 else 0.52)
		draw_line(direcao * distancia_inicio, direcao * distancia_fim, cor_luz if indice % 3 == 0 else cor_principal, maxf(0.1, 2.0 * transparencia), true)
		draw_circle(direcao * distancia_fim, maxf(0.1, 1.8 * transparencia), cor_luz)

	var tamanho_nucleo := 5.0 * transparencia
	var nucleo := PackedVector2Array([
		Vector2(0.0, -tamanho_nucleo * 1.7),
		Vector2(tamanho_nucleo, 0.0),
		Vector2(0.0, tamanho_nucleo * 1.7),
		Vector2(-tamanho_nucleo, 0.0)
	])
	draw_colored_polygon(nucleo, cor_luz)
