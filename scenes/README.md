# AI Context & Developer Router: Cenas (`/scenes`)

Este arquivo atua como o **Roteador de Cenas** para Agentes de IA e Desenvolvedores. Mapeia a hierarquia de nós, camadas físicas e scripts acoplados a cada cena `.tscn` do projeto.

---

## Mapa de Roteamento de Cenas

| Cena | Tipo Raiz | Camadas de Física | Script Vinculado | Testes Automatizados | Documentação Técnica |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [`main.tscn`](main.tscn) | `Node2D` | Cenário e instâncias integradas | - | `tests/playtest_sprint1.gd`<br>`tests/playtest_sprint2.gd` | [modulo1.md](../modulo1.md)<br>[modulo2.md](../modulo2.md) |
| [`entities/player.tscn`](entities/player.tscn) | `CharacterBody2D` | Layer 2 (Player)<br>Mask 3 (World/Player)<br>Layer 4 (Hitbox) | `scripts/player.gd`<br>`scripts/player_sprite.gd`<br>`scripts/hitbox.gd` | `tests/playtest_sprint1.gd`<br>`tests/playtest_sprint2.gd` | [docs/modules/player.md](../docs/modules/player.md) |
| [`entities/dummy.tscn`](entities/dummy.tscn) | `CharacterBody2D` | Layer 3 (Enemies)<br>Mask 1 (World)<br>Layer 3 (Hurtbox) | `scripts/dummy.gd`<br>`scripts/hurtbox.gd` | `tests/test_hurtbox_dummy.gd`<br>`tests/test_dummy_destruction.gd` | [docs/modules/dummy.md](../docs/modules/dummy.md) |

---

## Convenções de Cenas & Camadas de Colisão (Physics Layers)
- **Layer 1:** `World` (Paredes, obstáculos estáticos, TileMapLayer)
- **Layer 2:** `Player` (Corpo físico do protagonista para colisão com o mundo)
- **Layer 3:** `Enemies` (Corpos físicos e Hurtboxes de inimigos/alvos)
- **Layer 4:** `PlayerHitbox` (Hitbox ofensiva da arma do jogador)
- **Layer 5:** `EnemyHitbox` (Hitbox ofensiva dos ataques do inimigo — Sprint 3)

---

## Diretrizes para Novas Cenas
Ao criar qualquer nova cena em `/scenes`:
1. Mantenha os nós componentes desacoplados e nomeados com clareza semântica.
2. Configure rigorosamente as Physics Layers e Masks.
3. Registre a nova cena imediatamente neste arquivo (`scenes/README.md`).
