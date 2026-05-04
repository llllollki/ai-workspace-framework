# Coding Standards

## Responsibility

This file defines shared coding conventions that apply across all projects in this workspace.

## What Belongs Here

- Language and framework conventions (TypeScript, Next.js, etc.)
- File and folder naming rules
- Import ordering and module structure
- Code formatting rules (Prettier, ESLint config references)
- Testing conventions
- Error handling patterns
- Security coding requirements

## What Does Not Belong Here

- Project-specific business logic patterns (belong under `projects\<project>\`)
- API patterns (see `api_patterns.md`)
- Build or deployment config (belong in the project repo)

## Related Files

- `api_patterns.md` — API-specific conventions
- `templates\` — file templates that follow these standards

---

## Stack Reference (AssistedLivingHelp)

The current project uses:

- Next.js App Router
- TypeScript
- Supabase Auth + Postgres
- Google Workspace (MVP email)
- Google Voice (MVP phone and SMS)

Source: `AssistedLivingHelp\README.md`

---

<!-- TODO: Document specific TypeScript, Next.js App Router, and Supabase coding conventions as they are established during implementation. -->
