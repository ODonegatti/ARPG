# AI Context & Developer Router: Testes Headless (`/tests`)

Este arquivo atua como o **Roteador de Testes Automatizados** para Agentes de IA e Desenvolvedores. Mapeia os arquivos de teste headless em GDScript, os cards que eles validam e como executá-los.

---

## Como Executar os Testes (Godot 4 Headless)

Para rodar qualquer teste individualmente via linha de comando:
```powershell
godot --headless -s tests/<nome_do_teste>.gd
```

Para rodar os playtests integrados de ponta a ponta:
```powershell
# Playtest integrado da Sprint 1 (Movimentação, Colisão, Animação)
godot --headless -s tests/playtest_sprint1.gd

# Playtest integrado da Sprint 2 (Combate Melee, Knockback, Dummy, Destruição)
godot --headless -s tests/playtest_sprint2.gd
```

---

## Mapa de Roteamento de Testes

| Arquivo de Teste | Card / Feature Validada | O que valida | Script(s) Alvo |
| :--- | :--- | :--- | :--- |
| [`playtest_sprint1.gd`](playtest_sprint1.gd) | Sprint 1 (Cards #1 a #10) | Integração completa do Player com TileMap, colisões e transição de estados de animação. | `scripts/player.gd`<br>`scripts/player_sprite.gd` |
| [`playtest_sprint2.gd`](playtest_sprint2.gd) | Sprint 2 (Cards #11 a #20) | Combate melee completo: aproximação, lunge, ataque, knockback no Dummy e destruição procedural. | `scripts/player.gd`<br>`scripts/hitbox.gd`<br>`scripts/dummy.gd`<br>`scripts/destruction_effect.gd` |
| [`test_player_attack_prep.gd`](test_player_attack_prep.gd) | Card #11 | Input Map de ataque, flags `can_attack`, `is_attacking` e cooldowns. | `scripts/player.gd` |
| [`test_hitbox_structure.gd`](test_hitbox_structure.gd) | Card #12 | Estrutura da Hitbox (`Area2D`), camadas de física (Layer 4) e pivô direcional. | `scripts/hitbox.gd` |
| [`test_attack_animation.gd`](test_attack_animation.gd) | Card #13 | Spritesheets direcionais de ataque, avanço frontal (*lunge*) e amortecimento. | `scripts/player.gd`<br>`scripts/player_sprite.gd` |
| [`test_hitbox_sync.gd`](test_hitbox_sync.gd) | Card #14 | Chaveamento temporal da Hitbox (janela de dano ativa entre 0.1s e 0.25s). | `scripts/player.gd`<br>`scripts/hitbox.gd` |
| [`test_hurtbox_dummy.gd`](test_hurtbox_dummy.gd) | Cards #16 e #17 | Detecção de golpe pela Hurtbox do Dummy, redução de HP e sinalização. | `scripts/hurtbox.gd`<br>`scripts/dummy.gd` |
| [`test_dummy_destruction.gd`](test_dummy_destruction.gd) | Card #19 | Morte ao zerar HP, remoção segura (`queue_free`) e disparo de `DestructionEffect`. | `scripts/dummy.gd`<br>`scripts/destruction_effect.gd` |

---

## Diretrizes de Teste para o Agente de IA
- **Regra Inegociável:** Sem arquivo de teste executando com sucesso em modo headless, o commit **não pode** ser realizado.
- Ao criar uma nova feature ou card, adicione seu arquivo de teste nesta pasta e registre-o imediatamente na tabela acima.
