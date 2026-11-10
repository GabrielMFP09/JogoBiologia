extends RefCounted
class_name EstadoEspecie

var _identificadores_mutacoes: Dictionary[String, bool] = {}


var identificadores_mutacoes: Array[String]:
	get:
		var identificadores: Array[String] = []
		for identificador in _identificadores_mutacoes:
			identificadores.append(identificador)
		return identificadores


func possui_mutacao(identificador_mutacao: String) -> bool:
	return _identificadores_mutacoes.has(identificador_mutacao)


func adicionar_mutacao(identificador_mutacao: String) -> void:
	_identificadores_mutacoes[identificador_mutacao] = true
