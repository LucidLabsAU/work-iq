# fetch

Fetch one or more WorkIQ entities by path using HTTP GET. Use this for precise, structured retrieval of M365 data when `ask` isn't specific enough — for example, to get a list of items with specific fields, apply filters, or read a single entity by ID.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entityUrls` | string[] | Yes | One or more entity paths to fetch. Must be relative to the domain root (start with `/`, no scheme or authority). Supports OData query parameters (`$filter`, `$select`, `$top`, `$orderby`, `$expand`). All query parameter values must be URL-encoded. |

## When to Use

- When you need a structured list of entities (messages, events, files, etc.)
- When you need to apply specific OData filters or select specific fields
- When you already have an entity ID and want its full details
- For multi-fetch: pass multiple URLs to retrieve several entities in one call

Prefer `ask` for open-ended questions. Use `fetch` when you need precise, filtered, or structured data.

> **⚠️ Not for delta queries.** Calling `/.../delta` or `/.../delta()` through `fetch`
> fails — delta is an OData **function** and must go through `call_function`. See
> `references/call-function-work-iq.md`.

## Multi-fetch caveats

- A single call accepts **at most 50** entity URLs.
- The batch result can report an error when **any one** URL fails, even if the other URLs
  returned data. If a multi-fetch errors, don't discard it — check for successful payloads
  inside the response, and re-issue only the failing URL on its own to isolate the problem.
  When a URL might fail (permissions, existence unknown), prefer small batches or single URLs.

## Pagination

Collection responses are **pages**, not the full result set. When a response contains
`@odata.nextLink`, more results exist:

- To get the next page, call `fetch` again with the `@odata.nextLink` value converted to
  a server-relative path (strip the scheme/authority/version prefix, keep the path and query
  string — including the opaque `$skiptoken`).
- **Do not paginate with `$skip`** — many collections (notably `/me/calendarView`) do not
  support it and the call fails.
- If you stop before exhausting pages, **tell the user the list is partial** ("first 25 of
  more") — never present one page as the complete answer.
- **Cap your paging.** For "latest/recent" questions one page is usually enough; otherwise stop
  after 2–3 pages unless the user explicitly asked for the complete set. Do not follow
  `@odata.nextLink` for dozens of pages to enumerate an entire mailbox or message history.

## URL Format

Paths must:
- Start with `/` (relative to the domain root)
- **Not** include a scheme or authority — `https://graph.microsoft.com/v1.0/me/messages` ❌, `/me/messages` ✅
- Have all query parameter values URL-encoded

Common URL encodings for OData query values:

| Character | Encoded | Example |
|-----------|---------|---------|
| Space | `%20` | `$filter=isRead%20eq%20false` |
| Single quote `'` | `%27` | `$filter=subject%20eq%20%27Hello%27` |
| `(` | `%28` | `$filter=startsWith%28subject%2C%27Re%3A%27%29` |
| `)` | `%29` | (same as above) |
| `:` | `%3A` | (in string literals) |
| `/` *(only inside string-literal values)* | `%2F` | (e.g. inside a quoted `$filter` value) |
| `,` *(only inside string-literal values)* | `%2C` | (in string literals; **not** in `$select=a,b,c` lists) |

> **Important — what NOT to encode:**
> - OData **property paths** like `start/dateTime`, `from/emailAddress/address`: leave the `/` raw. Use `$orderby=start/dateTime`, never `$orderby=start%2FdateTime`.
> - **Comma-separated `$select` lists** like `$select=subject,from,receivedDateTime`: leave the `,` raw. Only encode commas that appear inside a quoted value.
> - OData keywords and field names (`$filter=`, `isRead`, `eq`, `desc`): standard ASCII, no encoding needed.

## OData Query Tips

| Parameter | Purpose | Example |
|-----------|---------|---------|
| `$top` | Limit result count | `$top=10` |
| `$filter` | Filter results | `$filter=isRead%20eq%20false` |
| `$select` | Return only specified fields | `$select=subject,from,receivedDateTime` |
| `$orderby` | Sort results | `$orderby=receivedDateTime%20desc` |
| `$expand` | Include related entities inline | `$expand=attachments` |

## Examples

### Get the signed-in user's profile
```json
{ "entityUrls": ["/me"] }
```

### Get unread emails (top 10)
```json
{ "entityUrls": ["/me/messages?$top=10&$filter=isRead%20eq%20false&$select=subject,from,receivedDateTime"] }
```

### Get upcoming calendar events
```json
{ "entityUrls": ["/me/events?$top=5&$orderby=start/dateTime&$select=subject,start,end,location"] }
```

### Get a specific message by ID
```json
{ "entityUrls": ["/me/messages/{id}"] }
```

### Fetch multiple entities in one call
```json
{ "entityUrls": ["/me", "/me/mailFolders/inbox"] }
```

### Get files from OneDrive
```json
{ "entityUrls": ["/me/drive/root/children?$select=name,size,lastModifiedDateTime"] }
```

### Get Teams channels for a group
```json
{ "entityUrls": ["/teams/{teamId}/channels"] }
```
