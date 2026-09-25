# Guia de Arquitetura de Upgrades Modulares

Este guia detalha como implementar suas novas ideias de upgrades para armas mantendo o código base (armas, projéteis e inimigos) 100% limpo, utilizando o poder dos **Hooks (Gatilhos)** e **Componentes (Nós Motoristas)** que aprendemos a criar.

> [!TIP]
> A regra de ouro dessa arquitetura é: **O projétil e o inimigo nunca perguntam qual upgrade o jogador tem.** Eles apenas emitem sinais ("Eu atirei", "Eu morri", "Eu bati"), e o sistema de Upgrades reage a eles silenciosamente por trás dos panos.

---

## 1. Míssil Mágico

### Missil Teleguiado
- **Como Fazer:** O que já conversamos! Use o Hook `ao_atirar(player, direcao, projetil)`.
- **Lógica:** O script do upgrade cria um Nó (o `motorista_teleguiado.gd`) e anexa ele (`add_child()`) na bala. O motorista roda o `_process` mudando o `direction` da bala para perseguir o alvo.

### Explosão ao Contato
- **Como Fazer:** Crie um novo Hook no `upgrades.gd` chamado `ao_causar_dano(inimigo, dano, arma)`. A bala do míssil chama essa função quando acerta alguém.
- **Lógica:** No script `upgrade_missil_explosao.gd`, você recebe o inimigo que tomou o hit, instancia a cena `explosao_visual.tscn` no pé dele, e dá dano em área em volta.

### Modo Automático (Órbita e Auto-Atirar)
- **Como Fazer:** Crie um Hook chamado `ao_equipar_arma(player)`. Ele roda assim que o jogador compra o upgrade ou troca para essa arma.
- **Lógica:** O upgrade anexa um Nó no Player chamado `motorista_auto_atirador.gd`. Esse nó contém um `Timer`. A cada *X* segundos, ele acha um inimigo perto, e chama a função `arma.usar_arma()` forçando a arma a atirar sem depender de Input do mouse! Ele também pode ter uma função `_process` que faz os mísseis ficarem girando (usando seno e cosseno, igual fizemos na Égide) antes de voar.

---

## 2. Laser

### Laser Contínuo
- **Como Fazer:** Como isso muda a estrutura da arma, você vai precisar de um tipo de projétil diferente (um `RayCast2D` em vez de um `Area2D` que voa).
- **Lógica:** No script base do laser (`laser.gd`), na hora que ele for spawnar a cena, ele checa: `if tem_efeito("laser_continuo"): projetil = cena_raycast_continuo`. É uma exceção válida onde a arma pode mudar sua cena base.

### Ricochete entre inimigos
- **Como Fazer:** Hook `ao_causar_dano(inimigo, dano, projetil)`.
- **Lógica:** Quando o laser bate no Inimigo 1, o Upgrade de Ricochete entra em ação: ele acha o Inimigo 2 mais próximo, e desenha uma linha reta (um nó `Line2D`) entre o Inimigo 1 e Inimigo 2, aplicando dano instantâneo no Inimigo 2.

---

## 3. Círculo de Fogo

### Queimadura Explode
- **Como Fazer:** Usando o Hook `ao_inimigo_morrer(inimigo, player)` que criamos. Se o inimigo morto tinha o nó de Queimadura, explode! *(Já implementado!)*

### Aumenta Tamanho e Tempo de Vida
- **Como Fazer:** Sem hooks complexos. Apenas matemática no `calcular_upgrades()` da própria arma.
- **Lógica:** A arma lê `valor_do_efeito("tamanho_fogo")` e quando dá o `instantiate()` do fogo, multiplica a `scale` dele e o `wait_time` do relógio pelo valor desse upgrade.

### Propagação do Fogo (Inimigo morre e passa o fogo)
- **Como Fazer:** Outro script herdando de `UpgradeData`, usando o Hook `ao_inimigo_morrer(inimigo, player)`.
- **Lógica:**
  1. Verifica se o morto tinha Queimadura.
  2. Procura o inimigo mais próximo a menos de X pixels.
  3. Pega a cena da queimadura e dá um `add_child` no inimigo novo, transferindo as stacks (acúmulo) que o morto tinha!

---

## 4. Terremoto

### Aumenta velocidade do tick / Dano
- **Como Fazer:** Exatamente como o Tamanho do Fogo. A arma lê os atributos no `calcular_upgrades()` e passa para o projétil quando cria ele.

### Slow / Stun nos Inimigos
- **Como Fazer:** No Hook `ao_causar_dano(inimigo, dano, projetil)`.
- **Lógica:** Se a arma for Terremoto, você pega a velocidade do inimigo (`inimigo.speed` ou no seu caso `inimigo.data.speed`) e divide por 2 temporariamente através de um Nó "DebuffSlow" que você gruda nele, do mesmo jeito que fez com a Queimadura. Para Stun, apenas crie um estado onde ele não consegue andar (ex: seta a velocidade pra 0 e liga um timer de 2 segundos para devolver).

### Spawna Terremoto no Dash
- **Como Fazer:** Crie um Hook novo `ao_player_dash(player)`. Lá no seu script `player.gd`, na parte onde ele aperta o botão de Dash, ele avisa a arma `arma.ao_player_dash(self)`.
- **Lógica:** O script do upgrade de Dash recebe isso e dá um `instantiate()` na cena do Terremoto exatamente na posição onde o player começou a dashar. 

---

## 5. Gravity

### Aumenta buracos negros e Puxão
- **Como Fazer:** Lidos no `calcular_upgrades()` e repassados para a cena do Buraco Negro no momento do tiro. O buraco negro usa a força do puxão para atrair os monstros.

### Executa inimigos com menos de 5% da vida
- **Como Fazer:** Hook `ao_causar_dano(inimigo, dano, projetil)`.
- **Lógica:**
```gdscript
# No upgrade_executar.gd
func ao_causar_dano(inimigo, dano, projetil):
    # Se a vida dele ficar menor que 5% da vida máxima, MATA NA HORA
    if inimigo.vida_atual <= inimigo.vida_max * 0.05:
        # Marca que ele sofreu um Execute!
        inimigo.set_meta("morto_por_execute", true)
        inimigo.take_damage(999999) # Força a morte
```

### Inimigos que morrem por esse Execute aumenta a vida máxima em 0.1%
- **Como Fazer:** Hook `ao_inimigo_morrer(inimigo, player)`.
- **Lógica:**
```gdscript
# No upgrade_aumenta_vida_execute.gd
func ao_inimigo_morrer(inimigo, player):
    # Se ele não tem a marca de execute, vai embora
    if not inimigo.has_meta("morto_por_execute"):
        return
        
    # Aumenta a vida permanentemente
    var cura = player.vida_max * 0.001
    player.vida_max += cura
    player.curar(cura) # Para não ficar com um buraco na vida
    print("Vida Maxima Aumentada!")
```
