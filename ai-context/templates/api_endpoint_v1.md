# API Endpoint Template — v1

## Responsibility

Use this template when documenting a new API endpoint.

## Template

```markdown
# [METHOD] /[path]

## Purpose

[One sentence describing what this endpoint does.]

## Authentication

[Required auth level: public / authenticated user / staff only / admin only]

## Request

### Path Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|

### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|

### Request Body

```json
{
}
```

## Response

### Success — [status code]

```json
{
}
```

### Error Responses

| Status | Condition |
|---|---|

## Side Effects

[Any database writes, emails sent, events triggered, etc.]

## Notes

[Any non-obvious behavior, rate limits, or constraints.]
```

## Versioning

This is `api_endpoint_v1`. See `orchestration\versioning_rules.md` for when to create a v2.
