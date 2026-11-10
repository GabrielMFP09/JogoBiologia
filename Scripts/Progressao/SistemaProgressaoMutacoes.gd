extends RefCounted
class_name SistemaProgressaoMutacoes

enum SituacaoAquisicaoMutacao {
	ADQUIRIDA,
	JA_ADQUIRIDA,
	INCOMPATIVEL_COM_MUTACAO_EXISTENTE,
	PONTOS_INSUFICIENTES
}

enum DisponibilidadeMutacao {
	DISPONIVEL,
	JA_ADQUIRIDA,
	INCOMPATIVEL_COM_MUTACAO_EXISTENTE,
	PONTOS_INSUFICIENTES
}


func consultar_disponibilidade(
	estado_tentativa: EstadoTentativa,
	mutacao: DefinicaoMutacao
) -> Dictionary:
	assert(is_instance_valid(estado_tentativa), "O estado da tentativa e obrigatorio.")
	assert(is_instance_valid(mutacao), "A definicao da mutacao e obrigatoria.")
	assert(not mutacao.identificador.strip_edges().is_empty(), "Uma mutacao precisa ter um identificador.")
	assert(mutacao.custo_pontos_mutacao >= 0, "O custo de uma mutacao nao pode ser negativo.")

	var resultado := {
		"situacao": DisponibilidadeMutacao.DISPONIVEL,
		"identificador_mutacao_conflitante": ""
	}

	if estado_tentativa.possui_mutacao(mutacao.identificador):
		resultado["situacao"] = DisponibilidadeMutacao.JA_ADQUIRIDA
		return resultado

	for mutacao_atual in estado_tentativa.mutacoes:
		if _esta_em_conflito(mutacao, mutacao_atual):
			resultado["situacao"] = DisponibilidadeMutacao.INCOMPATIVEL_COM_MUTACAO_EXISTENTE
			resultado["identificador_mutacao_conflitante"] = mutacao_atual.identificador
			return resultado

	if estado_tentativa.pontos_mutacao < mutacao.custo_pontos_mutacao:
		resultado["situacao"] = DisponibilidadeMutacao.PONTOS_INSUFICIENTES

	return resultado


func tentar_adquirir(estado_tentativa: EstadoTentativa, mutacao: DefinicaoMutacao) -> Dictionary:
	var resultado_disponibilidade := consultar_disponibilidade(estado_tentativa, mutacao)
	var disponibilidade: int = resultado_disponibilidade["situacao"]
	var identificador_conflitante: String = resultado_disponibilidade["identificador_mutacao_conflitante"]

	if disponibilidade != DisponibilidadeMutacao.DISPONIVEL:
		var situacao_aquisicao: int
		match disponibilidade:
			DisponibilidadeMutacao.JA_ADQUIRIDA:
				situacao_aquisicao = SituacaoAquisicaoMutacao.JA_ADQUIRIDA
			DisponibilidadeMutacao.INCOMPATIVEL_COM_MUTACAO_EXISTENTE:
				situacao_aquisicao = SituacaoAquisicaoMutacao.INCOMPATIVEL_COM_MUTACAO_EXISTENTE
			DisponibilidadeMutacao.PONTOS_INSUFICIENTES:
				situacao_aquisicao = SituacaoAquisicaoMutacao.PONTOS_INSUFICIENTES
		return {
			"situacao": situacao_aquisicao,
			"identificador_mutacao_conflitante": identificador_conflitante
		}

	var pontos_gastos := estado_tentativa.gastar_pontos_mutacao(mutacao.custo_pontos_mutacao)
	assert(pontos_gastos, "A tentativa nao possui pontos de mutacao suficientes.")
	estado_tentativa.adicionar_mutacao(mutacao)
	return {
		"situacao": SituacaoAquisicaoMutacao.ADQUIRIDA,
		"identificador_mutacao_conflitante": ""
	}


func _esta_em_conflito(candidata: DefinicaoMutacao, existente: DefinicaoMutacao) -> bool:
	if candidata.identificadores_mutacoes_incompativeis.has(existente.identificador):
		return true

	return existente.identificadores_mutacoes_incompativeis.has(candidata.identificador)
