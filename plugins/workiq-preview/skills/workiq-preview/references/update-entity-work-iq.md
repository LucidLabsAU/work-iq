# update_entity_work_iq

Update an existing WorkIQ entity via HTTP PATCH. Only the fields you include in the body are changed — other fields are left untouched.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entityUrl` | string | Yes | The entity path including the item's ID (e.g., `/me/events/{id}`). Get the ID from a prior `fetch_work_iq` or `create_entity_work_iq` call. Must be relative to the domain root — start with `/`, do not include a scheme or authority (`https://graph.microsoft.com` ❌, `/me/events/{id}` ✅). URL-encode any special characters in path segments. |
| `jsonBody` | string | Yes | JSON-encoded string containing only the fields to update. Omit fields you don't want to change. |

## When to Use

- Marking an email as read/unread
- Updating the subject, time, or location of a calendar event
- Changing the status or due date of a task
- Updating a document's metadata
- Any partial update to an existing M365 entity

## Workflow

1. Obtain the entity's `id` from `fetch_work_iq` or `create_entity_work_iq`
2. Optionally call `get_schema_work_iq` with `httpMethod: "patch"` to confirm which fields are updatable
3. Call `update_entity_work_iq` with only the fields you want to change

## Examples

### Mark a message as read
```json
{
  "entityUrl": "/me/messages/{id}",
  "jsonBody": "{\"isRead\":true}"
}
```

### Update a calendar event's subject and location
```json
{
  "entityUrl": "/me/events/{id}",
  "jsonBody": "{\"subject\":\"Updated: Team Sync\",\"location\":{\"displayName\":\"Conference Room B\"}}"
}
```

### Update a Planner task's due date
```json
{
  "entityUrl": "/planner/tasks/{taskId}",
  "jsonBody": "{\"dueDateTime\":\"2024-06-10T17:00:00Z\"}"
}
```

### Mark a Planner task as complete
```json
{
  "entityUrl": "/planner/tasks/{taskId}",
  "jsonBody": "{\"percentComplete\":100}"
}
```

### Move a message to a different category
```json
{
  "entityUrl": "/me/messages/{id}",
  "jsonBody": "{\"categories\":[\"Project Alpha\"]}"
}
```
