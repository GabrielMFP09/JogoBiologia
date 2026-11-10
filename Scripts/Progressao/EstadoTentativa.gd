extends RefCounted
class_name EstadoTentativa

var _pontos_mutacao: int = 0
var _mutacoes: Dictionary[String, DefinicaoMutacao] = {}


var pontos_mutacao: int:
	get:
		return _pontos_mutacao


var mutacoes: Array[DefinicaoMutacao]:
	get:
		var lista_mutacoes: Array[DefinicaoMutacao] = []
		for mutacao in _mutacoes.values():
			lista_mutacoes.append(mutacao)
		return lista_mutacoes


func conceder_pontos_mutacao(quantidade: int) -> void:
	if quantidade < 0:
		push_error("A quantidade de pontos de mutacao nao pode ser negativa.")
		return

	_pontos_mutacao += quantidade


func gastar_pontos_mutacao(quantidade: int) -> bool:
	if quantidade < 0:
		push_error("A quantidade de pontos de mutacao nao pode ser negativa.")
		return false

	if quantidade > _pontos_mutacao:
		return false

	_pontos_mutacao -= quantidade
	return true


func possui_mutacao(identificador_mutacao: String) -> bool:
	return _mutacoes.has(identificador_mutacao)


func adicionar_mutacao(mutacao: DefinicaoMutacao) -> void:
	if _mutacoes.has(mutacao.identificador):
		push_error("A tentativa ja possui essa mutacao.")
		return

	_mutacoes[mutacao.identificador] = mutacao
