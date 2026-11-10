# Arquitetura inicial

Este documento registra uma proposta inicial para orientar as implementações. O projeto já tem um recorte inicial de progressão, descrito em "Código inicial", mas ainda não tem cenas nem fluxo de jogo integrado. Os limites abaixo são responsabilidades desejadas, não uma exigência de criar desde já uma cena ou classe para cada item.

## Mapa de responsabilidades

| Área | Responsabilidade | Limite importante |
| --- | --- | --- |
| Fluxo da partida | Iniciar e encerrar uma tentativa e coordenar transições de tela. | Não concentra regras de combate, mutação ou cura. |
| Protagonista | Movimento e estado específico da planta. | Delega regras compartilhadas a sistemas menores quando necessário. |
| Combate | Alcance, ataques, dano e resistências. | Deve servir tanto à protagonista quanto aos insetos. |
| Mutações e espécie | Adaptações, incompatibilidades e evolução da espécie. | Distingue efeitos da tentativa atual de dados persistentes. |
| Insetos | Comportamento, combate e derrota. | A recompensa por derrota é encaminhada à progressão, sem depender da interface. |
| Luz solar | Interação com pontos de luz e recuperação por fotossíntese. | A regra de cura não pertence à interface. |
| Interface | Apresentação do estado e encaminhamento das escolhas do jogador. | Não decide regras de jogo. |

## Colaboração entre áreas

- Componha entidades com cenas e nós da Godot. Evite um controlador central que acumule regras não relacionadas.
- Prefira composição para colaborar entre sistemas. Use sinais da Godot quando forem úteis para comunicar eventos sem referência direta entre quem publica e quem recebe.
- Mantenha os dados da tentativa atual distintos dos dados que passam a fazer parte da espécie. O momento e as regras exatas dessa transição continuam em aberto.
- Evite verificações específicas para cada mutação espalhadas por combate, protagonista e interface. Mantenha os efeitos e as incompatibilidades próximos da definição de mutação; a forma concreta dessa definição será escolhida após as primeiras necessidades de autoria ficarem claras.
- Comece cada área com o menor caminho funcional. Introduza interfaces, recursos ou serviços compartilhados apenas quando um caso real justificar a separação.

## Código inicial

O primeiro recorte implementado fica em `Scripts/Progressao`, em GDScript:

- `DefinicaoMutacao.gd` é um recurso Godot com identificador e identificadores de mutações incompatíveis.
- `EstadoTentativa.gd` guarda pontos recebidos e mutações adquiridas na tentativa.
- `EstadoEspecie.gd` reserva o estado de mutações estabelecidas para a espécie; ainda não há salvamento nem transferência automática.
- `SistemaProgressaoMutacoes.gd` consulta a disponibilidade de uma mutação sem alterar o estado e a registra quando ela não foi adquirida antes, não contradiz uma mutação da tentativa atual e há pontos suficientes para pagar seu custo. Os pontos são descontados apenas quando a aquisição é concluída. As consultas retornam um dicionário com `situacao` e `identificador_mutacao_conflitante`.

O custo da mutação é definido em `DefinicaoMutacao` e pago no momento da aquisição. O recorte ainda não define como as mutações são oferecidas, seus efeitos nos atributos, nem como resolver incompatibilidades entre a tentativa e a espécie. Esses comportamentos permanecem pendentes.

## Interface inicial

`Cenas/Interface/HudTentativa.tscn` compõe o primeiro recorte de interface, com vida, pontos de mutação, uma mensagem de interação e um painel para escolhas de mutação. O script `Scripts/Interface/HudTentativa.gd` só apresenta os dados que recebe e emite `mutacao_selecionada` quando uma opção disponível é escolhida. A cena que hospedar o HUD deve conectá-lo aos estados da tentativa e à progressão; essas regras não pertencem ao HUD.

Para atualizar a apresentação, a cena hospedeira pode chamar `mostrar_vida(vida_atual, vida_maxima)`, `mostrar_pontos_mutacao(pontos)` e `mostrar_interacao(texto)`. A lista passada para `mostrar_mutacoes` usa dicionários com `identificador`, `nome`, `descricao`, `custo_pontos` e `disponibilidade`. Os valores esperados para `disponibilidade` são `disponivel`, `ja_adquirida`, `incompativel` e `pontos_insuficientes`; `mutacao_conflitante` é opcional e só complementa a mensagem de incompatibilidade. Esta conversão mantém o HUD independente das classes de progressão.

## Primeira cena jogável

`Cenas/Mundo/Partida.tscn` é a cena principal configurada no projeto. Ela instancia a protagonista, plataformas provisórias e o HUD. `ControladorProtagonista.gd` trata apenas deslocamento horizontal e pulo usando as ações padrão `ui_left`, `ui_right` e `ui_accept` (setas e espaço na configuração padrão do Godot). A protagonista usa `CharacterBody2D` e uma forma de colisão separada do nó `VisualTemporario`; os polígonos desse nó são substitutos que podem ser trocados por `Sprite2D` ou `AnimatedSprite2D` posteriormente.

O percurso ainda não inclui inimigos, combate, vida funcional, pontos recebidos ou interação com luz. A barra e os pontos do HUD são apenas valores iniciais até esses sistemas serem conectados.

## Percurso geral previsto

1. Uma tentativa começa e a protagonista explora e combate insetos.
2. Derrotar insetos pode conceder pontos de mutação; a regra e o momento de uso desses pontos ainda precisam ser definidos.
3. Mutações alteram características da planta, incluindo benefícios, custos e incompatibilidades.
4. Pontos de luz permitem recuperar vida por fotossíntese, conforme regras ainda pendentes.
5. Ao morrer, mudanças da tentativa passam para a espécie, conforme uma regra de transição a definir.

Este percurso apenas conecta os elementos já previstos para o jogo. Ele não determina telas, controles, quantidade de recursos, formato de salvamento ou regras adicionais.

## Decisões pendentes

- **TODO — progressão:** definir como as opções de mutação são apresentadas e como resolver conflitos entre mutações da tentativa e da espécie ao morrer.
- **TODO — incompatibilidades:** definir como a escolha entre mutações incompatíveis funciona e se é possível substituir uma mutação já adquirida.
- **TODO — combate:** definir unidades e regras de alcance, tipos de ataque e como resistências afetam o dano.
- **TODO — fotossíntese:** definir como pontos de luz são identificados, como a interação começa e quais limites ou custos se aplicam à cura.
- **TODO — persistência:** decidir se os dados da espécie são salvos entre sessões e quais dados isso inclui.
- **TODO — autoria das mutações:** escolher entre recursos da Godot, código ou uma combinação quando os requisitos para criar e editar mutações estiverem claros.

Atualize este rascunho quando uma decisão for tomada. As pendências não são regras já definidas para o jogo.
