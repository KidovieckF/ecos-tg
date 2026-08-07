# Plano — Ecos_TG (TCC)

Roguelike top-down com andares progressivos. Cada run = 15 salas → boss → andar seguinte.
Morreu = run acabou, volta ao lobby. Nada é persistente entre sessões.

## Regras da run
- Zera ao morrer/vencer: moeda, vida, xp, nível, modificadores de arma, andar
- Arma escolhida no lobby inicia a run
- **Andares até vencer:** 3

## Fase 1 — Fundação limpa
- [ ] Remover scripts mortos (player1.1.gd, magia_1.gd/1.1.gd, carrossel_exemplo.gd, upgrade.tscn duplicada)
- [ ] Criar autoload RunData (andar, moeda_run, vida, xp, nivel, proj_mods duplicado, arma)
- [ ] Padronizar acesso por grupos (Players, HUD) — remover get_parent().get_node("HUD")
- [ ] RunData.resetar_run() no início/morte

## Fase 2 — Fechar o core loop
- [ ] Corrigir dano acumulado em arma_fogo.gd
- [ ] Transporte entre andares (RunData → recarregar Mundo.tscn com andar+1)
- [ ] Escala de dificuldade por andar (ondas, pesos, vida dos inimigos)
- [ ] Vitória no andar final (tela de vitória + resumo da run)
- [ ] Reset entre runs ao morrer/vencer
- [ ] Corrigir mutação de upgrades (hud_upgrade.gd)

## Fase 3 — Conteúdo & polimento
- [ ] Loja do andar, sala de cura/elite
- [ ] Mais armas, inimigos, personagens
- [ ] Balanceamento e HUD do andar
- [ ] Som, juice, telas polidas
- [ ] Documentação do TCC (arquitetura, decisões, testes)

## Progresso
_(vou marcando ✓ conforme concluímos, com data e commit)_