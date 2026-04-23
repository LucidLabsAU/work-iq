# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repo is a **GitHub Copilot CLI plugin marketplace** — not an application. It ships three plugin packages (`workiq`, `microsoft-365-agents-toolkit`, `workiq-productivity`) that bundle skills (markdown + YAML frontmatter) and, for `workiq` only, a reference to the externally-published `@microsoft/workiq` MCP server (npm). There is no build, compile, bundle, or test step in this repo — distribution is via the marketplace registry that consumers add to their Copilot CLI.

## Two Marketplace Registries (Keep In Sync)

There are **two** marketplace manifests that list the same three plugins, and they must stay aligned when a plugin is added/removed/renamed/versioned:

| File | Consumed by | Notes |
|------|-------------|-------|
| `.github/plugin/marketplace.json` | GitHub Copilot CLI (`/plugin marketplace add microsoft/work-iq`) | Skill paths are **repo-relative** (`./plugins/<plugin>/skills/<skill>`) |
| `.claude-plugin/marketplace.json` | Claude Code marketplace tooling | Skill paths are **plugin-relative** (`./skills/<skill>`) |

The two files use different path conventions for the `skills` arrays — do not "normalise" them. Plugin `name`, `source`, `version`, and `description` should match across both.

## Plugin Layout Convention

```
plugins/<plugin-name>/
├── .mcp.json               # OPTIONAL — only if plugin exposes an MCP server (currently only `workiq/`)
├── README.md               # Required
└── skills/<skill-name>/
    ├── SKILL.md            # Required — YAML frontmatter (name, description) + body
    └── references/         # Optional supporting docs
```

`workiq-productivity` and `microsoft-365-agents-toolkit` are skills-only (no `.mcp.json`) — they call out to the `workiq` MCP server installed by the `workiq` plugin or to external CLIs (e.g. ATK CLI). Don't add a `.mcp.json` to a skills-only plugin unless it is genuinely exposing its own server.

## SKILL.md Authoring Rules

- **`description` field hard limit: 1024 characters.** Copilot CLI silently drops skills whose description exceeds this — there is git history of a fix (`fdd3e11`) that trimmed descriptions for exactly this reason. When editing, count characters before saving.
- Frontmatter requires at least `name` and `description`. The description should embed natural-language trigger phrases ("USE THIS SKILL when…", "Trigger phrases include…") because that string is what the Copilot router matches against.
- Body uses standard markdown; reference docs go under `skills/<name>/references/` (see `microsoft-365-agents-toolkit/skills/declarative-agent-developer/references/` for the established pattern).

## Working With Plugins Locally

The marketplace itself isn't installed during development; install plugins by path so edits are picked up:

```bash
copilot plugin install ./plugins/workiq
copilot plugin install ./plugins/microsoft-365-agents-toolkit
copilot plugin install ./plugins/workiq-productivity
copilot plugin list
copilot plugin uninstall <name>
```

**After editing a SKILL.md or any plugin file, the running Copilot CLI session will not reload it** — uninstall + reinstall the affected plugin and restart the session.

## Adding / Modifying a Plugin — Required Touch Points

When adding a new plugin or renaming/removing one, all of these must be updated together (see `CONTRIBUTING.md` PR checklist):

1. `plugins/<name>/` directory with `README.md` + at least one `skills/<skill>/SKILL.md`
2. `.github/plugin/marketplace.json` — add entry with repo-relative skill paths
3. `.claude-plugin/marketplace.json` — add entry with plugin-relative skill paths
4. `README.md` (root) — plugin table near the bottom
5. `PLUGINS.md` — full catalog entry (skills table, example prompts, MCP server section if applicable)
6. `AGENTS.md` — "Available plugins" section

`AGENTS.md` is the primary context document for AI agents working in this repo (separate from this file) and explicitly asks to be kept current — treat it as a required edit, not optional.

## Tenant Admin Scripts (PowerShell)

`scripts/Enable-WorkIQToolsForTenant.ps1` and `scripts/Verify-WorkIQTenant.ps1` are admin-side tooling for tenants hitting AADSTS650052 / "Access Denied" on the one-click consent URL. They provision the missing MCP Server service principals (Work IQ Tools, Mail, Calendar, Teams, OneDrive, SharePoint, Word, Admin, Me, M365 Copilot) and grant admin consent. They are documented in `ADMIN-INSTRUCTIONS.md`; they are not run as part of repo development.

## What This Repo Is NOT

- **Not the MCP server source.** `@microsoft/workiq` is built and published from `github.com/microsoft/work-iq-mcp` (see `server.json`). Don't look here for MCP tool implementations — only the skill prompts that drive them.
- **Not a Node project.** There is no `package.json`, `node_modules`, or build step at the repo root. Node 18+ is a runtime prerequisite for end users running `npx -y @microsoft/workiq mcp`, not a dev dependency here.
- **No test suite.** "Testing" per `CONTRIBUTING.md` means: validate `.mcp.json` is valid JSON, confirm the MCP server starts, verify skill docs are accurate. Lint a JSON change with `jq . <file>` before committing.

## EULA Files

`EULA/` contains ~40 localised `.docx` files of the pre-release license terms. Do not edit these; they are legal artefacts.
