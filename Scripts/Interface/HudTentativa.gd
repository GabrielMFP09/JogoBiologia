extends Control
class_name HudTentativa

signal mutacao_selecionada(identificador: String)
signal painel_mutacoes_fechado

@onready var barra_vida: ProgressBar = %BarraVida
@onready var texto_vida: Label = %TextoVida
@onready var texto_pontos_mutacao: Label = %TextoPontosMutacao
@onready var painel_interacao: PanelContainer = %PainelInteracao
@onready var texto_interacao: Label = %TextoInteracao
@onready var painel_mutacoes: PanelContainer = %PainelMutacoes
@onready var opcoes_mutacao: VBoxContainer = %OpcoesMutacao


func _ready() -> void:
	mostrar_vida(100, 100)
	mostrar_pontos_mutacao(0)
	limpar_interacao()
	painel_mutacoes.hide()


func _unhandled_key_input(evento: InputEvent) -> void:
	if evento.is_action_pressed("ui_cancel") and painel_mutacoes.visible:
		fechar_mutacoes()
		get_viewport().set_input_as_handled()


func mostrar_vida(vida_atual: int, vida_maxima: int) -> void:
	var limite_vida := maxi(vida_maxima, 0)
	var vida := clampi(vida_atual, 0, limite_vida)

	barra_vida.max_value = maxi(limite_vida, 1)
	barra_vida.value = vida
	texto_vida.text = "%d / %d" % [vida, limite_vida]


func mostrar_pontos_mutacao(pontos: int) -> void:
	texto_pontos_mutacao.text = "Pontos de mutação: %d" % maxi(pontos, 0)


func mostrar_interacao(texto: String) -> void:
	texto_interacao.text = texto
	painel_interacao.show()


func limpar_interacao() -> void:
	texto_interacao.text = ""
	painel_interacao.hide()


func mostrar_mutacoes(mutacoes: Array[Dictionary]) -> void:
	_limpar_opcoes_mutacao()

	if mutacoes.is_empty():
		var aviso := Label.new()
		aviso.text = "Nenhuma mutação disponível."
		aviso.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		opcoes_mutacao.add_child(aviso)

	for dados_mutacao in mutacoes:
		_adicionar_opcao_mutacao(dados_mutacao)

	painel_mutacoes.show()


func fechar_mutacoes() -> void:
	painel_mutacoes.hide()
	painel_mutacoes_fechado.emit()


func mutacoes_estao_visiveis() -> bool:
	return painel_mutacoes.visible


func _adicionar_opcao_mutacao(dados: Dictionary) -> void:
	var identificador := str(dados.get("identificador", ""))
	var nome := str(dados.get("nome", identificador))
	var descricao := str(dados.get("descricao", ""))
	var custo := maxi(int(dados.get("custo_pontos", 0)), 0)
	var disponibilidade := str(dados.get("disponibilidade", "disponivel"))
	var motivo := _texto_indisponibilidade(disponibilidade, dados)

	var botao := Button.new()
	botao.custom_minimum_size = Vector2(0, 82)
	botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	botao.text = "%s  -  %d pontos\n%s" % [nome, custo, descricao]
	if not motivo.is_empty():
		botao.text += "\n" + motivo
	botao.disabled = disponibilidade != "disponivel" or identificador.is_empty()
	botao.pressed.connect(_selecionar_mutacao.bind(identificador))
	opcoes_mutacao.add_child(botao)
	if opcoes_mutacao.get_child_count() == 1:
		botao.grab_focus()


func _texto_indisponibilidade(disponibilidade: String, dados: Dictionary) -> String:
	match disponibilidade:
		"ja_adquirida":
			return "Já adquirida"
		"incompativel":
			var conflito := str(dados.get("mutacao_conflitante", "outra mutacao"))
			return "Incompatível com: %s" % conflito
		"pontos_insuficientes":
			return "Pontos de mutação insuficientes"
		_:
			return ""


func _selecionar_mutacao(identificador: String) -> void:
	mutacao_selecionada.emit(identificador)


func _limpar_opcoes_mutacao() -> void:
	for filho in opcoes_mutacao.get_children():
		opcoes_mutacao.remove_child(filho)
		filho.queue_free()

