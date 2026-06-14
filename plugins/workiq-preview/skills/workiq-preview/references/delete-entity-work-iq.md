# delete_entity

Delete a WorkIQ entity via HTTP DELETE. This is a permanent operation — use with care, especially for emails and calendar events.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `entityUrl` | string | Yes | The entity path including the item's ID (e.g., `/me/events/{id}`). Must be relative to the domain root — start with `/`, do not include a scheme or authority (`https://graph.microsoft.com` ❌, `/me/events/{id}` ✅). URL-encode any special characters in path segments. |

## When to Use

- Deleting a calendar event
- Deleting a draft email
- Removing a Planner task
- Deleting a Teams message (where permitted)

## Gotchas

- **Email deletion moves to Deleted Items**, it does not permanently delete. That is the right
  default for any "delete / remove / get rid of this email" request — use this tool. Reach for
  `do_action` with `/me/messages/{id}/permanentDelete` only when the user explicitly
  asks for permanent, unrecoverable removal, and only against the **single resolved message ID**
  — never loop permanentDelete across a list of messages.
- **Calendar event deletion** removes it from the calendar and sends cancellation notices to attendees if it was an organized meeting.
- Always confirm the entity ID with `fetch` before deleting to avoid removing the wrong item.

## Workflow

1. Use `fetch` to confirm you have the correct entity and its ID
2. Call `delete_entity` with the entity's full path including ID

## Examples

### Delete a calendar event
```json
{ "entityUrl": "/me/events/{id}" }
```

### Delete a draft email
```json
{ "entityUrl": "/me/messages/{id}" }
```

### Delete a Planner task
```json
{ "entityUrl": "/planner/tasks/{taskId}" }
```
