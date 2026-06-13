# get_schema

Retrieve the OpenAPI schema for a WorkIQ API path or operation. Use this to understand what fields are available on an entity, what parameters a query accepts, and what body shape is required for create/update operations.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `path` | string | No* | Entity path (e.g., `/me/messages`). Preferred over `operationIds`. |
| `operationIds` | string | No* | Operation ID (e.g., `me.CreateMessages`). Use if you don't know the path. |
| `httpMethod` | string | No | HTTP method filter: `get`, `post`, `patch`, or `delete`. Narrows results when a path supports multiple methods. |
| `apiVersion` | string | No | `v1.0` (default) or `beta`. Use `beta` for preview features. |

*Provide either `path` or `operationIds` — at least one is required.

## When to Use

- Before calling `create_entity` or `update_entity` to understand the required body shape
- When `fetch` returns unfamiliar fields and you want to understand their meaning
- When you need to know what OData query parameters (`$filter`, `$select`, `$orderby`) are supported
- To check if a `beta` endpoint has fields not available in `v1.0`

## Examples

### Get the schema for reading messages
```json
{ "path": "/me/messages", "httpMethod": "get" }
```

### Get the schema for creating a calendar event
```json
{ "path": "/me/events", "httpMethod": "post" }
```

### Get the schema for updating a message
```json
{ "path": "/me/messages/{id}", "httpMethod": "patch" }
```

### Get a beta schema
```json
{ "path": "/me/messages", "httpMethod": "get", "apiVersion": "beta" }
```

### Look up by operation ID
```json
{ "operationIds": "me.CreateMessages" }
```
