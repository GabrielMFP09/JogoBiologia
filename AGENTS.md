# Diretrizes do projeto

## Visão do jogo

- Jogo de ação roguelite leve, inspirado em *Dead Cells*, desenvolvido na Godot.
- A protagonista é uma planta. Durante as partidas, ela obtém pontos de mutação ao derrotar insetos e pode adquirir adaptações.
- Ao morrer, as mudanças adquiridas passam a fazer parte da espécie, dando continuidade à evolução entre partidas.
- A planta pode recuperar vida em pontos de luz solar por meio da fotossíntese.
- Mutações podem trazer benefícios e custos. Por exemplo, espinhos aumentam a resistência a mordidas e ferem inimigos que atacam, mas reduzem a fotossíntese e os pontos de mutação obtidos.
- Mutações incompatíveis entre si exigem uma escolha: não devem coexistir.
- O combate considera resistências e alcance tanto da protagonista quanto dos inimigos.

## Diretrizes de implementação

- Escreva o código, os identificadores, as mensagens e os comentários em português. Use nomes sem acentos nos identificadores para manter a compatibilidade com as ferramentas; preserve os nomes definidos pelas APIs da Godot, do C# e de outras dependências.
- Use GDScript para sistemas pequenos. Use C# para sistemas de porte médio ou grande.
- Em C#, prefira composição e interfaces. Evite herança, exceto quando necessária para integrar com a Godot.
- Prefira código claro que explique a própria intenção. Escreva comentários apenas em documentação de classes ou métodos quando forem realmente úteis e em trechos cujo funcionamento não esteja claro pelo código.
- Implemente cada funcionalidade com a menor quantidade de mudanças necessária.
- Mantenha as alterações localizadas; evite modificar partes distantes do projeto para atender a um pedido, salvo quando necessário.
- Mantenha a interface simples e fácil de alterar. O projeto é educacional; priorize praticidade em vez de acabamento visual elaborado.

## Rascunho da arquitetura

Esta seção é uma proposta inicial, detalhada em [docs/ARQUITETURA.md](docs/ARQUITETURA.md). O projeto ainda não tem cenas nem fluxo de jogo integrado; o código inicial de progressão está descrito abaixo. Transforme as responsabilidades em cenas, nós, recursos e scripts conforme as funcionalidades forem implementadas. Evite criar abstrações antes de uma necessidade concreta.

### Responsabilidades

- **Fluxo da partida:** iniciar e encerrar uma tentativa e coordenar a transição entre jogo e telas. Não deve concentrar regras de combate ou mutação.
- **Protagonista:** reunir movimento e estado próprio, delegando combate e efeitos de mutação a componentes menores quando necessário.
- **Combate:** resolver alcance, ataques, dano e resistências de forma reutilizável por protagonista e insetos.
- **Mutações e espécie:** representar adaptações e incompatibilidades, aplicar seus efeitos e separar o estado temporário da partida da evolução persistente da espécie.
- **Insetos:** tratar comportamento, combate e derrota; a recompensa de pontos de mutação deve ser comunicada ao sistema responsável pela progressão.
- **Luz solar:** oferecer um ponto de interação para a fotossíntese e a recuperação de vida, sem acoplar a regra de cura à interface.
- **Interface:** apresentar estado e opções do jogo e encaminhar ações do jogador aos sistemas correspondentes; manter apresentação e regras separadas.

### Organização e colaboração entre sistemas

- Use cenas e nós da Godot para compor elementos do jogo. Scripts devem cuidar de responsabilidades claras, sem um controlador central que acumule todas as regras.
- Prefira que os sistemas colaborem por dependências explícitas, composição e interfaces em C#. Use sinais da Godot quando forem adequados para comunicar eventos sem acoplamento direto.
- Mantenha separados os dados da tentativa atual e os dados que persistem na espécie. A implementação de salvamento pode ser definida quando os requisitos estiverem claros.
- Mutações devem poder expressar efeitos e incompatibilidades sem espalhar verificações específicas de cada mutação por combate, protagonista e interface. A forma concreta de definir esses dados ainda será escolhida conforme as primeiras mutações forem implementadas.
- O código de progressão está em `Scripts/Progressao`: estados de tentativa e espécie, recurso de definição de mutação e aquisição com custo em pontos e verificação de incompatibilidades. Os efeitos das mutações ainda não são aplicados nem há transferência automática para a espécie.

### Pendências de projeto

- **TODO — progressão:** definir como as mutações são oferecidas e como resolver conflitos entre mutações da tentativa e da espécie ao morrer. A aquisição de uma mutação já gasta o custo definido no recurso.
- **TODO — incompatibilidades:** definir como apresentar escolhas quando duas mutações não puderem coexistir e se alguma regra de substituição será permitida.
- **TODO — combate:** definir unidades e regras de alcance, tipos de ataque e como resistências afetam o dano.
- **TODO — fotossíntese:** definir como são identificados os pontos de luz, como a interação é iniciada e quais limites ou custos existem para a cura.
- **TODO — persistência:** definir se e quais dados da espécie serão salvos entre sessões.
- **TODO — dados das mutações:** decidir entre recursos da Godot, código ou uma combinação, depois de conhecer as necessidades reais de autoria e edição.

Ao iniciar cada sistema, implemente primeiro o menor caminho funcional e atualize este rascunho quando uma decisão for tomada. Não trate as pendências acima como regras já definidas do jogo.
