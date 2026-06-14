# do_action

Execute a WorkIQ action via HTTP POST. Actions are named operations that perform a task (rather than creating a resource) — such as sending an email, copying a file, moving a message, accepting a meeting invitation, or computing free/busy availability across multiple calendars.

> **⚠️ Write actions execute immediately.** `/me/sendMail`, `/forward`, `/accept`, `/decline`, `/permanentDelete`, and similar verbs take effect right away and are visible to other people or unrecoverable. **Before invoking, summarize the action (recipients, subject, body, target ID) and get the user's explicit confirmation.** Do not auto-send drafts or auto-respond to meeting invites without confirmation.

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
- Replying to a message
- Computing free/busy availability for multiple users (`getSchedule`)
- Reacting to a Teams message (`setReaction`)
- Setting the user's Teams presence (`setUserPreferredPresence`)
- Initiating a large file upload session (`createUploadSession`)
- Subscribing to change notifications

Distinguish from `create_entity`: use `do_action` for verbs (send, copy, move, accept, reply, getSchedule) rather than creating a new stored resource. If an operation has a function-like name (`getSchedule`, `findMeetingTimes`) but takes a JSON body, it's still an action — POST it through this tool.

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

### Get free/busy availability for multiple users (`getSchedule`)
```json
{
  "actionUrl": "/me/calendar/getSchedule",
  "jsonBody": "{\"schedules\":[\"adelev@contoso.com\",\"meganb@contoso.com\"],\"startTime\":{\"dateTime\":\"2024-06-03T09:00:00\",\"timeZone\":\"Pacific Standard Time\"},\"endTime\":{\"dateTime\":\"2024-06-03T18:00:00\",\"timeZone\":\"Pacific Standard Time\"},\"availabilityViewInterval\":60}"
}
```

`availabilityViewInterval` is optional minutes (default 30, min 5, max 1440). `schedules` is a string array of SMTP addresses (users, distribution lists, rooms, or equipment).

### Set my Teams presence to Busy
```json
{
  "actionUrl": "/me/presence/setUserPreferredPresence",
  "jsonBody": "{\"availability\":\"Busy\",\"activity\":\"Busy\",\"expirationDuration\":\"PT1H\"}"
}
```

Use `setUserPreferredPresence` for user requests ("set me to Busy"). The `setPresence` action is the application-session variant and requires a `sessionId` — don't fall back to it without one.

### React to a Teams chat message
```json
{
  "actionUrl": "/chats/{chatId}/messages/{messageId}/setReaction",
  "jsonBody": "{\"reactionType\":\"like\"}"
}
```

For channel messages use the `/teams/{teamId}/channels/{channelId}/messages/{messageId}/setReaction` path. See `references/teams-work-iq.md` for chat-vs-channel resolution.

### Initiate a large file upload session
```json
{
  "actionUrl": "/me/drive/root:/Projects/big-file.zip:/createUploadSession",
  "jsonBody": "{\"item\":{\"@microsoft.graph.conflictBehavior\":\"replace\"}}"
}
```

The response returns an `uploadUrl` you can PUT chunks to. Use this for files larger than 4MB (`upload_blob`'s simple PUT limit).
