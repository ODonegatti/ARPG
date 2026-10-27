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
Toda interação, geração de código ou alteração deve respeitar estes 6 mandamentos:

1. **Tipagem Estática Rigorosa:** Sempre declare tipos explícitos para variáveis, parâmetros e retornos no GDScript (`var vel: Vector2 = Vector2.ZERO`, `func take_damage(amount: int) -> void:`).
2. **Godot 4 Exclusivo:** Nunca use métodos, propriedades ou convenções da Godot 3.
3. **Teste Obrigatório Antes de Commitar:** Toda alteração ou card DEVE ter sua suíte correspondente em `/tests` testada e validada em modo headless antes de qualquer commit.
4. **Conventional Commits Estrito:** Commits no formato `<tipo>(<escopo>): <descrição curta>`.
5. **Zero Scope Creep:** Foco cirúrgico na DoD (*Definition of Done*) do card ativo da Sprint.
6. **Padrão de Roteamento de Contexto para IA Obrigatório:** Qualquer nova implementação DEVE incluir cabeçalho de roteamento no GDScript (`AI Context Router`) e atualizar os roteadores locais correspondentes (`scripts/README.md`, `scenes/README.md`, `tests/README.md`, `docs/modules/index.md`).

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
| **Consultar Sprints Passadas** | [`docs/sprints/index.md`](docs/sprints/index.md) | Índice geral de sprints: [`sprint_1.md`](docs/sprints/sprint_1.md) e [`sprint_2.md`](docs/sprints/sprint_2.md). |
| **Roteador de Scripts e Código** | [`scripts/README.md`](scripts/README.md) | Tabela de todos os scripts, camadas, responsabilidades, testes e docs vinculadas. |
| **Roteador de Cenas e Nós** | [`scenes/README.md`](scenes/README.md) | Mapeamento de cenas `.tscn`, nós filhos, Physics Layers (1 a 5) e scripts acoplados. |
| **Roteador de Testes Automatizados** | [`tests/README.md`](tests/README.md) | Catálogo de testes headless, cards validados e comandos para execução via CLI. |
| **Roteador de Módulos Técnicos** | [`docs/modules/index.md`](docs/modules/index.md) | Índice de especificações técnicas: [`player.md`](docs/modules/player.md), [`dummy.md`](docs/modules/dummy.md). |
| **Regras de Código & Arquitetura** | [`docs/guidelines/architecture_rules.md`](docs/guidelines/architecture_rules.md) | Tipagem GDScript, separação de nós (SRP), Juice por código, `DestructionEffect` e Padrão de Roteamento. |
| **Didática, Módulos e PRs** | [`docs/guidelines/pedagogical_rules.md`](docs/guidelines/pedagogical_rules.md) | Formato dos módulos do curso, persona do Alfred, estrutura de capítulos e especificação completa de PR. |
| **Padrões de Commit & Git** | [`docs/guidelines/git_standards.md`](docs/guidelines/git_standards.md) | Regras do Conventional Commits, tipos permitidos (`feat`, `fix`, `refactor`, `test`, `docs`, `chore`) e escopos. |
| **Módulos Didáticos Publicados** | [`modulo1.md`](modulo1.md)<br>[`modulo2.md`](modulo2.md) | Capítulos pedagógicos completos já escritos para os estudantes do curso. |
| **Relatórios de Revisão de Sprint** | [`docs/sprint_1_review.md`](docs/sprint_1_review.md)<br>[`docs/sprint_2_review.md`](docs/sprint_2_review.md) | Validação de critérios de aceitação (DoD) e resultados de playtest das sprints finalizadas. |

---

## 5. Fluxo de Trabalho e Padrão para Qualquer Implementação
1. **Entrada:** Leia a seção 3 deste arquivo e abra [`docs/sprints/sprint_3.md`](docs/sprints/sprint_3.md) para ler o card a ser implementado.
2. **Contexto Específico:** Consulte [`scripts/README.md`](scripts/README.md) e [`scenes/README.md`](scenes/README.md) apenas se precisar de referências dos nós existentes.
3. **Desenvolvimento:** Implemente a lógica com tipagem estrita e insira o bloco `AI Context Router` no cabeçalho do script GDScript.
4. **Testes Headless:** Crie/atualize o arquivo de teste em `/tests/` e valide via `godot --headless -s tests/<teste>.gd`.
5. **Atualização dos Roteadores:** Registre o novo script/cena/teste em `scripts/README.md`, `scenes/README.md` e `tests/README.md`.
6. **Commit & PR:** Siga o Conventional Commits e o modelo de PR definido em [`docs/guidelines/pedagogical_rules.md`](docs/guidelines/pedagogical_rules.md).