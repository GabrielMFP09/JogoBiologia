extends Node2D

@onready var hud: HudTentativa = $CamadaInterface/HudTentativa
@onready var protagonista: ControladorProtagonista = $Protagonista

var estado_tentativa: EstadoTentativa = EstadoTentativa.new()
var sistema_mutacoes: SistemaProgressaoMutacoes = SistemaProgressaoMutacoes.new()
var mutacoes_disponiveis: Array[DefinicaoMutacao] = []


func _ready() -> void:
	_criar_mutacoes()
	protagonista.vida_alterada.connect(hud.mostrar_vida)
	protagonista.morreu.connect(_ao_morrer)
	hud.mutacao_selecionada.connect(_ao_selecionar_mutacao)
	hud.mostrar_vida(protagonista.vida_atual, protagonista.vida_maxima)
	hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
	hud.mostrar_interacao("←/→ ou A/D: mover    ↑ ou W: pular    J: atacar    M: mutações")
	for no_inseto in get_tree().get_nodes_in_group("insetos"):
		var inseto := no_inseto as Inseto
		if is_instance_valid(inseto):
			inseto.derrotado.connect(_ao_derrotar_inseto)


func _unhandled_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("mostrar_mutacoes") and protagonista.vida_atual > 0:
		if hud.mutacoes_estao_visiveis():
			hud.fechar_mutacoes()
		else:
			_mostrar_mutacoes()
		get_viewport().set_input_as_handled()
		return

	if evento.is_action_pressed("pular") and protagonista.vida_atual <= 0:
		get_tree().reload_current_scene()


func _ao_derrotar_inseto(recompensa_pontos: int) -> void:
	estado_tentativa.conceder_pontos_mutacao(recompensa_pontos)
	hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
	hud.mostrar_interacao("Inseto derrotado: +%d pontos de mutação" % recompensa_pontos)


func _ao_morrer() -> void:
	hud.mostrar_interacao("A planta morreu. Pressione ↑ ou W para tentar novamente.")


func _criar_mutacoes() -> void:
	var espinhos := DefinicaoMutacao.new()
	espinhos.identificador = "espinhos"
	espinhos.nome = "Espinhos"
	espinhos.descricao = "Aumenta o dano dos ataques, mas reduz a vida máxima."
	espinhos.custo_pontos_mutacao = 2
	espinhos.bonus_dano_ataque = 4
	espinhos.bonus_vida_maxima = -20
	espinhos.identificadores_mutacoes_incompativeis.append("casca_grossa")

	var casca_grossa := DefinicaoMutacao.new()
	casca_grossa.identificador = "casca_grossa"
	casca_grossa.nome = "Casca grossa"
	casca_grossa.descricao = "Aumenta vida e resistência, mas reduz a velocidade."
	casca_grossa.custo_pontos_mutacao = 3
	casca_grossa.bonus_vida_maxima = 30
	casca_grossa.bonus_velocidade = -45.0
	casca_grossa.bonus_resistencia_dano = 2
	casca_grossa.identificadores_mutacoes_incompativeis.append("espinhos")

	mutacoes_disponiveis = [espinhos, casca_grossa]


func _mostrar_mutacoes() -> void:
	var opcoes: Array[Dictionary] = []
	for mutacao in mutacoes_disponiveis:
		var consulta := sistema_mutacoes.consultar_disponibilidade(estado_tentativa, mutacao)
		var disponibilidade := "disponivel"
		var identificador_conflitante := str(consulta["identificador_mutacao_conflitante"])
		var nome_conflitante := identificador_conflitante
		for mutacao_existente in mutacoes_disponiveis:
			if mutacao_existente.identificador == identificador_conflitante:
				nome_conflitante = mutacao_existente.nome
				break
		match consulta["situacao"]:
			SistemaProgressaoMutacoes.DisponibilidadeMutacao.JA_ADQUIRIDA:
				disponibilidade = "ja_adquirida"
			SistemaProgressaoMutacoes.DisponibilidadeMutacao.INCOMPATIVEL_COM_MUTACAO_EXISTENTE:
				disponibilidade = "incompativel"
			SistemaProgressaoMutacoes.DisponibilidadeMutacao.PONTOS_INSUFICIENTES:
				disponibilidade = "pontos_insuficientes"

		opcoes.append({
			"identificador": mutacao.identificador,
			"nome": mutacao.nome,
			"descricao": mutacao.descricao,
			"custo_pontos": mutacao.custo_pontos_mutacao,
			"disponibilidade": disponibilidade,
			"mutacao_conflitante": nome_conflitante
		})

	hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
	hud.mostrar_mutacoes(opcoes)


func _ao_selecionar_mutacao(identificador: String) -> void:
	for mutacao in mutacoes_disponiveis:
		if mutacao.identificador != identificador:
			continue

		var resultado := sistema_mutacoes.tentar_adquirir(estado_tentativa, mutacao)
		if resultado["situacao"] == SistemaProgressaoMutacoes.SituacaoAquisicaoMutacao.ADQUIRIDA:
			protagonista.aplicar_mutacoes(estado_tentativa.mutacoes)
			hud.mostrar_pontos_mutacao(estado_tentativa.pontos_mutacao)
			hud.fechar_mutacoes()
			hud.mostrar_interacao("Mutação adquirida: %s" % mutacao.nome)
		else:
			_mostrar_mutacoes()
		return
