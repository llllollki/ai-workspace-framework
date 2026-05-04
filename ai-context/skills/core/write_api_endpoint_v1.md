# Skill: Write API Endpoint — v1

## Purpose

Write a new API endpoint.

## When to Use

Use this skill when tasked with adding or modifying an API route.

## Inputs Required

- Endpoint purpose and expected behavior
- Authentication requirements
- Request and response shape
- Relevant API patterns (`global\api_patterns.md`)
- Project API spec (`projects\AssistedLivingHelp\api_spec.md`)
- Data model (`projects\AssistedLivingHelp\data_model.md`)

## Steps

1. Load API patterns and the project API spec.
2. Confirm the endpoint fits the existing API structure.
3. Implement the route handler.
4. Apply the correct authentication and authorization check.
   - For JSON API routes, use `getActiveStaffUser()` and return a manual 401. Do NOT use `requireActiveStaffUser()` — it calls `redirect()` from `next/navigation` and will not return a JSON error response.
5. Write tests covering success, error, and auth cases.
   - Note: As of 2026-05-03, no test framework is configured in this project. Verification is done via TypeScript type checking (`node node_modules/typescript/bin/tsc --noEmit`) and manual curl/Postman tests. Update this step when a test framework is added.
6. Document the endpoint using `templates\api_endpoint_v1.md`.

## Output

- Route handler file.
- Test file.
- API spec update in `projects\AssistedLivingHelp\api_spec.md` if a new route is added.

<!-- TODO: Refine with AssistedLivingHelp-specific route conventions once the API layer is built out. -->
