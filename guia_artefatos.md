# 🗺️ Guia de Implementação dos Artefatos — Ecos_TG

Este guia não contém código. Ele é um mapa de direções para você seguir, implementando cada artefato na ordem correta, construindo a infraestrutura modular à medida que avança.

---

## 🏗️ Infraestrutura Modular (Faça ANTES de qualquer artefato)

Antes de criar os artefatos, você precisa preparar o terreno. Cada item abaixo é uma fundação que muitos artefatos vão usar. Construir agora evita retrabalho depois.

### 1. Novos campos no `Artefato_data` (Resource)

O seu Resource atual tem `dano_add`, `dano_mult`, `vida_max_add`, etc. Você vai precisar adicionar:

- **`limite`** (int): Quantas cópias desse artefato o jogador pode ter. Use `-1` para "sem limite".
- **`raridade`** (String ou Enum): `"Comum"`, `"Incomum"`, `"Raro"`, `"Epico"`, `"Lendario"`, `"Unico"`.
- **`chance_critico_add`** (float): Para artefatos que adicionam chance de crítico.
- **`atk_speed_mult`** (float): Para artefatos que alteram velocidade de ataque. Valor padrão: `1.0`.
- **`reducao_dano`** (float): Porcentagem de redução de dano recebido. Valor padrão: `0.0`.
- **`tamanho_magia_mult`** (float): Multiplicador de tamanho de magias. Valor padrão: `1.0`.

> [!TIP]
> Use valores padrão inteligentes! Se `dano_mult` padrão é `1.0` e `speed_mult` padrão é `1.0`, artefatos que não mexem nesses stats simplesmente não alteram nada na fórmula.

### 2. Novos campos no `RunData`

O `RunData` é o cérebro da run. Adicione variáveis globais que serão recalculadas pelo `calcular_artefatos()`:

- **`reducao_dano`** (float): Total de redução de dano acumulado. Começa em `0.0`.
- **`atk_speed_mult`** (float): Multiplicador total de velocidade de ataque. Começa em `1.0`.
- **`tamanho_magia_mult`** (float): Multiplicador total do tamanho das magias. Começa em `1.0`.

Lembre-se de atualizar o `calcular_artefatos()` para somar/multiplicar esses novos campos ao iterar pela lista de artefatos, seguindo o mesmo padrão que já existe para `dano_add`, `vida_max_add`, etc. E lembre de resetar tudo no `resetar_run()`.

### 3. Sistema de Limite de Artefatos

Dentro da função `adicionar_artefato()` do RunData, **antes** de adicionar ao array, faça uma verificação:
- Conte quantas cópias daquele artefato específico já existem em `artefatos_coletados`.
- Se a quantidade já é igual ao `limite` do artefato, **não adicione** e retorne (opcionalmente emita um sinal de "inventário cheio" para mostrar feedback na UI).
- Se o limite for `-1`, sempre adicione.

### 4. Barramento de Eventos (Signal Bus) — A peça mais importante!

Muitos artefatos reativos precisam "ouvir" coisas que acontecem no jogo (ex: "o jogador critou", "o jogador causou dano", "o jogador ficou parado"). Para isso, crie um **barramento de sinais** (Event Bus).

**Onde criar:** No próprio `RunData` (já é um Singleton acessível de qualquer lugar).

**Sinais que você vai precisar ao longo do guia:**
- `sinal_critico(dano, posicao_inimigo, direcao)` — Emitido quando qualquer fonte de dano causa um golpe crítico.
- `sinal_dano_causado(dano, posicao_inimigo)` — Emitido quando qualquer fonte de dano acerta um inimigo.
- `sinal_dano_queimadura(dano, inimigo)` — Emitido quando a queimadura causa dano.

**Quem emite:** Os scripts que causam dano (armas, projéteis, debuffs). No momento certo (ex: dentro do `take_damage` da hurtbox, ou no projétil ao acertar), o script chama `RunData.sinal_critico.emit(...)`.

**Quem ouve:** Os artefatos reativos se conectam a esses sinais quando são coletados.

> [!IMPORTANT]
> Não precisa criar todos os sinais agora! Crie cada sinal apenas quando chegar no artefato que precisa dele. Mas **reserve esse espaço** no RunData desde já.

---

## ✅ Nível 1 — Artefatos Puramente Numéricos

Estes artefatos funcionam apenas com os campos do `Artefato_data` e o `calcular_artefatos()` do RunData. São os mais simples: crie o arquivo `.tres` no editor da Godot, preencha os campos, e pronto.

---

### 1. 💪 Whey Protein (Comum | Sem limite)
**Efeito:** +10 de vida máxima.

**Como fazer:**
- Crie um novo Resource (`.tres`) do tipo `Artefato_data`.
- Preencha `vida_max_add = 10`.
- Todos os outros valores ficam nos seus padrões (dano 0, mult 1, etc.).
- Pronto. O `calcular_artefatos()` já soma `vida_max_add`. Sem limite, o jogador pode empilhar quantos quiser.

**O que testar:** Pegue 3 Wheys e veja se a vida máxima subiu 30.

---

### 2. 🔮 Cristal de Mana (Comum | Sem limite)
**Efeito:** +10% de dano.

**Como fazer:**
- Crie um `.tres` com `dano_mult = 0.1`.
- Pronto. O `calcular_artefatos()` já acumula `dano_mult`.

> [!WARNING]
> Verifique como o seu `calcular_artefatos()` trata o `dano_multiplicador`. Hoje ele faz `mult += i.dano_mult`, ou seja, ele **soma** os multiplicadores. Se o jogador pegar 2 Cristais (0.1 + 0.1 = 0.2), o multiplicador total fica 0.2. Certifique-se que na hora de aplicar o dano, a fórmula seja `dano * (1 + multiplicador)` e não `dano * multiplicador`, senão com 0 artefatos o dano seria zerado!

**O que testar:** Pegue 1 Cristal e veja se o dano aumentou ~10%.

---

### 3. 👓 Lente de Contato (Comum | Sem limite)
**Efeito:** +5% de chance de crítico.

**Como fazer:**
- Use o novo campo `chance_critico_add` que você criou na infraestrutura.
- Crie um `.tres` com `chance_critico_add = 5`.
- No `calcular_artefatos()`, some o `chance_critico_add` de todos os artefatos e aplique no `RunData.chance_critico`.

**O que testar:** Com `chance_critico` base em 5, pegue 2 Lentes. A chance deve ir para 15.

---

### 4. 🧃 O Suco (Raro | Limite: 10)
**Efeito:** +10% de vida máxima.

**Como fazer:**
- Crie um `.tres` com `vida_max_mult = 1.1` e `limite = 10`.
- O `calcular_artefatos()` já multiplica `vida_max_mult` no segundo loop.
- O sistema de limite (que você criou na infraestrutura) impede de pegar mais de 10.

**O que testar:** Com 100 de vida base, pegue 1 Suco. Vida deve ir para 110. Tente pegar o 11° e ele deve ser recusado.

---

### 5. 🔫 Coldre do Xerife (Incomum | Limite: 5)
**Efeito:** +10% de velocidade de ataque.

**Como fazer:**
- Use o novo campo `atk_speed_mult` no Artefato_data. Valor: `0.9` (reduzir o cooldown em 10% = atacar 10% mais rápido).
- No `calcular_artefatos()`, acumule o `atk_speed_mult` dos artefatos e salve no `RunData.atk_speed_mult`.
- No Player, onde o `AttackTimer.wait_time` é definido, multiplique o cooldown base pelo `RunData.atk_speed_mult`.
- Exemplo conceitual: se o cooldown base da arma é 0.5s e o jogador tem 2 Coldres, o wait_time seria `0.5 * 0.9 * 0.9 = 0.405s`.

**O que testar:** Segure o tiro e veja se a cadência aumenta com mais Coldres.

---

## ⚠️ Nível 2 — Artefatos Modificadores

Estes artefatos mudam **regras** do jogo. Precisam de novas variáveis no RunData e de lógica adicional em scripts existentes. A função `efeito()` do Artefato_data começa a ser útil aqui.

---

### 6. 🛡️ Armadura Pesada de Titânio (Épico | Limite: 1)
**Efeito:** -50% de velocidade, -25% de dano recebido.

**Como fazer:**
- Crie o `.tres` com `speed_mult = 0.5` e `reducao_dano = 0.25`.
- O `calcular_artefatos()` já cuida do `speed_mult`. Adicione a lógica para acumular `reducao_dano` também.
- **Onde aplicar a redução de dano:** Na função `take_damage` do **Player** (`player.gd`). Antes de subtrair da vida, calcule: `quantidade_real = quantidade * (1.0 - RunData.reducao_dano)`.

**O que testar:** Tome dano de um inimigo que dá 100. Com a armadura, deve tirar 75.

---

### 7. 🍄 Cogumelo Esquisito (Raro | Sem limite)
**Efeito:** Tamanho das magias +200%, mas ocasionalmente uma sai pela culatra.

**Como fazer:**
- Crie o `.tres` com `tamanho_magia_mult = 3.0` (200% de aumento = 3x o tamanho original).
- No `calcular_artefatos()`, acumule e salve em `RunData.tamanho_magia_mult`.
- Nas armas/magias que instanciam projéteis, multiplique o `scale` pelo `RunData.tamanho_magia_mult`.
- **"Sai pela culatra":** Na função que dispara a magia, adicione uma chance pequena (ex: 10%) de que ao invés de ir na direção do mouse, a magia vá na direção **oposta** (inverta o vetor de direção) ou cause dano no próprio jogador.

**O que testar:** As magias devem ser gigantes. De vez em quando, uma deve ir para trás ou machucar o jogador.

---

### 8. 💎 Cristal Corrompido de Mana (Raro | Limite: 1)
**Efeito:** Dobro de dano, mas vida máxima é SEMPRE metade. Itens de vida dão metade.

**Como fazer:**
- Este é um artefato que muda **regras**, não apenas números. A melhor abordagem:
- Adicione uma flag booleana no RunData: `cristal_corrompido_ativo = false`.
- Na função `efeito()` deste artefato, ative a flag.
- Aplique `dano_mult = 1.0` (dobrar = multiplicar por 2, mas como o mult é somado, coloque o valor que faça o total ser 2x).
- **Onde aplicar a maldição da vida:**
  - No `calcular_artefatos()`, **depois** de calcular a vida máxima final, se `cristal_corrompido_ativo` for true, divida `vida_max` por 2.
  - Na função `adicionar_artefato()`, onde você faz `vida_atual += artefato.vida_max_add`, se a flag estiver ativa, adicione apenas metade.

> [!CAUTION]
> Cuidado com a ordem! A vida deve ser cortada pela metade **depois** de todos os outros artefatos de vida terem sido calculados. Caso contrário, um Whey Protein poderia dar 10 de vida e depois o Cristal cortar, dando a impressão de que o Whey dá 5.

**O que testar:** Pegue o Cristal. A vida cai pela metade imediatamente. Depois pegue um Whey (+10 vida) e veja se ele dá apenas +5.

---

### 9. 🔨 Prensa Hidráulica (Lendário | Limite: 1)
**Efeito:** Ataque MUITO lento, apenas 1 projétil, dano ENORME, bala minúscula.

**Como fazer:**
- Este artefato modifica múltiplas coisas ao mesmo tempo. A abordagem mais modular:
- Adicione uma flag no RunData: `prensa_hidraulica_ativa = false`.
- Na função `efeito()`, ative a flag.
- **Onde aplicar as mudanças:**
  - No `calcular_upgrades()` de cada arma, se a flag estiver ativa: force `tiros_por_burst = 1`, `bursts = 1`.
  - No Player, multiplique o `AttackTimer.wait_time` por um valor alto (ex: 3x ou 4x mais lento).
  - No `disparar_burst()` ou equivalente de cada arma, se a flag estiver ativa: multiplique o dano por um valor grande (ex: 5x) e reduza o scale do projétil (ex: `Vector2(0.3, 0.3)`).

> [!IMPORTANT]
> Como a Prensa afeta **todas** as armas igualmente, considere centralizar essa lógica. Uma boa opção é criar uma função `aplicar_modificadores_globais()` no RunData que é chamada no momento do disparo, ao invés de espalhar `if`s por todas as armas.

**O que testar:** Ataque fica extremamente lento, sai apenas 1 bala pequena, mas ela dá dano absurdo.

---

## 🔥 Nível 3 — Artefatos Reativos (Baseados em Eventos)

Estes artefatos **reagem** a coisas que acontecem no jogo. É aqui que o **Barramento de Sinais** do RunData entra em ação.

**Padrão Geral para artefatos reativos:**
1. O artefato precisa de um **script próprio** (`.gd`) que herda de `Artefato_data`.
2. Na função `efeito()` do artefato, ele se conecta ao sinal relevante do RunData.
3. A função callback executa o efeito especial.

> [!IMPORTANT]
> Antes de começar os artefatos abaixo, implemente pelo menos o sinal `sinal_critico` e o sinal `sinal_dano_causado` no RunData. Depois, vá nos scripts que causam dano (hurtbox, projéteis) e faça eles emitirem esses sinais no momento certo.

---

### 10. 🌱 Plantinha Fofinha (Comum | Sem limite)
**Efeito:** Ao ficar parado em combate, recupera 1% de vida por segundo.

**Complexidade:** Média-Baixa (não precisa de sinal, precisa de timer).

**Como fazer:**
- Este artefato funciona com um **Timer** ao invés de sinais.
- Na função `efeito()`, crie um Timer no **Player** (ou no RunData) que dispara a cada 1 segundo.
- O callback do Timer verifica: o Player está com `velocity == Vector2.ZERO`? Se sim, cure 1% da `vida_max`.
- Se o jogador tiver 2 Plantinhas, o efeito deve curar 2% (empilhável).
- **Alternativa mais simples:** Ao invés de criar um Timer no `efeito()`, adicione uma variável no RunData tipo `cura_parado_por_segundo` (float). A Plantinha apenas soma 1.0 nesse valor via `calcular_artefatos()`. No script do Player, dentro do `_physics_process`, verifique se a velocidade é zero e se sim, cure `RunData.cura_parado_por_segundo * (RunData.vida_max * 0.01) * delta`.

**O que testar:** Fique parado perto de inimigos. A vida deve subir devagar. Ande e pare — só cura quando parado.

---

### 11. 👢 Botina do Pé Rapado (Incomum | Limite: 5)
**Efeito:** Ganha boost de velocidade ao causar QUALQUER crítico.

**Sinal necessário:** `sinal_critico`

**Como fazer:**
- Na função `efeito()`, conecte-se ao `RunData.sinal_critico`.
- Quando o sinal disparar, aumente temporariamente o `RunData.speed_calculado` (ex: +50% por 2 segundos).
- Use um Timer para reverter o speed após a duração.
- Com múltiplas Botinas, decida: o boost empilha (mais velocidade) ou apenas reseta o timer (mesma velocidade, mais tempo)?

> [!TIP]
> Para o boost temporário, uma abordagem limpa é ter uma variável separada no RunData tipo `speed_bonus_temporario`. O Player usa `RunData.speed_calculado + RunData.speed_bonus_temporario` para se mover. Assim você não precisa ficar alterando e revertendo o speed base.

**O que testar:** Ataque um inimigo. Quando critar, o jogador deve ter um burst de velocidade visível por alguns segundos.

---

### 12. 😎 Óculos de Sol (Comum | Condicional: ter arma de fogo)
**Efeito:** Se cura em uma porcentagem do dano de queimadura.

**Sinal necessário:** `sinal_dano_queimadura`

**Como fazer:**
- Primeiro, no script da `queimadura.gd`, depois de causar o dano, emita `RunData.sinal_dano_queimadura.emit(dano_final, get_parent())`.
- Na função `efeito()` do artefato, conecte-se a esse sinal.
- O callback calcula uma porcentagem do dano causado (ex: 10%) e chama a função `curar()` do Player.
- **Condição "ter arma de fogo":** Na hora de oferecer o artefato na loja/drop, verifique se a arma atual do jogador é de fogo. Se não for, não ofereça.

**O que testar:** Queime um inimigo e observe a vida do jogador subindo aos poucos.

---

### 13. 🤠 Chapéu do Cowboi (Épico | Limite: 2)
**Efeito:** Ao causar crítico, solta um "IHAAAAA" e lança uma bala que causa crítico garantido na direção do inimigo.

**Sinal necessário:** `sinal_critico(dano, posicao_inimigo, direcao)`

**Como fazer:**
- Na função `efeito()`, conecte-se ao `RunData.sinal_critico`.
- O callback recebe a posição do inimigo que foi atingido.
- Ele instancia um projétil especial (pode ser o mesmo projétil do míssil mágico, ou um novo) na posição do **Player**.
- Calcula a direção do Player até o inimigo.
- Chama `start()` do projétil com `critico = true` forçado (garantido) e um dano base que você define.
- **O "IHAAAAA":** Use um `AudioStreamPlayer` para tocar um som. Pode ser adicionado ao Player ou ao próprio projétil.
- **Com 2 Chapéus:** Lança 2 balas? Ou 1 bala com dano dobrado? Decida e documente.

> [!WARNING]
> Cuidado com loop infinito! Se a bala do Chapéu acertar o inimigo e critar, ela pode disparar OUTRA bala do Chapéu, que crita de novo, e assim infinitamente. Adicione uma flag tipo `bala_do_chapeu = true` no projétil e não emita `sinal_critico` quando esse projétil acertar.

**O que testar:** Acerte um inimigo com crítico. Uma bala extra deve sair na direção dele com "IHAAAAA". Verifique que não há loop infinito.

---

### 14. ⏱️ Relógio de Bolso (Único — Boss Drop | Limite: 1)
**Efeito:** Ao causar dano, chance de atirar uma magia e outra arma.

**Sinal necessário:** `sinal_dano_causado(dano, posicao_inimigo)`

**Como fazer:**
- Na função `efeito()`, conecte-se ao `RunData.sinal_dano_causado`.
- O callback rola um dado (ex: 10% de chance).
- Se ativou, ele busca uma magia aleatória das magias disponíveis e a instancia na posição do Player, direcionada ao inimigo.
- Opcionalmente, também dispara a arma secundária (`RunData.armas[1]`) se existir.
- **Magia aleatória:** Você pode manter uma lista de cenas de magias no RunData ou no próprio artefato, e escolher uma com `pick_random()`.

> [!WARNING]
> Mesmo cuidado do Chapéu: se a magia disparada pelo Relógio causar dano, ela pode ativar o Relógio de novo. Use uma flag `disparado_por_relogio` para evitar recursão.

**O que testar:** Ataque inimigos normalmente. De vez em quando, uma magia aleatória deve sair "grátis".

---

### 15. 🛡️ Égide (Épico | Limite: 1)
**Efeito:** Um escudo que protege de ataques. Se beneficia dos seus projéteis.

**Complexidade:** Alta — precisa de um sistema novo.

**Como fazer:**
- Este artefato é fundamentalmente diferente. Ele cria uma **entidade no mundo** (uma Area2D visual ao redor do Player).
- Na função `efeito()`, instancie uma cena de escudo (`Egide.tscn`) como filho do Player.
- **O escudo como Area2D:**
  - Detecta projéteis inimigos que entram na área e os destrói (ou reduz o dano).
  - Tem uma "vida" própria (ex: 50 HP de escudo). Ao absorver dano, perde vida. Se chegar a 0, desaparece temporariamente.
  - Regenera depois de um tempo sem levar dano.
- **"Se beneficia dos seus projéteis":** Quando os projéteis do Player passam por dentro da Égide (Area2D detecta), eles ganham um buff (dano extra, tamanho, etc.). Isso é feito fazendo a Égide detectar área do seu próprio projétil e modificar as variáveis dele.

> [!CAUTION]
> Este é o artefato mais complexo em termos de cena. Vai precisar de uma cena `.tscn` própria com: CollisionShape2D, Sprite/Animação visual, Script de lógica, Timers para regeneração. Planeje bem antes de implementar.

**O que testar:** Veja o escudo ao redor do Player. Leve dano e veja o escudo absorver. Atire através do escudo e veja os projéteis ficarem mais fortes.

---

### 16. 🥔 Batata Copiadora (Raro | Sem limite)
**Efeito:** A cada minuto, copia aleatoriamente um artefato que você já tem.

**Complexidade:** Alta — precisa de Timer + duplicação de recursos.

**Como fazer:**
- Na função `efeito()`, crie um Timer no RunData (ou no Player) com `wait_time = 60` e `autostart = true`.
- O callback do Timer:
  1. Pega a lista `RunData.artefatos_coletados`.
  2. Escolhe um aleatório com `pick_random()`.
  3. **Duplica** o recurso com `.duplicate()` (IMPORTANTE: use duplicate, senão você estará adicionando a mesma referência).
  4. Chama `RunData.adicionar_artefato(artefato_duplicado)`.
- **Com múltiplas Batatas:** Cada Batata tem seu próprio Timer. 2 Batatas = 2 cópias por minuto.
- **Cuidado com limite:** Se a Batata copiar um artefato que já está no limite, a cópia deve ser recusada silenciosamente (o sistema de limite que você criou na infraestrutura cuida disso automaticamente!).
- **Batata pode copiar Batata?** Decida! Se sim, o jogador pode criar uma avalanche exponencial de artefatos. Pode ser divertido ou quebrar o jogo. Se não, exclua a Batata da lista de candidatos.

**O que testar:** Espere 1 minuto. Um artefato aleatório deve aparecer duplicado no inventário. Verifique que artefatos com limite não são duplicados além do limite.

---

## 📋 Checklist — Ordem Sugerida de Implementação

### Fase 0 — Infraestrutura
- [ ] Adicionar novos campos no `Artefato_data`
- [ ] Adicionar novas variáveis no `RunData`
- [ ] Atualizar `calcular_artefatos()` para processar os novos campos
- [ ] Atualizar `resetar_run()` para limpar as novas variáveis
- [ ] Implementar sistema de limite no `adicionar_artefato()`

### Fase 1 — Numéricos
- [ ] Whey Protein
- [ ] Cristal de Mana
- [ ] Lente de Contato
- [ ] O Suco
- [ ] Coldre do Xerife

### Fase 2 — Modificadores
- [ ] Armadura Pesada de Titânio
- [ ] Cogumelo Esquisito
- [ ] Cristal Corrompido de Mana
- [ ] Prensa Hidráulica

### Fase 3 — Preparação do Event Bus
- [ ] Criar sinais no RunData (`sinal_critico`, `sinal_dano_causado`, `sinal_dano_queimadura`)
- [ ] Emitir `sinal_dano_causado` na hurtbox e nos projéteis
- [ ] Emitir `sinal_critico` nos projéteis quando `e_critico == true`
- [ ] Emitir `sinal_dano_queimadura` no script da queimadura

### Fase 4 — Reativos
- [ ] Plantinha Fofinha (Timer, sem sinal)
- [ ] Botina do Pé Rapado (sinal_critico)
- [ ] Óculos de Sol (sinal_dano_queimadura)
- [ ] Chapéu do Cowboi (sinal_critico + projétil)
- [ ] Relógio de Bolso (sinal_dano_causado + magia)
- [ ] Égide (cena própria, escudo)
- [ ] Batata Copiadora (Timer + duplicação)
