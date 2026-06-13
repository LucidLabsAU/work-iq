# search_paths

Discover available WorkIQ API paths by searching with a regex filter. Use this as the first step when you need to work with entity tools but aren't sure what paths are available for a given resource type.

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `filter` | string | No | Regex pattern to match against available paths (e.g., `messages`, `.*calendar.*`). Omit to list all paths. |
| `backend` | string | No | Which backend to search: `graph-v1` (default), `sharepoint-rest`, or `dataverse` |

## When to Use

- Before using `fetch`, `create_entity`, or other entity tools when you're unsure of the exact path
- To discover what data is accessible for a given concept (e.g., "what calendar-related paths exist?")
- To explore the SharePoint REST or Dataverse backends

## Recommended Workflow

1. Call `search_paths` with a broad filter to find candidate paths
2. Call `get_schema` on the path you want to use to understand its fields and parameters
3. Call `fetch` or the appropriate write tool with the confirmed path

## Examples

### Find all message-related paths
```json
{ "filter": "messages" }
```

### Find calendar paths
```json
{ "filter": ".*calendar.*" }
```

### List all available paths (no filter)
```json
{}
```

### Search SharePoint REST paths
```json
{ "backend": "sharepoint-rest" }
```

### Find Planner paths
```json
{ "filter": "planner" }
```

### Find OneDrive/files paths
```json
{ "filter": "drive" }
```
