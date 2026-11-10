extends Resource
class_name DefinicaoMutacao

@export var identificador: String = ""
@export var nome: String = ""
@export_multiline var descricao: String = ""
@export_range(0, 100, 1) var custo_pontos_mutacao: int = 0
@export var identificadores_mutacoes_incompativeis: Array[String] = []
@export var bonus_dano_ataque: int = 0
@export var bonus_vida_maxima: int = 0
@export var bonus_velocidade: float = 0.0
@export var bonus_resistencia_dano: int = 0
