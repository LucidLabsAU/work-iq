# Work IQ

Work IQ is a **Copilot CLI plugin marketplace** for managing AI agent plugins for GitHub Copilot CLI. It provides MCP servers, skills, and tools that connect AI assistants to Microsoft 365 data.

## Repository Structure

```
work-iq/
├── .github/
│   └── plugin/
│       └── marketplace.json  # Plugin marketplace registry
├── plugins/                  # Plugin packages (skills + MCP servers)
│   ├── workiq/
│   ├── workiq-preview/
│   ├── microsoft-365-agents-toolkit/
│   └── workiq-productivity/
├── server.json               # MCP server manifest
├── ADMIN-INSTRUCTIONS.md     # Tenant admin consent guide
├── CONTRIBUTING.md           # Guide for adding new plugins
├── PLUGINS.md                # Plugin catalog — skills, agents, and commands
└── AGENTS.md                 # This file
```

## Installing Plugins

This repo is a [Copilot CLI plugin marketplace](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/plugins-marketplace). Install plugins using the marketplace workflow below.

### Quick install (copy-paste ready)

```bash
copilot plugin install ./plugins/workiq
copilot plugin install ./plugins/workiq-preview
copilot plugin install ./plugins/microsoft-365-agents-toolkit
copilot plugin install ./plugins/workiq-productivity
```

> **Important:** After installing, restart your Copilot CLI session for new skills to become available.

### Check what's installed

```bash
copilot plugin list
```

### Removing a plugin

```bash
copilot plugin uninstall workiq
copilot plugin uninstall workiq-preview
copilot plugin uninstall microsoft-365-agents-toolkit
copilot plugin uninstall workiq-productivity
```

## Plugins

Plugins live in `plugins/<plugin-name>/` and follow this structure:

```
plugins/<plugin-name>/
├── .mcp.json              # MCP server config (if plugin has an MCP server)
├── README.md              # Plugin documentation
└── skills/                # Skill definitions
    └── <skill-name>/
        ├── SKILL.md       # Skill definition with YAML frontmatter
        └── references/    # Supporting docs (optional)
```

### Available plugins

- **workiq** — Query Microsoft 365 data with natural language. Bundles:
  - `workiq` skill — Guides usage of the `ask_work_iq` MCP tool for emails, meetings, documents, Teams messages, and people
  - MCP server (`@microsoft/workiq`) with tools: `ask_work_iq`, `accept_eula`, `get_debug_link`

- **workiq-preview** — Preview build with the full WorkIQ tool surface (read + write). Bundles:
  - `workiq-preview` skill — Guides usage of `ask_work_iq` for semantic questions plus the entity tools for fast, structured M365 reads and writes
  - MCP server (`@microsoft/workiq@preview`) with tools: `ask_work_iq`, `fetch_work_iq`, `fetch_blob_work_iq`, `get_schema_work_iq`, `search_paths_work_iq`, `create_entity_work_iq`, `update_entity_work_iq`, `delete_entity_work_iq`, `do_action_work_iq`, `call_function_work_iq`, `upload_blob_work_iq`, `accept_eula`, `get_debug_link`

- **microsoft-365-agents-toolkit** — Toolkit for building M365 Copilot declarative agents. Bundles:
  - `install-atk` skill — Install or update the M365 Agents Toolkit CLI and VS Code extension
  - `declarative-agent-developer` skill — Scaffolding, JSON manifest authoring, capability configuration, deployment
  - `ui-widget-developer` skill — Build MCP servers with OpenAI Apps SDK widget rendering for Copilot Chat
  - `m365-agent-evaluator` skill — Generate, run, and analyze evaluation suites for M365 Copilot declarative agents

- **workiq-productivity** — Read-only WorkIQ productivity insights. Bundles:
  - `action-item-extractor` skill — Extract action items with owners, deadlines, and priorities
  - `daily-outlook-triage` skill — Quick summary of inbox and calendar for the day
  - `email-analytics` skill — Analyze email patterns (volume, senders, response times)
  - `meeting-cost-calculator` skill — Calculate time and cost spent in meetings
  - `org-chart` skill — Visual ASCII org chart for any person
  - `multi-plan-search` skill — Search tasks across all Planner plans
  - `site-explorer` skill — Browse SharePoint sites, lists, and libraries
  - `channel-audit` skill — Audit channels for inactivity and cleanup
  - `channel-digest` skill — Summarize activity across multiple channels

## Prerequisites

- **Node.js 18+** — Required for the workiq MCP server (`npx`)
- **Admin consent** — The WorkIQ MCP server requires tenant admin consent on first use. See the [Tenant Administrator Enablement Guide](./ADMIN-INSTRUCTIONS.md) for details.

## Creating a New Plugin

```bash
mkdir -p plugins/my-plugin/skills/my-skill/references
```

Create the required files:

**`README.md`** — Plugin documentation with installation instructions, skill table, and usage examples.

**`skills/<name>/SKILL.md`** — Skill definition with YAML frontmatter.
**The `description` field must not exceed 1024 characters** — the Copilot CLI runtime silently drops skills that exceed this limit.
```yaml
---
name: my-skill
description: >
  What this skill does.
  Triggers: "trigger phrase 1", "trigger phrase 2"
---

# My Skill

Skill instructions here...
```

**`.mcp.json`** (optional) — MCP server configuration if your plugin exposes tools:
```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@my-org/my-package", "mcp"],
      "tools": ["*"]
    }
  }
}
```

After creating a plugin:
1. Register it in `.github/plugin/marketplace.json` by adding an entry to the `plugins` array
2. Install it with `copilot plugin install ./plugins/my-plugin`

---

## Self-Maintenance Instructions

> **Important:** When making changes to this repository — adding new plugins or modifying workflows — update this AGENTS.md file to reflect those changes. This file serves as the primary context document for AI agents working in this repo. Keep it accurate and current. Specifically:
>
> - Add new plugins to the "Available plugins" section when they are created
> - Register new plugins in `.github/plugin/marketplace.json`
> - Update "Getting Started" if new setup steps are required
> - Update "Repository Structure" if top-level directories change
> - **After editing any skill or plugin content**, reinstall the affected plugin so the running session picks up the changes:
>   ```bash
>   copilot plugin uninstall <plugin-name>
>   copilot plugin install ./plugins/<plugin-name>
>   ```

---

## Azure resource tagging (org-wide standard)

Every Azure resource provisioned in any LucidLabsAU repo must carry the standard tag set. The lowercase keys are required by the tenant `require-standard-tags` policy.

| Tag | Type | Example |
| --- | --- | --- |
| `project` | kebab-case string | `lucid-operations` |
| `environment` | enum | `prod` / `nonprod` / `dev` / `staging` |
| `managedBy` | enum | `Bicep` / `Terraform` / `manual` |
| `costCentre` | enum | `Integration` / `Platform` / `Security` / `Productivity` / `Identity` / `Governance` / `Marketing` / `Engineering` / `rd-platform` |
| `application` | string | `Lucid Hub + MCP Server` |
| `owner` | email | `keith@oakai.au` |
| `mapping_tag` | GUID | `guid('LucidLabsAU/<repo>', '<path/to/file.bicep>')` |

Legacy PascalCase keys (`Application`, `Environment`, `ManagedBy`, `CostCenter`) may co-exist for backwards compatibility but lowercase is canonical.

### `mapping_tag` — Defender for Cloud code-to-cloud linkage

The `mapping_tag` GUID lets Microsoft Defender for Cloud correlate this deployed Azure resource back to its source Bicep file (Cloud Security Explorer → *Provisioned by* → *Code repositories*). Use a deterministic GUID derived from repo + path so it survives redeploys:

```bicep
mapping_tag: guid('LucidLabsAU/<repo-name>', '<path/to/file.bicep>')
```

In Bicep:

- **Single-file template:** add to a `commonTags` var and apply via `tags: commonTags`.
- **Multi-module template:** parent declares `commonTags`; pass via `tags` param to each module. If a module has inline tags (no parent passthrough), add `mapping_tag` inline using its own path.
- **Resource group declarations:** tag the RG with the full standard set including `mapping_tag`.

**Resource types that REJECT user tags** (don't try): `Microsoft.Insights/diagnosticSettings`, `Microsoft.OperationsManagement/solutions`, `Microsoft.Automation/automationAccounts/runbooks`, `microsoft.alertsmanagement/smartDetectorAlertRules`, some `Microsoft.Web/certificates`, some `Microsoft.EventGrid/systemTopics`, `Microsoft.App/agents`. Their parents carry the linkage instead.

**Caveats:**
- Defender's IaC mapping is GA on Azure DevOps, partial on GitHub (the MSDO GitHub Action does not ship `IaCFileScanner`). Authoring `mapping_tag` now is forward-compatible.
- ~12-hour propagation delay before Defender Cloud Security Explorer reflects the link.
- Requires Defender CSPM plan (Foundational CSPM is insufficient).

Reference: <https://learn.microsoft.com/azure/defender-for-cloud/iac-template-mapping>
