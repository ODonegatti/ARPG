# Padrões de Git e Conventional Commits

Este documento define os padrões estritos de versionamento para manter o histórico do repositório limpo, rastreável e didático.

---

## 1. Formato de Mensagens de Commit
Siga rigorosamente a convenção do **Conventional Commits**:

```
<tipo>(<escopo>): <descrição curta no imperativo/presente>
```

### Exemplos Válidos:
- `feat(player): adiciona aceleracao e desaceleracao por atrito (Card #9)`
- `fix(combat): corrige calculo do angulo da hitbox ao atacar na diagonal (Card #12)`
- `test(enemy): implementa playtest automatizado da FSM do goblin (Card #22)`
- `docs(course): adiciona capitulo sobre State Pattern no modulo 3`
- `refactor(physics): desacopla calculo de velocidade do processamento de colisao`
- `chore(sprint-3): inicializa branch e backlog de IA do inimigo`

---

## 2. Tipos Permitidos
- `feat`: Nova funcionalidade ou mecânica de jogo.
- `fix`: Correção de bug ou ajuste de comportamento indesejado.
- `refactor`: Refatoração sem alteração de comportamento externo (SRP, desacoplamento).
- `test`: Adição ou ajuste de testes automatizados e playtests.
- `docs`: Documentação técnica, módulos do curso ou relatórios de fechamento de sprint.
- `chore`: Atualizações de configuração, organização de pastas ou contexto de IA.

---

## 3. Escopos Comuns
- `player` — Movimentação, inputs, animação e atributos do protagonista.
- `enemy` — Lógica, FSM, detecção e atributos de inimigos.
- `combat` — Hitbox, Hurtbox, cálculo de dano, knockback e armas.
- `world` — TileMap, colisões de cenário, transições de área.
- `ui` — Barras de vida, menus, HUD e feedback de tela.
- `core` — Máquinas de estado base, gerenciadores globais, utilitários.
- `course` — Módulos didáticos (`moduloX.md`) e tutoriais.
- `test` — Playtests e suítes headless.
- `sprint-X` — Atualizações e fechamentos de sprint específicas.
- `ai-context` — Roteamento e arquitetura de contexto para agentes de IA.

---

## 4. Regra de Ouro: Sem Teste, Sem Commit
Toda implementação concluída deve ter um arquivo de teste correspondente em `/tests` criado e executado com sucesso antes do commit. O teste entra no mesmo commit da funcionalidade.
