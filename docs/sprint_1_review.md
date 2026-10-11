# Relatório de Revisão e Fechamento: Sprint 1

## Visão Geral da Sprint 1
- **Foco da Sprint:** Fundação da entidade jogável (Player), movimentação direcional fluida em 8 direções, sistema de colisões com o cenário e máquina de estados de animação direcional com pixel art nítido.
- **Resultado do Playtest:** 100% dos testes de integração e playtest físico aprovados.
- **Status do Console:** 0 Erros (errors), 0 Avisos (warnings) críticos.

---

## 1. Escopo Entregue na Sprint 1

| Card / Item | Descrição | Status |
| :--- | :--- | :--- |
| **#1 a #5** | Configuração inicial do projeto, estrutura de pastas, repositório e diretrizes | Concluído |
| **#6 - Criação do Player** | `CharacterBody2D`, `CollisionShape2D`, configuração do Input Map (WASD / setas) | Concluído |
| **#7 - TileMap e Cenário** | Integração do tileset Tiny Swords, camadas físicas e colisão estática | Concluído |
| **#8 - Sistema de Animações** | Criação do `PlayerSprite` e `AnimationPlayer`, spritesheets de Idle/Run | Concluído |
| **Fix - Nitidez Pixel Art** | Configuração de Texture Filter (Nearest) e Snap 2D (Transforms & Vertices) | Concluído |
| **#9 - Refatoração do Player** | Separação de responsabilidades (SRP), funções desacopladas e `@export` | Concluído |
| **#10 - Playtest e Fechamento** | Execução e validação completa da física, animações e colisão com TileMap | Concluído |

---

## 2. Validação dos Critérios de Aceitação (DoD)

### Movimentação Fluida em 8 Direções
- Vetores de entrada lidos via `Input.get_vector()` e normalizados com `.normalized()`.
- Magnitude escalar de velocidade rigorosamente constante (`200.0 px/s`) em eixos cardinais e diagonais.

### Colisões com o TileMap
- Verificado deslizamento e colisão com o colisor estático do `TileMapLayer` (impacto registrado em `(16.0, 188.25)` com normal `(1.0, 0.0)`).
- Sem travamentos ou quinas invisíveis.

### Transições de Animação (Idle/Walk)
- Transições automáticas acionadas pelo vetor direcional:
  - `direction != Vector2.ZERO`: Aciona estado `walk` e seleciona textura direcional correspondente (`walk_down`, `walk_up`, `walk_side` com `flip_h`).
  - `direction == Vector2.ZERO`: Transiciona para `idle`, preservando a orientação do último movimento registrado em `last_direction`.

---

## 3. Próximos Passos (Backlog para a Sprint 2)
1. **Sistema de Combate Básico:** Ataque corpo a corpo com espada, detecção de hitbox/hurtbox e animações de ataque.
2. **Inimigo Básico (Mob):** Instanciação de IA simples com perseguição direcional e área de agressão.
3. **Barra de Vida / HUD:** Interface gráfica desacoplada com sinais da Godot.
