# AI Context & Developer Router: Scripts (`/scripts`)

Este arquivo atua como o **Roteador de Lógica** para Agentes de IA e Desenvolvedores. Consulte a tabela abaixo para localizar a responsabilidade, cena associada, testes e documentação de cada script do projeto.

---

## Mapa de Roteamento de Scripts

| Script | Responsabilidade / Camada | Cena Vinculada | Testes Automatizados | Documentação Técnica |
| :--- | :--- | :--- | :--- | :--- |
| [`player.gd`](player.gd) | Controlador do protagonista: input 8D, física `move_and_slide`, cooldown de ataque e desaceleração (*lunge*). | `scenes/entities/player.tscn` | `tests/playtest_sprint1.gd`<br>`tests/playtest_sprint2.gd`<br>`tests/test_player_attack_prep.gd` | [docs/modules/player.md](../docs/modules/player.md) |
| [`player_sprite.gd`](player_sprite.gd) | Gerenciador de spritesheet direcional (Down, Up, Side com `flip_h`) e sincronização de animações. | `scenes/entities/player.tscn` | `tests/test_attack_animation.gd` | [docs/modules/player.md](../docs/modules/player.md) |
| [`hitbox.gd`](hitbox.gd) | Área de transmissão de dano (`Area2D`, Layer 4). Transporta dano base, força de knockback e referência ao atacante. | `scenes/entities/player.tscn` | `tests/test_hitbox_structure.gd`<br>`tests/test_hitbox_sync.gd` | [docs/modules/player.md](../docs/modules/player.md) |
| [`hurtbox.gd`](hurtbox.gd) | Área de recepção de dano (`Area2D`, Layer 3). Detecta Hitboxes tipadas e emite sinal `hit_received(hitbox)`. | `scenes/entities/dummy.tscn` | `tests/test_hurtbox_dummy.gd` | [docs/modules/dummy.md](../docs/modules/dummy.md) |
| [`dummy.gd`](dummy.gd) | Entidade de treino (`CharacterBody2D`): vida `hp`, atrito linear de knockback e gatilho de destruição. | `scenes/entities/dummy.tscn` | `tests/playtest_sprint2.gd`<br>`tests/test_dummy_destruction.gd` | [docs/modules/dummy.md](../docs/modules/dummy.md) |
| [`destruction_effect.gd`](destruction_effect.gd) | Efeito procedural global: quebra sprite em fragmentos físicos; gera sangue se `is_living = true`. | Instanciado via código em `Node` raiz | `tests/test_dummy_destruction.gd` | [docs/guidelines/architecture_rules.md](../docs/guidelines/architecture_rules.md) |

---

## Diretrizes para Novos Scripts
Ao criar qualquer novo script em `/scripts`:
1. Use **Strict Static Typing** em 100% dos métodos e variáveis.
2. Adicione cabeçalho com metadados de roteamento para a IA (`AI Context Router`).
3. Registre o script imediatamente neste arquivo (`scripts/README.md`).
4. Crie o teste correspondente em `/tests/` antes de commitar.
