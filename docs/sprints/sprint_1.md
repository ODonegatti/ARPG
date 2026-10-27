# Sprint 1: Fundação, Movimentação 2D e Cenário (Concluída)

- **Período:** 05 de Outubro de 2026 – 09 de Outubro de 2026
- **Status:** Concluída e aprovada
- **Documento do Módulo do Curso:** [modulo1.md](../../modulo1.md)
- **Relatório de Fechamento:** [docs/sprint_1_review.md](../sprint_1_review.md)

---

## 1. Objetivo da Sprint 1
Estabelecer a fundação técnica do projeto com arquitetura limpa em Godot 4: criação do repositório, configuração do ambiente e padrões, criação do Player (`CharacterBody2D`) com movimentação direcional normalizada em 8 direções, colisão com cenário via `TileMapLayer` e sistema de animação direcional com pixel art nítido (Nearest texture filtering e snap de pixels).

---

## 2. Backlog e Cards Entregues (Trello #1 a #10)

| Card / Item | Título / Descrição | Status |
| :--- | :--- | :--- |
| **Card #1** | `[Dev] #1 - Inicialização do Repositório e Padrões Git` | Concluído |
| **Card #2** | `[Dev] #2 - Configurações do Projeto Godot 4 e Pixel Art Snap` | Concluído |
| **Card #3** | `[Dev] #3 - Importação e Configuração dos Assets Tiny Swords` | Concluído |
| **Card #4** | `[Dev] #4 - Definição da Estrutura de Diretórios e Convenções` | Concluído |
| **Card #5** | `[Dev] #5 - Criação do Mapeamento de Entradas (Input Map WASD/Setas)` | Concluído |
| **Card #6** | `[Dev] #6 - Criação do CharacterBody2D do Player e Script de Movimento` | Concluído |
| **Card #7** | `[Dev] #7 - Configuração do TileMapLayer e Colisões Estáticas do Cenário` | Concluído |
| **Card #8** | `[Dev] #8 - Sistema de Animação com AnimationPlayer (Idle e Walk Direcional)` | Concluído |
| **Card #9** | `[Dev] #9 - Refatoração do Player (SRP, Separação de Responsabilidades e @export)` | Concluído |
| **Card #10** | `[Dev] #10 - Playtest Headless da Sprint 1 e Validação de Fechamento` | Concluído |

---

## 3. Principais Entregas Técnicas
- **Movimentação:** `Input.get_vector()` normalizado, velocidade constante (200 px/s), sem aceleração residual indesejada.
- **Colisões:** Camada física estática no `TileMapLayer` interagindo perfeitamente com o `CollisionShape2D` do Player.
- **Visual:** Texturas com filtro Nearest, Snap 2D configurado, sem shimmering ou distorção de pixel art.
