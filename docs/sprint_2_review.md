# Relatório de Revisão e Fechamento: Sprint 2

## Visão Geral da Sprint 2
- **Foco da Sprint:** Arquitetura do sistema de combate corpo a corpo (Melee Combat), ciclo de vida de Hitboxes e Hurtboxes em camadas físicas 2D desacopladas, animações direcionais de golpe com avanço frontal dinâmico (*lunge* estilo Minecraft Dungeons), entidade alvo de treino (`Dummy`), feedback visual imediato (*damage flash* e cinemática de *knockback* amortecido por atrito) e o padrão global de destruição por código (`DestructionEffect` com estilhaçamento de textura e partículas de sangue procedural).
- **Resultado do Playtest:** 100% dos testes unitários e o teste integrado de ponta a ponta (`tests/playtest_sprint2.gd`) aprovados no modo headless da Godot 4.
- **Status do Console:** 0 Erros (errors), 0 Avisos (warnings) críticos.

---

## 1. Escopo Entregue na Sprint 2

| Card / Item | Descrição | Status |
| :--- | :--- | :--- |
| **#11 - Input Map e Ações de Ataque** | Mapeamento da ação `player_attack`, flags de combate (`can_attack`, `is_attacking`), cooldown e suporte a atordoamento (`apply_stun`) | Concluído |
| **#12 - Estrutura da Hitbox do Player** | Componente `Hitbox` (`Area2D`) com Collision Layer 4 (`PlayerHitbox`), Collision Mask 3 (`Enemies`) e pivô direcional rotativo (`HitboxPivot`) | Concluído |
| **#13 - Animação de Golpe Direcional** | Spritesheets de ataque nas orientações Down, Up, Side (com `flip_h`), transição de estados e mecânica de *lunge* frontal | Concluído |
| **#14 - Sincronização de Frame da Hitbox** | Trilhas de método no `AnimationPlayer` para chaveamento cirúrgico da janela de dano (0.1s a 0.25s) com fail-safe na conclusão | Concluído |
| **#15 - Cena Base do Inimigo/Alvo (Dummy)** | Entidade `CharacterBody2D` com física amortecida por atrito, sprite estático/animado e sombra desenhada no chão | Concluído |
| **#16 - Implementação da Hurtbox no Inimigo** | Componente `Hurtbox` (`Area2D`), escuta na Layer 4, detecção tipada via `hit_received(hitbox: Hitbox)` e suporte a i-frames | Concluído |
| **#17 - Sistema de Tomada de Dano e Vida** | Encapsulamento de `max_hp` e `hp` com setter restritivo (`clampi`), e método `receber_dano(valor)` | Concluído |
| **#18 - Feedback Visual de Dano (Knockback & Flash)** | Impulso cinemático em direção oposta ao atacante, amortecimento linear por `friction * delta` e Tween de modulação de cor (*flash*) | Concluído |
| **#19 - Condição de Destruição e Efeito Padrão** | Lógica de morte quando `hp <= 0`, emissão de sinal `died`, remoção com `queue_free()` e efeito global `DestructionEffect` (fragmentos + sangue se `is_living`) | Concluído |
| **#20 - Revisão, Depuração e Fechamento** | Suíte de integração ponta a ponta (`tests/playtest_sprint2.gd`), validação completa de combate e documentação do módulo | Concluído |

---

## 2. Validação dos Critérios de Aceitação (DoD)

### Sistema de Ataque e Hitbox Direcional
- Acionamento responsivo de ataque com controle estrito de cadência via `attack_cooldown` (0.4s).
- Rotação do `HitboxPivot` calculada via `direction.angle()`, garantindo precisão de cobertura em 360° com base na última direção registrada (`last_direction`).
- Ativação diferida e segura da `Hitbox` (`monitoring = true`, `monitorable = true`, `disabled = false`) exclusivamente entre 0.1s e 0.25s da animação de golpe, com desligamento automático (*fail-safe*) no callback `_on_animation_player_animation_finished`.

### Avanço Frontal (*Lunge*) Estilo Minecraft Dungeons
- Durante o ataque, a movimentação livre é substituída por um estalo inicial de impulso (`attack_lunge_speed = 240.0 px/s`) na direção do golpe.
- O impulso é estancado abruptamente através de forte desaceleração linear (`attack_lunge_friction = 2400.0 px/s²`), evitando deslizamento incontrolável do jogador enquanto desfere o corte.

### Detecção de Colisão Desacoplada (Component Pattern)
- A `Hurtbox` reside na Layer 3 (`Enemies`) e monitora a Layer 4 (`PlayerHitbox`).
- Ao detectar sobreposição, a `Hurtbox` valida a tipagem estática (`area is Hitbox`) e emite o sinal `hit_received(hitbox: Hitbox)`, mantendo o atacante e o alvo 100% desacoplados.

### Feedback de Dano: Knockback Físico e Damage Flash
- Vetor de knockback calculado no `Dummy` em função da posição global do atacante: `(global_position - hitbox.source.global_position).normalized() * hitbox.knockback_force`.
- Desaceleração orgânica via `velocity.move_toward(Vector2.ZERO, friction * delta)` no `_physics_process`.
- Feedback visual imediato através de `Tween` animando `sprite.modulate` para vermelho claro (`Color(1.0, 0.3, 0.3)`) e retornando para `Color.WHITE` em 0.12 segundos.

### Padrão Global de Destruição (`DestructionEffect`)
- Quando `hp <= 0`, o `Dummy` desativa imediatamente o processamento de física e sua `Hurtbox`, gerando o efeito `DestructionEffect` antes de chamar `queue_free()`.
- O efeito recorta a textura original em uma grade de $4 \times 4$ fragmentos rígidos (`RigidBody2D` simulados via física ou cálculo procedural) arremessados para longe da direção do golpe.
- Alvos marcados com `is_living = true` emitem adicionalmente partículas vermelhas (sangue procedural), enquanto objetos inanimados (`is_living = false`, como o Dummy) emitem apenas os estilhaços de madeira/palha.

---

## 3. Próximos Passos (Backlog para a Sprint 3)
1. **Inteligência Artificial de Inimigos (Mobs Móveis):** Criação de um monstro básico (ex: Goblin / Slime) com máquina de estados finita (Idle, Wander, Chase, Attack) e campo de visão via `Area2D`.
2. **Interface de Usuário (HUD & Health Bars):** Criação de barra de vida flutuante para inimigos e interface de vida fixa para o Player, utilizando sinais desacoplados da Godot.
3. **Mecânica de Dano ao Player:** Permitir que inimigos causem dano de contato ou golpes contra a Hurtbox do protagonista, integrando i-frames e tela vermelha.
