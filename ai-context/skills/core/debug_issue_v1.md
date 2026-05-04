# Skill: Debug Issue — v1

## Purpose

Diagnose and resolve a bug or unexpected behavior.

## When to Use

Use this skill when tasked with investigating and fixing a reported issue.

## Inputs Required

- Description of the unexpected behavior
- Steps to reproduce
- Expected vs. actual behavior
- Relevant files or components

## Steps

1. Reproduce the issue using the provided steps.
2. Identify the root cause — do not guess; trace the actual execution path.
3. Confirm the scope of the fix: is this a single-file change or cross-cutting?
4. Implement the minimum fix required to resolve the root cause.
5. Verify the fix resolves the issue without introducing regressions.
6. Update the task document with findings and fix notes.

## Rules

- Fix the root cause, not just the symptom.
- Do not add error handling for cases that cannot happen.
- Do not refactor surrounding code as part of a bug fix unless the refactor is necessary to fix the bug.

## Output

- Fixed code.
- Test case covering the bug scenario (add to prevent regression).
- Task document updated with findings.
