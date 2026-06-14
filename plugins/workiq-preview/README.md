# Work IQ Plugin — Preview

> **Preview build.** Full WorkIQ tool surface for GitHub Copilot CLI: agentic semantic queries via `ask` **plus** direct, structured reads and writes against Microsoft 365 — emails, meetings, calendar, documents, Teams messages, OneDrive/SharePoint files, and people.

## Installation

### Via GitHub Copilot CLI Plugin Marketplace

```bash
/plugin install workiq-preview@work-iq
```

### Via MCP Configuration

Add to your `.mcp.json` or IDE MCP settings:

```json
{
  "workiq-preview": {
    "command": "npx",
    "args": ["-y", "@microsoft/workiq@preview", "mcp"],
    "tools": ["*"]
  }
}
```

## Updating

If you installed WorkIQ globally with npm, run the following command to install or update to the latest preview build:

```bash
npm install -g @microsoft/workiq@preview
```

> **Note:** `npm update` ignores dist-tag specifiers, so it will not switch you to the preview channel. Use `npm install` as shown above.

To verify the installed version after updating:

```bash
workiq version
```

> 💡 **Using npx?** If you run WorkIQ via `npx -y @microsoft/workiq@preview mcp`, npx automatically fetches the latest version each time, so no manual update step is needed.

## Usage

The preview plugin exposes the full WorkIQ tool surface — read **and** write — via 11 MCP tools.

### Semantic queries (`ask`)

```
"What did John say about the proposal?"
"Summarize emails from the leadership team this week"
"What's top of mind for Sarah?"
"Find the design doc for the authentication system"
"Who is working on Project Alpha?"
```

### Structured reads (`fetch`, `search_paths`, `get_schema`, `fetch_blob`)

```
"List my unread emails from Sarah this week"
"What meetings do I have Monday?"
"Show me the channels in the DevX team"
"List files in my OneDrive 'Specs' folder"
"Who are Rob's direct reports?"
"Download the latest PowerPoint from my OneDrive 'Specs' folder"
```

### Writes (`create_entity`, `update_entity`, `delete_entity`, `do_action`, `upload_blob`)

> ⚠️ Writes execute immediately and are visible to other people or unrecoverable. The skill is instructed to confirm with you before sending mail, forwarding, accepting/declining meetings, or permanently deleting.

```
"Send the draft email to the engineering distribution list"
"Create a calendar event Friday at 3pm with the design team"
"Accept the 2pm meeting from Rob"
"Decline the Monday standup — I'll catch up on the recording"
"Mark Sarah's last three emails as read"
"Reply to the deadline thread with 'on track for Friday'"
"Upload report.pdf to my OneDrive root"
"Move the design review thread to the Archive folder"
```

### CLI commands (out-of-band of the MCP server)

Some operations are not exposed as MCP tools and must be run as shell commands — `auth login`/`logout`, `auth consent` (granting additional Graph scopes), `config show`/`set`/`reset`, `version`. Invoke them via `npx -y @microsoft/workiq@preview <command>` to guarantee you hit the same binary the MCP server uses. See [`skills/workiq-preview/references/cli-commands.md`](./skills/workiq-preview/references/cli-commands.md) for the full reference.

## Skills

| Skill | Description |
|-------|-------------|
| [**workiq-preview**](./skills/workiq-preview/SKILL.md) | Guides usage of the full WorkIQ tool surface — `ask` for semantic questions plus entity tools for fast, structured M365 reads and writes |

## Platform Support

Supported on `win_x64`, `win_arm64`, `linux_x64`, `linux_arm64`, `osx_x64`, and `osx_arm64`.

## License

See the root [LICENSE](../../LICENSE) file.
