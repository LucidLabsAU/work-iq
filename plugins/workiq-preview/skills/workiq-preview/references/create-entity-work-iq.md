# create_entity_work_iq

Create a new WorkIQ entity by POSTing to a collection path. Use this to create calendar events, draft emails, tasks, Teams messages, and other M365 resources.

> **⚠️ Writes are persistent.** Creating a calendar event sends invitations to attendees; creating a draft email is invisible until sent but takes up space; creating a task or message in a shared list is visible to collaborators. **Before invoking, summarize what you're about to create (subject, attendees, due date, parent list/folder) and get the user's explicit confirmation.**

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `parentUrl` | string | Yes | The parent collection path to POST to (e.g., `/me/events`, `/me/messages`). Do not include an ID — this creates a new item. Must be relative to the domain root — start with `/`, do not include a scheme or authority (`https://graph.microsoft.com` ❌, `/me/events` ✅). URL-encode any special characters in path segments. |
| `jsonBody` | string | Yes | JSON-encoded string with the fields for the new entity. Use `get_schema_work_iq` on the path with `httpMethod: "post"` first if unsure of required fields. |

## When to Use

- Creating a new calendar event
- Creating a draft email (use `do_action_work_iq` with `/me/sendMail` to send immediately)
- Creating a new Planner task
- Creating a new Teams channel message
- Any time you need to POST a new item to a collection

## Workflow

1. Call `get_schema_work_iq` with the collection URL and `httpMethod: "post"` to confirm required fields
2. Call `create_entity_work_iq` with the collection URL and a valid body
3. Save the returned `id` if you need to reference or update the entity later

## Examples

### Create a calendar event
```json
{
  "parentUrl": "/me/events",
  "jsonBody": "{\"subject\":\"Team Sync\",\"start\":{\"dateTime\":\"2024-06-01T10:00:00\",\"timeZone\":\"Pacific Standard Time\"},\"end\":{\"dateTime\":\"2024-06-01T11:00:00\",\"timeZone\":\"Pacific Standard Time\"},\"attendees\":[{\"emailAddress\":{\"address\":\"colleague@example.com\"},\"type\":\"required\"}]}"
}
```

### Create a draft email
```json
{
  "parentUrl": "/me/messages",
  "jsonBody": "{\"subject\":\"Project update\",\"body\":{\"contentType\":\"HTML\",\"content\":\"<p>Here is the latest update...</p>\"},\"toRecipients\":[{\"emailAddress\":{\"address\":\"manager@example.com\"}}]}"
}
```

### Create a Planner task
```json
{
  "parentUrl": "/planner/tasks",
  "jsonBody": "{\"planId\":\"{planId}\",\"title\":\"Update client list\"}"
}
```
