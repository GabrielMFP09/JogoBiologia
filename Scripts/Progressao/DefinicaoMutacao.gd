extends Resource
class_name DefinicaoMutacao

@export var identificador: String = ""
@export_range(0, 100, 1) var custo_pontos_mutacao: int = 0
@export var identificadores_mutacoes_incompativeis: Array[String] = []
