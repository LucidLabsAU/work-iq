# WorkIQ CLI commands (out-of-band of the MCP server)

Some WorkIQ operations are **not exposed as MCP tools** and must be run as shell commands — most commonly authentication management, scope consent, config inspection, and version checks. Run these in a terminal (not via the MCP server) when you need them.

## Invocation

**Always invoke via `npx -y @microsoft/workiq@preview <command>`.** This guarantees you hit the exact same binary version that the MCP server uses (the `@preview` tag for this plugin), avoiding mismatches with any globally-installed `workiq` on `PATH`. All variants share the same `~/.workiq` config file, so changes made by these commands are immediately visible to the running MCP server (you may need to restart it to re-read auth state).

## Command reference

| Task | Command |
|------|---------|
| Check installed version | `npx -y @microsoft/workiq@preview version` |
| Sign in (default account) | `npx -y @microsoft/workiq@preview auth login` |
| Sign in with a specific account | `npx -y @microsoft/workiq@preview auth login --account user@contoso.com` |
| Sign out / clear cached tokens | `npx -y @microsoft/workiq@preview auth logout` |
| Grant additional Graph scopes | `npx -y @microsoft/workiq@preview auth consent --scopes Mail.Read Calendars.Read` |
| Show current config | `npx -y @microsoft/workiq@preview config show` |
| Set a config value | `npx -y @microsoft/workiq@preview config set <key>=<value>` |
| Remove a config key | `npx -y @microsoft/workiq@preview config unset <key>` |
| Reset config to defaults | `npx -y @microsoft/workiq@preview config reset` |
| Accept the EULA | `npx -y @microsoft/workiq@preview accept-eula` |
| Generate a debug share link | `npx -y @microsoft/workiq@preview debug <conversationId>` |

## When to use these

- A tool call returns **HTTP 403 Forbidden** → run `auth consent --scopes <scopes>` with the scopes needed for that Graph path.
- Sign-in is broken or hangs on Windows → `config set disableBrokeredAuth=true` to force browser-based login.
- You suspect a **stale token** or wrong cached account → `auth logout` then `auth login` (optionally with `--account`).
- You want to verify the running binary version matches the plugin → `version`.

After any `auth` or `config` change, restart your Copilot CLI session so the MCP server picks up the new state.
