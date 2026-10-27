# AI Context & Developer Router: Módulos Técnicos (`/docs/modules`)

Este arquivo atua como o **Roteador de Módulos Técnicos** para Agentes de IA e Desenvolvedores. Mapeia a documentação aprofundada de entidades e subsistemas do jogo.

---

## Mapa de Roteamento de Módulos

| Módulo / Entidade | Arquivo de Documentação | Responsabilidades Principais | Cenas e Scripts Vinculados |
| :--- | :--- | :--- | :--- |
| **Player** | [`player.md`](player.md) | Movimentação 8D, leitura de inputs, AnimationPlayer, mecânica de *lunge* e ataque corpo a corpo. | `scenes/entities/player.tscn`<br>`scripts/player.gd`<br>`scripts/player_sprite.gd`<br>`scripts/hitbox.gd` |
| **Dummy (Alvo de Treino)** | [`dummy.md`](dummy.md) | Hurtbox (`Area2D`), dano, knockback por atrito, flash visual e integração com `DestructionEffect`. | `scenes/entities/dummy.tscn`<br>`scripts/dummy.gd`<br>`scripts/hurtbox.gd` |
| **Inimigo / FSM (Em Dev)** | *A ser criado na Sprint 3* | Máquina de estados (`State`, `StateMachine`), campo de visão e combate ativo do mob. | `scenes/entities/enemy.tscn`<br>`scripts/state_machine.gd` |

---

## Padrão para Novos Módulos Técnicos
Ao implementar uma nova entidade relevante ou subsistema:
1. Crie o arquivo `docs/modules/<nome_do_modulo>.md`.
2. Documente:
   - Objetivo do módulo e problemas que resolve.
   - Conceitos-chave de engine/arquitetura.
   - Hierarquia de nós da cena.
   - Configurações no Inspector.
   - Sinais emitidos e consumidos.
3. Adicione o novo módulo à tabela acima e referencie-o no [AI_CONTEXT.md](../../AI_CONTEXT.md).
