# Installing prerequisites for the WorkIQ plugin

The WorkIQ MCP server is distributed as the npm package `@microsoft/workiq` and is launched by Copilot CLI via `npx`. This requires:

- **Node.js 18 or later** (LTS recommended)
- **npm** (bundled with Node.js — provides the `npx` command)

To verify what's installed:

```powershell
node --version
npm --version
npx --version
```

All three commands should print a version number. If `node --version` reports `< v18.0.0`, upgrade using one of the options below.

---

## Windows

### Option A — winget (recommended, built into Windows 10/11)

```powershell
winget install OpenJS.NodeJS.LTS
```

### Option B — Chocolatey

```powershell
choco install nodejs-lts
```

### Option C — Scoop

```powershell
scoop install nodejs-lts
```

### Option D — Official installer

Download and run the Windows installer (`.msi`) from <https://nodejs.org/en/download> and pick the **LTS** build.

> After installing, **open a new terminal** so the updated `PATH` is picked up, then **restart the Copilot CLI session**.

---

## macOS

### Option A — Homebrew (recommended)

```powershell
brew install node
```

### Option B — Official installer

Download and run the macOS installer (`.pkg`) from <https://nodejs.org/en/download> and pick the **LTS** build.

### Option C — nvm (if you manage multiple Node versions)

```powershell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Then in a new shell:
nvm install --lts
nvm use --lts
```

---

## Linux

### Debian / Ubuntu

```powershell
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### Fedora / RHEL / CentOS Stream

```powershell
sudo dnf install -y nodejs npm
```

### Arch / Manjaro

```powershell
sudo pacman -S --noconfirm nodejs npm
```

### Alpine

```powershell
sudo apk add --no-cache nodejs npm
```

### Any distro — nvm (per-user, no sudo)

```powershell
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Then in a new shell:
nvm install --lts
nvm use --lts
```

---

## Cross-platform — Volta

[Volta](https://volta.sh) installs and pins Node.js per project and works the same on Windows, macOS, and Linux.

```powershell
# macOS / Linux
curl https://get.volta.sh | bash

# Windows
winget install Volta.Volta

# Then in a new shell:
volta install node@lts
```

---

## After installing

1. **Open a new terminal window** so the updated `PATH` is loaded.
2. Verify with `node --version` — it should print `v18.x.x` or newer.
3. **Restart the Copilot CLI session** — MCP servers are only launched at session start, so the existing session won't pick up the newly installed `npx`.
4. Retry the WorkIQ tool call that originally failed.

## Still failing?

- On Windows, if `node --version` works in a new terminal but Copilot CLI still can't find `npx`, fully close and reopen the terminal application (not just the tab), then start Copilot CLI again.
- Ensure that the directory containing `node`/`npx` is on the `PATH` for the user running Copilot CLI. On Windows: `where.exe npx`. On macOS/Linux: `which npx`.
- If you use `nvm` or `volta`, make sure the shell that launches Copilot CLI sources the version manager's init script (e.g., `~/.bashrc`, `~/.zshrc`).
