# Versioning Rules

## Responsibility

This file defines when to create a new versioned template or skill, how to deprecate old versions, and where to record framework changes.

## What Belongs Here

- Version naming conventions for templates and skills
- Rules for creating a new version vs. editing in place
- Deprecation process
- Where to log framework changes

## What Does Not Belong Here

- Project-specific decisions (see `projects\AssistedLivingHelp\decisions\`)
- Application code versioning

---

## Version Naming

Templates and skills use a `_vN` suffix (e.g., `component_v1.md`, `component_v2.md`).

Start at `v1`. Increment only when a breaking change is made that would invalidate existing uses of the prior version.

## When to Create a New Version

Create a new `_vN` file when:

- The template or skill's expected inputs, outputs, or behavior change in a way that is incompatible with prior usage.
- An existing task document pins the prior version and should not be silently updated.

Do NOT create a new version for:

- Wording improvements that don't change behavior.
- Adding optional guidance that doesn't affect existing users.
- Bug fixes or clarifications.

## Deprecation Process

1. Add a `> DEPRECATED as of YYYY-MM-DD. Use <new-file>.md instead.` notice at the top of the old file.
2. Do not delete the old file until all references to it are updated.
3. Record the deprecation in `ai-context\CHANGELOG.md`.

## Where to Record Framework Changes

| Change type | Where to record |
|---|---|
| New template or skill | `ai-context\CHANGELOG.md` + `skills\skills_index.md` |
| Deprecated template or skill | `ai-context\CHANGELOG.md` |
| New project context file | `ai-context\projects\<project>\execution_log.md` |
| Application code decisions | `ai-context\projects\<project>\decisions\` |

## Project Decisions vs. Framework Version History

- Framework versioning (`CHANGELOG.md`) tracks structural documentation changes.
- Project decisions (`decisions\`) track durable application-level choices (auth strategy, state management, data model decisions, etc.).
- Do not conflate the two.
