# alh-tracker — Project Overview

## Purpose

Build `alh-tracker`, a California-first shift log and handoff tool for small RCFE operators. The product replaces paper binders, whiteboards, text chains, and verbal shift handoffs with a simple, mobile-friendly care operations log.

Core wedge: "Replace the paper binder. Make shift handoff fast, clear, and auditable."

Product mantra: "Fast enough for caregivers. Clear enough for handoff. Trustworthy enough for owners. Safe enough for future compliance."

## Relationship to AssistedLivingHelp

`alh-tracker` is a separate product line inside the AssistedLivingHelp ecosystem.

- AssistedLivingHelp creates facility relationships through its family placement and lead-matching platform.
- `alh-tracker` makes those facility relationships stickier by helping operators manage daily care operations.
- Commercial starting assumption: standalone SaaS for non-ALH facilities; discounted or bundled for AssistedLivingHelp facility partners. Not yet locked — see `ai_memory.md` open question and task 0001.
- Data boundary: resident care data must not be shared with the AssistedLivingHelp placement or partner side. Any future cross-product data sharing requires explicit operator consent and legal review.

## Recommended Product Positioning

### MVP Positioning

"A mobile-first shift log and handoff tool for California RCFE operators."

Long form: "Replace the paper binder with simple shift logs, resident routine tracking, and handoffs that work on caregiver phones, shared tablets, and desktop."

### Later Expansion

"Daily care visibility for residents, families, caregivers, and owners, with a path toward stronger RCFE documentation and MAR/eMAR-adjacent workflows."

## Target Market

- California-first
- RCFE-focused MVP
- Small care homes, ideally 6–20 residents
- Existing workflow likely uses paper binders, texts, whiteboards, spreadsheets, or verbal handoffs
- First design partner: a California RCFE in this profile, willing to allow observation of real shift workflows and test a prototype

## Primary Personas

| Persona | Role | Failure mode if ignored |
|---|---|---|
| **Buyer** | RCFE owner / operator / administrator | Evaluates and purchases; cares about liability, audit trails, family satisfaction, and regulatory posture |
| **Daily user** | Caregiver, med tech, house manager | Uses every shift under time pressure; needs to be faster than the paper binder or they revert to it |
| **Secondary beneficiary** | Family member | Wants reassurance and visibility; not part of MVP |

Do not collapse the buyer and daily user personas. Their needs, tech fluency, and failure modes differ significantly. Optimizing only for the buyer produces a dashboard that caregivers ignore. Optimizing only for the caregiver produces a logger the owner cannot get useful summaries from.

## Compliance and Regulatory Context

See `compliance_notes.md` for full detail.

- California RCFE facilities are regulated under CDSS Title 22.
- The MVP is not a compliance system, MAR/eMAR, clinical monitoring tool, or medical advice product.
- The data model must be designed to not block a future path toward stronger RCFE documentation or MAR-adjacent workflows.
- Audit trail, role-based access, and edit history are required from day one — non-negotiable.

## Non-Functional Requirements

- Mobile-friendly responsive web/PWA
- Works on caregiver phones, shared tablets, and desktop
- Offline-tolerant: must not silently lose work if WiFi is spotty
- Secure authentication and resident data storage
- Role-based access control
- Resident care data must not be sent to advertising or marketing analytics tools
- Audit trail on all care log entries from day one

## Pinned Versions

_TODO: Record pinned versions once the tech stack is selected._
