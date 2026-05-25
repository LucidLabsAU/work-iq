# do_action_work_iq

Execute a WorkIQ action via HTTP POST. Actions are named operations that perform a task (rather than creating a resource) — such as sending an email, copying a file, moving a message, or accepting a meeting invitation.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `actionUrl` | string | Yes | The action path (e.g., `/me/sendMail`, `/me/messages/{id}/copy`). Must be relative to the domain root — start with `/`, do not include a scheme or authority (`https://graph.microsoft.com` ❌, `/me/sendMail` ✅). URL-encode any special characters in path segments or query values. |
| `jsonBody` | string | No | JSON-encoded string with action parameters. Some actions require a body; others take no parameters. |

## When to Use

- Sending an email (rather than just creating a draft)
- Accepting, declining, or tentatively accepting a meeting invitation
- Copying or moving a message to another folder
- Forwarding a message
- Subscribing to change notifications

Distinguish from `create_entity_work_iq`: use `do_action_work_iq` for verbs (send, copy, move, accept) rather than creating a new stored resource.

## Examples

### Send an email immediately
```json
{
  "actionUrl": "/me/sendMail",
  "jsonBody": "{\"message\":{\"subject\":\"Hello\",\"body\":{\"contentType\":\"Text\",\"content\":\"Just checking in.\"},\"toRecipients\":[{\"emailAddress\":{\"address\":\"colleague@example.com\"}}]},\"saveToSentItems\":true}"
}
```

### Send a previously created draft
```json
{ "actionUrl": "/me/messages/{id}/send" }
```

### Copy a message to another folder
```json
{
  "actionUrl": "/me/messages/{id}/copy",
  "jsonBody": "{\"destinationId\":\"archive\"}"
}
```

### Move a message to a folder
```json
{
  "actionUrl": "/me/messages/{id}/move",
  "jsonBody": "{\"destinationId\":\"inbox\"}"
}
```

### Accept a meeting invitation
```json
{
  "actionUrl": "/me/events/{id}/accept",
  "jsonBody": "{\"comment\":\"See you there!\",\"sendResponse\":true}"
}
```

### Decline a meeting invitation
```json
{
  "actionUrl": "/me/events/{id}/decline",
  "jsonBody": "{\"comment\":\"Conflict — will catch up on recording.\",\"sendResponse\":true}"
}
```

### Forward a message
```json
{
  "actionUrl": "/me/messages/{id}/forward",
  "jsonBody": "{\"comment\":\"FYI\",\"toRecipients\":[{\"emailAddress\":{\"address\":\"teammate@example.com\"}}]}"
}
```

### Reply to a message
```json
{
  "actionUrl": "/me/messages/{id}/reply",
  "jsonBody": "{\"comment\":\"Thanks for the update!\"}"
}
```
