# Sprint 2: Sistema de Combate Corpo a Corpo (Melee Combat) (Concluída)

- **Período:** 12 de Outubro de 2026 – 16 de Outubro de 2026
- **Status:** Concluída e aprovada
- **Documento do Módulo do Curso:** [modulo2.md](../../modulo2.md)
- **Relatório de Fechamento:** [docs/sprint_2_review.md](../sprint_2_review.md)
- **Suíte de Teste Integrado:** `tests/playtest_sprint2.gd`

---

## 1. Objetivo da Sprint 2
Arquitetura completa do sistema de combate corpo a corpo (Melee Combat): ciclo de vida de Hitboxes e Hurtboxes desacopladas em camadas físicas 2D (Layers 3 e 4), animações direcionais de golpe com avanço frontal dinâmico (*lunge* estilo Minecraft Dungeons), entidade alvo de treino (`Dummy`), feedback visual imediato (*damage flash* e *knockback* amortecido por atrito) e o padrão global de destruição procedural por código (`DestructionEffect`).

---

## 2. Backlog e Cards Entregues (Trello #11 a #20)

- **Card #11:** `[Dev] #11 - Configuração do Input Map de Ataque e Ações` - **[CONCLUÍDO]**
  - *Critérios:* Mapeamento da tecla de ataque básico (`J` ou botão esquerdo do mouse) no Input Map da Godot; preparação da lógica de cooldown de ataque no script do Player.
  - *Estimativa:* 1h

- **Card #12:** `[Dev] #12 - Estrutura de Cena da Hitbox do Espadachim (Area2D)` - **[CONCLUÍDO]**
  - *Critérios:* Criação de um nó `Area2D` acoplado ao Player com `CollisionShape2D` posicionado na frente da última direção movimentada; camadas de colisão (Layers/Masks) configuradas.
  - *Estimativa:* 1h 10m

- **Card #13:** `[Dev] #13 - Animação de Ataque Direcional (AnimationTree)` - **[CONCLUÍDO]**
  - *Critérios:* Criação das animações de golpe básico para as direções principais; integração e transição de estado de ataque no `AnimationTree` sem travar o movimento base se necessário.
  - *Estimativa:* 55m

- **Card #14:** `[Dev] #14 - Sincronização de Frame de Ativação da Hitbox` - **[CONCLUÍDO]**
  - *Critérios:* Script GDScript e sinais do `AnimationPlayer` para ligar e desligar a propriedade `monitoring` da Hitbox apenas nos frames ativos do golpe.
  - *Estimativa:* 1h 15m

- **Card #15:** `[Dev] #15 - Criação da Cena Base do Inimigo/Alvo (Dummy)` - **[CONCLUÍDO]**
  - *Critérios:* Criação da cena `Dummy.tscn` (`CharacterBody2D` simples) com sprite estático/animado e sombra básica para testes de dano.
  - *Estimativa:* 1h

- **Card #16:** `[Dev] #16 - Implementação da Hurtbox no Inimigo` - **[CONCLUÍDO]**
  - *Critérios:* Adição de um nó `Area2D` (Hurtbox) no Dummy configurado para escutar as camadas de colisão da Hitbox do Player.
  - *Estimativa:* 1h 10m

- **Card #17:** `[Dev] #17 - Sistema de Tomada de Dano e Vida (HP Component)` - **[CONCLUÍDO]**
  - *Critérios:* Variável de vida (`hp`) encapsulada no script do Dummy; criação da função `receber_dano(valor)` conectada ao sinal `area_entered` da Hurtbox.
  - *Estimativa:* 1h

- **Card #18:** `[Dev] #18 - Feedback Visual de Dano (Knockback Simples & Flash)` - **[CONCLUÍDO]**
  - *Critérios:* Pequeno impulso físico (`move_and_slide` com vetor oposto) no Dummy ao sofrer dano e efeito visual básico (piscar o sprite em branco ou vermelho).
  - *Nota de Arquitetura (futuro):* O knockback **dependerá do tipo de ataque do player** (leve, pesado, combo, habilidade). Hoje usa só `Hitbox.knockback_force`; o cálculo está isolado em `Dummy._calcular_knockback(hitbox)`, ponto único onde o tipo de ataque (ex: `Hitbox.attack_type`) será integrado.
  - *Estimativa:* 1h 10m

- **Card #19:** `[Dev] #19 - Condição de Destruição do Alvo (Queue_Free)` - **[CONCLUÍDO]**
  - *Critérios:* Lógica de morte no script do Dummy que verifica quando `hp <= 0` e executa a remoção segura da cena (`queue_free()`).
  - *Padrão de Destruição (todo o projeto):* o sprite se quebra em pedaços arremessados pela tela; seres vivos soltam também pixels vermelhos (sangue). Implementado em `DestructionEffect` (`scripts/destruction_effect.gd`), testado em `tests/test_dummy_destruction.gd`.
  - *Estimativa:* 1h

- **Card #20:** `[Dev] #20 - Revisão, Depuração e Fechamento da Sprint 2` - **[CONCLUÍDO]**
  - *Critérios:* Teste integrado de combate (aproximar, bater, causar dano, verificar knockback e destruição do alvo); commit final limpo no Git. Testado e validado em `tests/playtest_sprint2.gd`.
  - *Estimativa:* 1h 10m
