# 📜 Guia de Drops de Artefatos, Raridade e Balanceamento — Ecos_TG

Este documento reúne todas as análises, sugestões de arquitetura, propostas de balanceamento e correções de mecânicas identificadas no projeto. Ele servirá como roteiro passo a passo para revisarmos e implementarmos juntos cada item, sem quebrar os sistemas existentes.

---

## 📌 Sumário
1. [Diagnóstico dos Problemas Críticos Encontrados](#1-diagnóstico-dos-problemas-críticos-encontrados)
2. [Sistema de Drops de Artefatos & Raridade](#2-sistema-de-drops-de-artefatos--raridade)
3. [Entidade de Drop no Chão (`Artefato_Drop.tscn`)](#3-entidade-de-drop-no-chão-artefato_droptscn)
4. [Balanceamento da Dificuldade & Curva de Poder](#4-balanceamento-da-dificuldade--curva-de-poder)
5. [Economia da Run (Moedas vs Preços na Loja)](#5-economia-da-run-moedas-vs-preços-na-loja)
6. [Checklist de Execução Passo a Passo](#6-checklist-de-execução-passo-a-passo)

---

## 1. Diagnóstico dos Problemas Críticos Encontrados

Durante a análise minuciosa do código, foram identificados pontos que geram inconsistências ou bugs no gameplay:

### 1.1. Conflito no Cálculo de Redução de Dano (`player.gd`)
* **Local:** `Scripts/Player/player.gd` (linhas 224-225)
* **Código atual:**
  ```gdscript
  var quantidade_real = quantidade * (1.0 - RunData.dano_reducao)
  quantidade_real = max(0, quantidade - RunData.dano_reducao)
  ```
* **Problema:** A segunda linha **sobrescreve** a primeira. Se `RunData.dano_reducao` for `0.25` (25% da Armadura Pesada), um dano de 10 deveria virar 7.5, mas a segunda linha faz `10 - 0.25 = 9.75`.
* **Solução:** Manter apenas o cálculo percentual ou definir claramente o que é redução percentual (`dano_reducao_pct`) e o que é armadura fixa (`armadura_fixa`).

---

### 1.2. A Armadilha de Escalação de Vida ("Scaling Trap")
* **Local:** `Scripts/Inimigos/inimigo_base.gd` (linha 29) e `Scripts/Miniboss/miniboss_base.gd` (linha 34)
* **Código atual:**
  ```gdscript
  vida_max = data.vida * player.nivel * RunData.mult_dificuldade
  ```
* **Problema:** A vida dos monstros é multiplicada diretamente pelo **nível do jogador** (`player.nivel`).
  - No Nível 1: Morcego tem 10 HP (morre com 4 tiros do Míssil que dá 3 de dano).
  - No Nível 5: O mesmo morcego passa para **50+ HP** (17 tiros!), mas o dano base da arma continua sendo 3.
  - O jogador sente que subir de nível deixa o jogo **mais difícil e esponjoso**, matando o sentimento de recompensa por upar.
* **Solução:** Desvincular a vida dos inimigos do nível do jogador. A vida deve escalar com o **Andar** (`RunData.andar`) e o número de **Salas Limpas**, recompensando o jogador quando ele sobe de nível.

---

### 1.3. `multiplicar_dificuldade()` não atualiza a variável global
* **Local:** `Scripts/Mundo/RunData.gd` (linhas 291-292)
* **Código atual:**
  ```gdscript
  func multiplicar_dificuldade() -> float:
      return 1.0 + dificuldade * 0.05
  ```
* **Problema:** A função apenas retorna o valor `float`, mas **nunca atualiza** a variável `RunData.mult_dificuldade`. Como os inimigos leem `RunData.mult_dificuldade`, o multiplicador fica estagnado no valor inicial.
* **Solução:** A função deve atualizar `mult_dificuldade = 1.0 + dificuldade * 0.05` ou retornar o valor e atribuir na hora.

---

### 1.4. Descarte do XP Excedente ao Subir de Nível
* **Local:** `Scripts/Player/player.gd` (linha 206)
* **Código atual:**
  ```gdscript
  if xp_atual >= barra_exp:
      xp_atual = 0
  ```
* **Problema:** Se faltam 5 de XP para upar e o jogador mata um monstro que dá 50 de XP, os 45 de XP excedentes são jogados no lixo (`xp_atual = 0`).
* **Solução:** Usar `xp_atual -= barra_exp`, preservando o progresso residual.

---

### 1.5. Miniboss sem Lista de Drops
* **Local:** `Cenas/Inimigos/Miniboss/Miniboss_base.tscn` e `Scripts/Miniboss/miniboss_base.gd`
* **Problema:** `dropar_artefato()` depende de `@export var drop_artefatos: Array[Artefato_data]`, que está vazio no inspetor da cena. Por isso, ao morrer, o Miniboss nunca dropa nada.
* **Solução:** Fazer o Miniboss sortear seu artefato diretamente da pool global (`RunData.artefatos_disponiveis`), garantindo 100% de drop sem depender de listas manuais por cena.

---

### 1.6. Sorteio de Raridade da Loja Incompleto
* **Local:** `Scripts/Mundo/Salas/loja_hud.gd` (linhas 57-66)
* **Problema:**
  - `< 50`: Comum (50%)
  - `< 80`: Incomum (30%)
  - `< 90`: Raro (10%)
  - `90 a 99`: A variável fica vazia (`""`), acionando um fallback desgovernado.
  - Artefatos `Épicos` e `Lendários` não têm chance programada na loja.
* **Solução:** Unificar o sistema de sorteio em uma função reutilizável no `RunData`.

---

## 2. Sistema de Drops de Artefatos & Raridade

### 2.1. Classificação das Raridades
O sistema terá 5 graus de raridade, cada um com sua cor de identidade visual:

| Raridade | Cor Hex | Uso & Perfil |
| :--- | :--- | :--- |
| **Comum** | `#BDC3C7` (Branco/Cinza) | Bônus numéricos diretos (Vida max, Dano % base). Sem limite ou limite alto. |
| **Incomum** | `#2ECC71` (Verde) | Utilitários e cadência (Velocidade de ataque, mobilidade condicional). |
| **Raro** | `#3498DB` (Azul) | Multiplicadores fortes, sinergias e regras modificadas (O Suco, Cogumelo). |
| **Épico** | `#9B59B6` (Roxo) | Efeitos de grande impacto (Armadura Pesada, Chapéu de Cowboy, Égide). |
| **Lendário** | `#F1C40F` (Dourado) | Game changers extremos e modificadores de run (Prensa Hidráulica). |
| **Único** | `#E74C3C` (Vermelho) | Drops exclusivos de Chefes de Andar (ex: Relógio de Bolso). |

---

### 2.2. Tabela de Probabilidades de Drop

#### A. Inimigos Comuns
* **Chance de dropar artefato:** **2.0%** (1 em 50 monstros).
* *(Opcional)* Inimigos de Elite / Onda Especial: **5.0%**.
* **Distribuição de Raridade ao Dropar:**
  - 🟢 **Comum:** 70%
  - 🔵 **Incomum:** 25%
  - 🟣 **Raro:** 5%
  - *(Épicos e Lendários NUNCA caem de inimigos comuns para manter o valor das salas especiais)*.

#### B. Miniboss (Sala de Miniboss)
* **Chance de dropar artefato:** **100% garantido**.
* **Distribuição de Raridade:**
  - 🟢 **Comum:** 0% (Miniboss não dá item básico)
  - 🔵 **Incomum:** 45%
  - 🟣 **Raro:** 40%
  - 🟣 **Épico:** 15%

#### C. Boss do Andar (Final de Andar)
* **Chance de dropar artefato:** **100% garantido**.
* **Distribuição de Raridade:**
  - 🟣 **Raro:** 40%
  - 🟣 **Épico:** 40%
  - 🟡 **Lendário / Único:** 20%

---

### 2.3. Sistema de "Pity" (Misericórdia contra Azar)
Para evitar que o jogador passe 10 salas sem ver nenhum drop de inimigo comum:
* Toda vez que um inimigo comum morre e **não** dropa artefato, incrementa `contador_pity_drop += 1`.
* A chance efetiva passa a ser:
  $$\text{chance\_final} = \text{chance\_base} + (\text{contador\_pity} \times 0.05\%)$$
* Assim que um artefato dropa, o `contador_pity_drop` reseta para zero.
* Garante que entre 30 e 50 kills o jogador sempre veja um drop acontecer.

---

### 2.4. Função Centralizadora no `RunData.gd`
Ao invés de programar o sorteio dentro de cada inimigo, loja e miniboss, criamos uma função única no `RunData`:

```gdscript
func sortear_artefato_por_pesos(pesos_raridade: Dictionary) -> Artefato_data:
    # 1. Filtra artefatos disponíveis respeitando arma requerida
    var pool_valida = artefatos_disponiveis.filter(func(a):
        return a.arma_requerida == "" or (armas[0] != null and a.arma_requerida == armas[0].nome)
    )
    if pool_valida.is_empty():
        return null

    # 2. Rola o dado para escolher a raridade conforme a tabela
    var raridade_escolhida = _rolar_raridade(pesos_raridade)

    # 3. Filtra os itens da raridade sorteada
    var candidatos = pool_valida.filter(func(a): return a.raridade == raridade_escolhida)

    # 4. Fallback: Se não houver itens disponíveis dessa raridade, pega qualquer um válido
    if candidatos.is_empty():
        candidatos = pool_valida

    return candidatos.pick_random()
```

---

## 3. Entidade de Drop no Chão (`Artefato_Drop.tscn`)

### Por que não abrir o Pop-up na hora da morte?
Se um inimigo comum morre cercado de outros monstros, congelar a tela de repente quebra a fluidez do combate e pode fazer o jogador tomar dano assim que fecha a tela.

### Solução Proposta:
Criar uma cena leve de mundo (`Area2D`):
1. **Visual:**
   - Ícone do artefato flutuando suavemente (`sin(tempo)`).
   - Efeito de partículas ou círculo de luz embaixo com a **cor da raridade** (Branco, Verde, Azul, Roxo, Dourado).
2. **Coleta:**
   - Quando o Player entra na área, abre a tela de recompensa (`Hud_artefato.tscn`).
   - Se o jogador **Aceitar**: adiciona no `RunData`, toca som de conquista e destrói o drop.
   - Se o jogador **Recusar**: fecha o pop-up e o item permanece no chão (podendo ser pego depois, caso mude de ideia antes de sair da sala).

---

## 4. Balanceamento da Dificuldade & Curva de Poder

### 4.1. Nova Fórmula de Vida dos Inimigos
Substituir a fórmula atrelada ao nível do jogador por uma fórmula progressiva de exploração:

$$\text{vida\_final} = \text{vida\_base} \times [1.0 + (\text{andar} - 1) \times 0.6 + (\text{salas\_visitadas} \times 0.04)]$$

* **Andar 1 (Início):** Morcego tem 10 HP.
* **Andar 1 (Sala 5):** Morcego tem ~12 HP.
* **Andar 2 (Início):** Morcego tem ~16 HP.
* **Efeito no Gameplay:** Subir de nível agora dá ao jogador uma **vantagem real**, fazendo com que ele sinta o progresso de sua build.

---

### 4.2. Dano Inimigo vs Vida do Jogador (Evitando One-Shots)
Atualmente Alice tem **20 HP base**, enquanto o projétil do Lich dá **20 de dano** e seu melee dá **10 de dano**. Um único projétil resulta em *Game Over*.

**Tabela de Ajuste Sugerida:**

| Entidade | Vida Atual | Dano Atual | Sugestão Balanceada |
| :--- | :--- | :--- | :--- |
| **Alice (Player)** | 20.0 | — | **50.0 a 60.0** (dá margem de erro) |
| **Morcego (Comum)** | 10.0 | 3.0 | 10.0 HP \| 3.0 Dano (Mantém) |
| **Atirador (Elite)** | 25.0 | 5.0 | 25.0 HP \| 5.0 Dano (Mantém) |
| **Lich (Miniboss)** | 200.0 | Projétil: 20.0 / Melee: 10.0 | Projétil: **8.0 a 10.0** / Melee: **6.0** |
| **Item de Cura (Drop)** | Cura 5.0 | — | Cura **10.0 a 15.0** (ou 20% da vida max) |

---

## 5. Economia da Run (Moedas vs Preços na Loja)

Atualmente cada moeda pega no chão dá 2 de dinheiro. A maioria dos artefatos custa fixo 10 moedas. Com apenas 5 moedas coletadas, o jogador já compra qualquer artefato.

### Escala de Preços Proposta por Raridade:

| Raridade | Custo na Loja | Esforço Médio do Jogador |
| :--- | :--- | :--- |
| 🟢 **Comum** | $15 a $20 | ~8 a 10 moedas coletadas |
| 🔵 **Incomum** | $30 a $40 | ~15 a 20 moedas coletadas |
| 🟣 **Raro** | $60 a $75 | Economia de 2 a 3 salas |
| 🟣 **Épico** | $100 a $120 | Investimento alto da run |
| 🟡 **Lendário** | $160 a $200 | Requer juntar dinheiro sem gastar |

---

## 6. Checklist de Execução Passo a Passo

Esta lista está ordenada na sequência lógica mais segura para implementarmos:

### Etapa 1: Correção dos Bugs Críticos de Base
- [ ] Corrigir o cálculo da redução de dano em `player.gd`.
- [ ] Preservar o XP excedente ao upar em `player.gd`.
- [ ] Atualizar o multiplicador em `RunData.multiplicar_dificuldade()`.
- [ ] Preencher a raridade que falta em `Florzinha.tres` e `Prensa.tres`.

### Etapa 2: Motor de Sorteio e Tabela de Raridades
- [ ] Criar a função centralizada `sortear_artefato_por_pesos()` no `RunData.gd`.
- [ ] Adicionar o sistema de Pity (`contador_pity_drop`) no `RunData.gd`.
- [ ] Atualizar `loja_hud.gd` para usar a função de sorteio centralizada.

### Etapa 3: Entidade de Drop no Chão
- [ ] Criar a cena `Artefato_Drop.tscn` (`Area2D` com sprite, luz colorida por raridade e tween flutuante).
- [ ] Conectar a detecção do jogador para abrir `Hud_artefato.tscn`.
- [ ] Manter o item no chão caso o jogador aperte "Recusar".

### Etapa 4: Integração de Drops nos Inimigos
- [ ] No `inimigo_base.gd`: Adicionar verificação de drop de artefato com pity ao morrer.
- [ ] No `miniboss_base.gd`: Fazer o miniboss instanciar o drop garantido com tabela de raridade no local da morte.

### Etapa 5: Rebalanceamento de Vida, Dano e Economia
- [ ] Implementar a nova fórmula de escalamento de vida por andar/salas limpas.
- [ ] Ajustar valores de vida base da personagem e danos de projéteis de chefes.
- [ ] Ajustar os preços dos recursos `.tres` de artefatos conforme suas raridades.
