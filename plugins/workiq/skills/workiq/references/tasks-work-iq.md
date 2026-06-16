# Tasks (Planner)

Use the WorkIQ **entity tools** for task/follow-up requests whose data lives in
Microsoft 365 — **not** the CLI's local task files, the session SQL `todos` table, or any
other on-disk task tracker. If the user says "add a task", "remind me to…", "follow up
with…", "mark … done", or "list my tasks", that is M365 data: route it to WorkIQ.

> **⚠️ Do not fall back to local/builtin task storage.** Creating a markdown file or
> inserting into a local database does **not** satisfy an M365 task request and is not
> recoverable by the user in Planner. If a WorkIQ task call fails, report the
> failure — do not silently substitute local storage.

## Planner — canonical paths

| Operation | Tool | Path |
|-----------|------|------|
| List my plans | `fetch` | `/me/planner/plans` |
| List tasks in a plan | `fetch` | `/planner/plans/{planId}/tasks` |
| Create a task | `create_entity` | parentUrl `/planner/tasks` (body includes `planId`) |
| Update / complete a task | `update_entity` | `/planner/tasks/{taskId}` |
| Delete a task | `delete_entity` | `/planner/tasks/{taskId}` |

Planner task body fields: `planId`, `title`, `bucketId`, `assignments`, `dueDateTime`,
`percentComplete` (`0` = not started, `50` = in progress, `100` = complete).

- **Mark a Planner task done:** `update_entity` with `{"percentComplete":100}`.
- **Planner gotcha:** `update_entity` / `delete_entity` on Planner resources
  require the current `@odata.etag` (an `If-Match` precondition). Fetch the task first to
  read its etag; if a Planner write returns a `412`/precondition error, re-fetch and retry.

## Resolve-then-act (do not loop)

1. Resolve the target with **one** `fetch` (Planner task) — match by `title`.
2. If the first fetch does not find it, try **one** `ask` to locate it semantically.
3. If still not found, **stop and report "not found"** — do not fire 10+ more `fetch`/`search_paths`/`ask` calls.
4. Once you have the id, call the mutation (`create_entity` / `update_entity` / `delete_entity`).

## Examples

### Create a Planner task
```json
{ "parentUrl": "/planner/tasks",
  "jsonBody": "{\"planId\":\"{planId}\",\"title\":\"Follow up with finance\"}" }
```

### Mark a Planner task complete
```json
{ "entityUrl": "/planner/tasks/{taskId}",
  "jsonBody": "{\"percentComplete\":100}" }
```
