# Skill: Build Auth Flow — v1

## Purpose

Build or modify an authentication or authorization flow.

## When to Use

Use this skill when implementing login, signup, session management, role checks, or access control.

## Inputs Required

- Auth flow type (public user signup, staff login, password reset, role check)
- Auth provider in use (Supabase Auth for AssistedLivingHelp)
- Access control requirements (`projects\AssistedLivingHelp\overview.md` — Security And Access Control section)
- Data model for user and role entities (`projects\AssistedLivingHelp\data_model.md`)

## Steps

1. Load security requirements from `projects\AssistedLivingHelp\overview.md`.
2. Confirm the auth provider and session model.
3. Implement the flow following the access control rules.
4. Confirm that internal admin access is staff-only and not accessible to public users.
5. Confirm that database policies require staff role checks, not merely any authenticated user.
6. Write tests covering success, failure, and unauthorized access cases.

## Rules (AssistedLivingHelp)

- Employee accounts are created by admins, not public signup.
- Public users may access only logged-in facility search and their own account data.
- Internal admin must be staff-only.
- Database-level policies must enforce staff membership checks, not merely any authenticated user.

Source: `projects\AssistedLivingHelp\overview.md` — Security And Access Control (under Compliance And Legal Guardrails); originally migrated from the project brief.

<!-- TODO: Update with the confirmed Supabase role model once defined. -->
