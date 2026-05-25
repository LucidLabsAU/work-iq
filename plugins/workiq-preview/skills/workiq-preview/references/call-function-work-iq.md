# call_function_work_iq

Call a WorkIQ Graph function via HTTP GET. Graph functions are named operations that return computed results rather than stored entities — for example, `delta` (change tracking), `reminderView` (upcoming reminders), or `getSchedule` (free/busy availability).

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `functionUrl` | string | Yes | The function path including any required inline parameters (e.g., `/me/reminderView(startDateTime='...',endDateTime='...')`). Must be relative to the domain root — start with `/`, do not include a scheme or authority (`https://graph.microsoft.com` ❌, `/me/reminderView(...)` ✅). URL-encode any special characters in inline parameter values. |

## When to Use

- When you need free/busy availability for scheduling (`getSchedule`)
- When you need upcoming meeting reminders (`reminderView`)
- Any time a Graph path requires function call syntax `functionName(param=value)`

Distinguish from `fetch_work_iq`: use `call_function_work_iq` when the path includes a function invocation with inline parameters. Use `fetch_work_iq` for plain collection or item paths.

## Examples

### Get upcoming meeting reminders
```json
{ "functionUrl": "/me/reminderView(startDateTime='2024-06-01T00:00:00Z',endDateTime='2024-06-30T23:59:59Z')" }
```

### Get free/busy schedule for multiple users
```json
{ "functionUrl": "/me/calendar/getSchedule" }
```


