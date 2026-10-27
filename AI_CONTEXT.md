# AI Context & Developer Router: ARPG Project

> **Arquitetura de Contexto para Agentes de IA:**
> Este arquivo atua como o **Roteador Central (Router)** do repositório. Ele mantém apenas as regras invioláveis e o estado imediato do projeto em memória rápida. Para aprofundar em qualquer tarefa, siga os links do **Mapa de Navegação** para carregar apenas o arquivo específico na sua janela de contexto.

---

## 1. Visão Executiva do Projeto
- **Gênero:** 2D Top-Down / Isometric Action RPG (estilo Minecraft Dungeons).
- **Engine:** Godot 4.x (GDScript estritamente tipado).
- **Proposta:** Curso/Tutorial Vivo de Game Development e Arquitetura de Software com Godot 4 (cada sprint gera um módulo didático oficial).
- **Persona do Assistente:** Alfred — Arquiteto de Software, Tech Lead e Instrutor Técnico.

---

## 2. Regras Inegociáveis (Core Guardrails)
Toda interação, geração de código ou alteração deve respeitar estes 5 mandamentos:

1. **Tipagem Estática Rigorosa:** Sempre declare tipos explícitos para variáveis, parâmetros e retornos no GDScript (`var vel: Vector2 = Vector2.ZERO`, `func take_damage(amount: int) -> void:`).
2. **Godot 4 Exclusivo:** Nunca use métodos, propriedades ou convenções da Godot 3.
3. **Teste Obrigatório Antes de Commitar:** Toda alteração ou card DEVE ter sua suíte correspondente em `/tests` testada e validada em modo headless antes de qualquer commit.
4. **Conventional Commits Estrito:** Commits no formato `<tipo>(<escopo>): <descrição curta>`.
5. **Zero Scope Creep:** Foco cirúrgico na DoD (*Definition of Done*) do card ativo da Sprint.

---

## 3. Estado Atual do Projeto (Fast Status)
- **Data de Início:** 05 de Outubro de 2026.
- **Sprint Ativa:** **Sprint 3 — IA Básica do Inimigo & Máquina de Estados (FSM)**.
- **Objetivo da Sprint 3:** FSM modular em GDScript, detecção via `Area2D`, estados de Idle/Wander/Chase/Attack e combate bidirecional.
- **Próximo Card:** **Card #21** — *Arquitetura da Máquina de Estados Finitos (FSM Base)*.
- **Arquivo da Sprint Ativa:** 👉 [docs/sprints/sprint_3.md](docs/sprints/sprint_3.md)

---

## 4. Mapa de Roteamento de Contexto (Context Router)

Identifique o seu objetivo atual e abra **apenas** o arquivo correspondente para economizar a janela de contexto:

| Objetivo / Necessidade | Onde buscar o contexto | Descrição do Conteúdo |
| :--- | :--- | :--- |
| **Trabalhar na Sprint Atual** | [`docs/sprints/sprint_3.md`](docs/sprints/sprint_3.md) | Backlog ativo da Sprint 3 (Cards #21 a #30), cronograma diário, critérios de aceitação e estimativas. |
| **Consultar Sprints Passadas** | [`docs/sprints/sprint_2.md`](docs/sprints/sprint_2.md)<br>[`docs/sprints/sprint_1.md`](docs/sprints/sprint_1.md) | Histórico de implementação, cards concluídos (#1 a #20), decisões de knockback e sistemas base. |
| **Regras de Código & Arquitetura** | [`docs/guidelines/architecture_rules.md`](docs/guidelines/architecture_rules.md) | Tipagem GDScript, separação de nós (SRP), Juice/Game Feel por código, padrão `DestructionEffect` e estrutura de pastas. |
| **Didática, Módulos e PRs** | [`docs/guidelines/pedagogical_rules.md`](docs/guidelines/pedagogical_rules.md) | Formato dos módulos do curso, persona do Alfred, estrutura de capítulos e especificação completa de Pull Requests. |
| **Padrões de Commit & Git** | [`docs/guidelines/git_standards.md`](docs/guidelines/git_standards.md) | Regras do Conventional Commits, tipos permitidos (`feat`, `fix`, `refactor`, `test`, `docs`, `chore`) e escopos. |
| **Documentação Técnica de Entidades** | [`docs/modules/player.md`](docs/modules/player.md)<br>[`docs/modules/dummy.md`](docs/modules/dummy.md) | Arquitetura técnica detalhada de nós, propriedades, sinais e componentes existentes. |
| **Módulos Didáticos Publicados** | [`modulo1.md`](modulo1.md)<br>[`modulo2.md`](modulo2.md) | Capítulos pedagógicos completos já escritos para os estudantes do curso. |
| **Relatórios de Revisão de Sprint** | [`docs/sprint_1_review.md`](docs/sprint_1_review.md)<br>[`docs/sprint_2_review.md`](docs/sprint_2_review.md) | Validação de critérios de aceitação (DoD) e resultados de playtest das sprints finalizadas. |

---

## 5. Fluxo de Trabalho Recomendado para o Agente
1. Leia o **Fast Status** da seção 3 para confirmar a sprint e o card de foco.
2. Acesse [`docs/sprints/sprint_3.md`](docs/sprints/sprint_3.md) para absorver os critérios de aceitação do card a ser desenvolvido.
3. Se tiver dúvidas sobre arquitetura ou padrões de nós, consulte [`docs/guidelines/architecture_rules.md`](docs/guidelines/architecture_rules.md).
4. Ao concluir o código, crie o teste automatizado em `/tests/`.
5. Valide no Godot headless.
6. Commit e PR conforme [`docs/guidelines/git_standards.md`](docs/guidelines/git_standards.md) e [`docs/guidelines/pedagogical_rules.md`](docs/guidelines/pedagogical_rules.md).