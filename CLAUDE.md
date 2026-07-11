# Work IQ — Copilot CLI Plugin Marketplace

GitHub Copilot CLI plugin marketplace shipping three plugin packages (`workiq`, `microsoft-365-agents-toolkit`, `workiq-productivity`). Only `workiq` references the externally-published `@microsoft/workiq` MCP server (npm). No build, compile, bundle, or test step in this repo — distribution is via the marketplace registry.

> **Precedence**: Inherits global (`~/.claude/CLAUDE.md`), workspace (`~/Documents/GitHub/CLAUDE.md`), and org (`LucidLabsAU/CLAUDE.md`). This file owns only repo-specific concerns.

## Commands

```bash
# Install plugins by path so local edits are picked up
copilot plugin install ./plugins/workiq
copilot plugin install ./plugins/microsoft-365-agents-toolkit
copilot plugin install ./plugins/workiq-productivity
copilot plugin list
copilot plugin uninstall <name>

# JSON lint a manifest change before commit
jq . .github/plugin/marketplace.json
jq . .claude-plugin/marketplace.json
```

After editing a SKILL.md or any plugin file, the running Copilot CLI session will not reload it — uninstall + reinstall the affected plugin and restart the session.

## Architecture

### Two marketplace registries (keep in sync)

There are **two** marketplace manifests listing the same three plugins. Both must stay aligned when a plugin is added/removed/renamed/versioned:

| File | Consumed by | Skill path style |
| --- | --- | --- |
| `.github/plugin/marketplace.json` | GitHub Copilot CLI (`/plugin marketplace add microsoft/work-iq`) | Repo-relative (`./plugins/<plugin>/skills/<skill>`) |
| `.claude-plugin/marketplace.json` | Claude Code marketplace tooling | Plugin-relative (`./skills/<skill>`) |

The two files use different path conventions — do not "normalise" them. Plugin `name`, `source`, `version`, and `description` must match across both.

### Plugin layout convention

```text
plugins/<plugin-name>/
├── .mcp.json               # OPTIONAL — only if plugin exposes an MCP server (currently only `workiq/`)
├── README.md               # Required
└── skills/<skill-name>/
    ├── SKILL.md            # Required — YAML frontmatter (name, description) + body
    └── references/         # Optional supporting docs
```

`workiq-productivity` and `microsoft-365-agents-toolkit` are skills-only (no `.mcp.json`). Don't add a `.mcp.json` to a skills-only plugin.

### Tenant admin scripts (PowerShell)

`scripts/Enable-WorkIQToolsForTenant.ps1` and `scripts/Verify-WorkIQTenant.ps1` provision missing MCP Server service principals (Work IQ Tools, Mail, Calendar, Teams, OneDrive, SharePoint, Word, Admin, Me, M365 Copilot) for tenants hitting AADSTS650052 / "Access Denied" on the one-click consent URL. Documented in `ADMIN-INSTRUCTIONS.md` — not run as part of repo development.

## Repo-specific gotchas

- **SKILL.md `description` hard limit: 1024 characters.** Copilot CLI silently drops skills whose description exceeds this — there is git history of a fix (`fdd3e11`) that trimmed descriptions for exactly this reason. Count characters before saving.
- Description should embed natural-language trigger phrases ("USE THIS SKILL when…", "Trigger phrases include…") — that string is what the Copilot router matches against.
- **No Node project.** No `package.json`, `node_modules`, or build step at the repo root. Node 18+ is a runtime prerequisite for end users running `npx -y @microsoft/workiq mcp`, not a dev dependency here.
- **Not the MCP server source.** `@microsoft/workiq` is built and published from `github.com/microsoft/work-iq-mcp` (see `server.json`). Don't look here for MCP tool implementations — only the skill prompts that drive them.
- **Required touch points** when adding/renaming/removing a plugin (see `CONTRIBUTING.md`): plugin directory, both `marketplace.json` files, root `README.md` plugin table, `PLUGINS.md` catalogue, `AGENTS.md`. `AGENTS.md` is the primary AI agent context document — treat it as a required edit.
- **`EULA/` is legal artefacts.** ~40 localised `.docx` files of pre-release licence terms — do not edit.
- **No test suite.** "Testing" per `CONTRIBUTING.md` means: validate `.mcp.json` is valid JSON, confirm the MCP server starts, verify skill docs are accurate.
