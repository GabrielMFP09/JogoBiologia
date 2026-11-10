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

O custo é definido em `DefinicaoMutacao` e pago na aquisição. A tentativa já oferece duas mutações e aplica seus efeitos aos atributos da protagonista; a passagem dos efeitos para a espécie continua pendente.

## Interface e mutações na tentativa

`Cenas/Interface/HudTentativa.tscn` apresenta vida, pontos de mutação, mensagens de interação e opções de mutação. `Partida.gd` conecta o HUD aos estados da tentativa e à progressão; o HUD apenas encaminha a escolha.

Para atualizar a apresentação, a cena hospedeira pode chamar `mostrar_vida(vida_atual, vida_maxima)`, `mostrar_pontos_mutacao(pontos)` e `mostrar_interacao(texto)`. A lista passada para `mostrar_mutacoes` usa dicionários com `identificador`, `nome`, `descricao`, `custo_pontos` e `disponibilidade`. Os valores esperados para `disponibilidade` são `disponivel`, `ja_adquirida`, `incompativel` e `pontos_insuficientes`; `mutacao_conflitante` é opcional e só complementa a mensagem de incompatibilidade. Esta conversão mantém o HUD independente das classes de progressão.

## Cena jogável e combate inicial

`Cenas/Mundo/Partida.tscn` instancia a protagonista, plataformas, três insetos e o HUD. A protagonista usa `plantinha.png`; os inimigos usam `vespinha.png`, `louvaDEUS.png` e `lesminha.png`. Os sprites são ampliados com filtragem nearest para preservar os pixels.

As setas movem a planta, Espaço pula, J ataca e M abre as mutações. Insetos perseguem a protagonista dentro de uma distância de percepção, atacam dentro do alcance configurado e concedem pontos ao serem derrotados. O dano recebido é reduzido pela resistência, com dano mínimo de um ponto. Insetos têm vida, velocidade, alcance, resistência e recompensas diferentes.

As duas mutações iniciais são criadas por `Partida.gd` como recursos: Espinhos aumenta o dano e reduz a vida máxima; Casca grossa aumenta vida e resistência e reduz velocidade. São incompatíveis entre si. Os efeitos ficam em `DefinicaoMutacao` e a protagonista agrega os valores das mutações adquiridas. Os pontos e mutações duram apenas durante a tentativa; persistência e transferência para a espécie continuam pendentes.

## Percurso geral previsto

1. Uma tentativa começa e a protagonista explora e combate insetos.
2. Derrotar cada inseto concede a recompensa configurada na cena, e esses pontos podem ser gastos em mutações durante a tentativa.
3. As mutações iniciais alteram dano, vida, velocidade e resistência, com incompatibilidade definida nos próprios recursos.
4. Pontos de luz permitem recuperar vida por fotossíntese, conforme regras ainda pendentes.
5. Ao morrer, mudanças da tentativa passam para a espécie, conforme uma regra de transição a definir.

Este percurso apenas conecta os elementos já previstos para o jogo. Ele não determina telas, controles, quantidade de recursos, formato de salvamento ou regras adicionais.

## Decisões pendentes

- **TODO — progressão:** definir como as mutações da tentativa passam a fazer parte da espécie ao morrer.
- **TODO — incompatibilidades:** a tentativa não permite substituir uma mutação adquirida; ainda falta definir como conflitos com mutações persistentes da espécie serão tratados.
- **TODO — combate:** expandir os ataques além do golpe corpo a corpo inicial e revisar os valores de alcance, dano e resistência durante o balanceamento.
- **TODO — fotossíntese:** definir como pontos de luz são identificados, como a interação começa e quais limites ou custos se aplicam à cura.
- **TODO — persistência:** decidir se os dados da espécie são salvos entre sessões e quais dados isso inclui.
- **TODO — autoria das mutações:** as primeiras definições são criadas em código; avaliar recursos `.tres` quando a autoria de mais mutações exigir edição no inspetor.

Atualize este rascunho quando uma decisão for tomada. As pendências não são regras já definidas para o jogo.
