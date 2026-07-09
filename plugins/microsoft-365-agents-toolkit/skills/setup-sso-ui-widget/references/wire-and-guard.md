# Wire SSO + Inject Guard + Write Env (Phases 6, 7, 8)

## Phase 6 — Wire `mcpPlugin.json` + conversation starters

```powershell
pwsh -NoProfile -File "$SsoScripts/wire-mcpplugin.ps1"
```

Switches the `RemoteMCPServer` runtime auth from `None` → `OAuthPluginVault` (using the provisioned Auth ID), leaves the `${{MCP_SERVER_URL}}/mcp` placeholder intact, and — when `declarativeAgent.json` defines no starters of its own — copies the widget's starters from `mcpPlugin.json` (`capabilities.conversation_starters`) into it. No synthetic starters are injected: any tool call already performs the SSO token exchange, so the widget's real starters double as the SSO proof.

> **⚠️ Tunnel ↔ OAuth coupling.** The OAuth registration is created with `baseUrl: ${{MCP_SERVER_URL}}` (Phase 4), ATK derives the Application ID URI from that tunnel domain, and Phase 5 writes it into the Entra app's `identifierUris`. So the **dev tunnel domain is baked into the OAuth registration, the App ID URI, and the Entra app**. If the tunnel URL ever changes, authentication breaks until you re-sync — run `pwsh -NoProfile -File "$SsoScripts/resync-tunnel-url.ps1"` (auto-detects the new URL, or pass `-NewUrl https://...`), which re-runs Phases 4 → 5 → 6 → 9 so everything realigns.

## Phase 7 — Inject the minimal JWKS guard (Option A, no express)

### 7a. Add `jose` + write the guard (script)

```powershell
pwsh -NoProfile -File "$SsoScripts/inject-guard.ps1"
```

Installs `jose` and copies the hardened guard from [`auth.ts`](auth.ts) into `$McpServerDir/src/auth.ts`. The guard is **single-tenant**: it validates signature/aud/iss/exp via `jose` and additionally enforces `scp = access_as_user` + tenant match, rejecting app-only tokens. See [`sso-explained.md`](sso-explained.md) §3.

### 7b. Insert the guard into the `/mcp` POST handler (code edit — you do this)

> This edits the user's existing server file, so it's a model task (not a script). Open the MCP server entry file (`$McpServerDir/src/index.ts` or equivalent) and find the `POST /mcp` branch (`url.pathname === "/mcp"` and `req.method === "POST"`).

Add the import near the top of the file:
```typescript
import { validateBearerToken, claimsStore } from "./auth.js";
```

Then transform the POST `/mcp` branch from:
```typescript
if (req.method === "POST" && url.pathname === "/mcp") {
  let body = "";
  for await (const chunk of req) body += chunk;
  const parsedBody = JSON.parse(body);
  await handleMcpRequest(req, res, parsedBody);
  return;
}
```
into (guard first, then run the original logic inside the claims scope):
```typescript
if (req.method === "POST" && url.pathname === "/mcp") {
  let claims;
  try {
    claims = await validateBearerToken(req.headers.authorization);
  } catch (err) {
    // Return a GENERIC message to the caller; log the detailed reason server-side only.
    console.error("[auth] token rejected:", (err as Error).message);
    res.writeHead(401, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      jsonrpc: "2.0",
      error: { code: -32001, message: "Authentication required" },
      id: null,
    }));
    return;
  }
  // Gate the per-request identity log behind a debug flag so it doesn't run in production.
  if (process.env.SSO_DEBUG === "1") {
    console.log("[auth] Valid SSO token accepted:", { sid: claims.sid, aud: claims.aud, tid: claims.tid, iss: claims.iss });
  }
  await claimsStore.run(claims, async () => {
    let body = "";
    for await (const chunk of req) body += chunk;
    const parsedBody = JSON.parse(body);
    await handleMcpRequest(req, res, parsedBody);
  });
  return;
}
```

> Tools can read the signed-in user's claims anywhere via `claimsStore.getStore()` (`name`, `preferred_username`, `oid`, `tid`).

### 7c. Allow the `Authorization` header through CORS

> In the same file, add `Authorization` to `Access-Control-Allow-Headers` for `/mcp` (preflight + responses), e.g. `"Content-Type, mcp-session-id, Last-Event-ID, mcp-protocol-version, Authorization"`. Without this, browser preflights drop the token.

## Phase 8 — Write the server's SSO env

```powershell
pwsh -NoProfile -File "$SsoScripts/write-sso-env.ps1"
```

Writes `TENANT_ID` / `CLIENT_ID` / `APP_ID_URI` into `env/.env.local` (the server's dotenv audience). If your MCP server loads a different env file (check its `dotenv.config({ path: ... })`), write those three keys there instead.

> **☁️ Azure deployment note.** The copied `auth.ts` custom token validation is meant for **local dev/testing**. When you deploy to **Azure App Service** (or a similar host), the recommended practice is the platform's **built-in authentication ("Easy Auth" / App Service Authentication)** rather than custom token-validation code — it validates tokens at the platform edge, reduces the attack surface, and offloads key/issuer handling. Keep `auth.ts` for local runs; switch to Easy Auth for the hosted deployment.
>
> - Overview: [Authentication and authorization in Azure App Service](https://learn.microsoft.com/azure/app-service/overview-authentication-authorization)
> - MCP-specific (matches this scenario): [Configure MCP server authorization in Azure App Service](https://learn.microsoft.com/azure/app-service/configure-authentication-mcp) — App Service Authentication validates the MCP client's token for you; you pre-authorize the client (e.g. M365 Copilot) instead of hand-rolling a guard.
