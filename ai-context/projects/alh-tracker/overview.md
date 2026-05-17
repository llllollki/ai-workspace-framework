# alh-tracker — Project Overview

## Purpose

Build `alh-tracker`, a California-first shift log and handoff tool for small RCFE operators. The product replaces paper binders, whiteboards, text chains, and verbal shift handoffs with a simple, mobile-friendly care operations log.

Core wedge: "Replace the paper binder. Make shift handoff fast, clear, and auditable."

Product mantra: "Fast enough for caregivers. Clear enough for handoff. Trustworthy enough for owners. Safe enough for future compliance." (positioning goal — no compliance claims without counsel review)

## Relationship to AssistedLivingHelp

`alh-tracker` is a separate product line inside the AssistedLivingHelp ecosystem.

- AssistedLivingHelp creates facility relationships through its family placement and lead-matching platform.
- `alh-tracker` makes those facility relationships stickier by helping operators manage daily care operations.
- Commercial starting assumption: standalone SaaS for non-ALH facilities; discounted or bundled for AssistedLivingHelp facility partners. Not yet locked — see `ai_memory.md` open question and task 0001.
- Data boundary: resident care data must not be shared with the AssistedLivingHelp placement or partner side. Any future cross-product data sharing requires explicit operator consent and legal review.

---

## Product Surfaces

ALH Tracker operates with three distinct product surfaces. Each has a defined user population, device policy, and data access scope. See ADR 0005 for the architectural decision governing these surfaces.

| Surface | Users | Device Policy |
|---|---|---|
| **Internal CRM** | ALH Tracker business/admin staff only | Desktop-only |
| **Facility Tracker App** | Facility owners, admins, caregivers, med techs | Mobile/tablet-first; desktop users directed to use phone/tablet |
| **Family Member App** | Family members authorized per resident | Mobile/tablet-first; desktop users directed to use phone/tablet — Planned Phase 2 |

**Internal CRM:** An internal ALH Tracker business tool for managing commercial relationships — facility owner/customer profiles, facility records, allowable resident count configuration, onboarding tracking, payment/subscription status, communications with facility owners, and support/admin notes. The CRM is not a care-delivery surface. CRM users are ALH Tracker business/admin staff; they are a distinct principal class separate from facility owners, caregivers, and family members. The CRM does not expose resident wellness/care logs. See ADR 0005.

**Facility Tracker App:** The primary care-operations product — shift logging, handoff, resident management, and daily care observation for facility owners and staff. This is the core alh-tracker product described throughout this documentation.

**Family Member App:** Planned Phase 2 separate mobile/tablet surface. View-only access to approved resident wellbeing data. Authentication model, invite mechanism, and app delivery format are TODO pending design and counsel review. Family app data access architecture is governed by ADR 0004.

**Desktop redirect note:** The mobile/tablet-first policy for the facility tracker app and family app means desktop users are directed to install/open the app on a phone or tablet. This is a distribution policy — not a security control and not a compliance measure. Whether desktop access is a hard block or a soft redirect is TODO. Whether facility owner/admin roles need any desktop access for administrative tasks is also TODO. The internal CRM remains desktop-only.

**TODO — CRM user authentication model:** CRM users authenticate via a mechanism separate from the facility tracker app and family app. The specific authentication model is pending CRM design.

---

## Recommended Product Positioning

### MVP Positioning

"A mobile-first shift log and handoff tool for California RCFE operators."

Long form: "Replace the paper binder with simple shift logs, resident routine tracking, and handoffs that work on caregiver phones, shared tablets, and desktop."

### Later Expansion

"Daily care visibility for residents, families, caregivers, and owners (pending Phase 2 counsel review and consent model approval), with a path toward stronger RCFE documentation and MAR/eMAR-adjacent workflows (only following a separate compliance and legal review confirming a safe and appropriate path — see `compliance_notes.md`)."

Family access is planned as a separate Phase 2 mobile/tablet surface — see Product Surfaces above.

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
| **Secondary beneficiary** | Family member | Wants reassurance and visibility; planned Phase 2 separate mobile/tablet app |
| **ALH Tracker business/admin staff** | Internal CRM user — not a care-delivery persona | Manages facility customer records, onboarding, subscription, communications, and support through the internal CRM desktop tool. Not a facility operator or caregiver. |

Do not collapse the buyer and daily user personas. Their needs, tech fluency, and failure modes differ significantly. Optimizing only for the buyer produces a dashboard that caregivers ignore. Optimizing only for the caregiver produces a logger the owner cannot get useful summaries from.

## Compliance and Regulatory Context

See `compliance_notes.md` for full detail.

- California RCFE facilities are regulated under CDSS Title 22.
- The MVP is not a compliance system, MAR/eMAR, clinical monitoring tool, or medical advice product.
- The data model must be designed to not block a future path toward stronger RCFE documentation or MAR-adjacent workflows.
- Audit trail, role-based access, and edit history are required from day one — non-negotiable.

## Non-Functional Requirements

- Mobile-friendly responsive web/PWA
- **Device policy:** Facility tracker app and family member app are mobile/tablet-first. Desktop users of these apps are directed to install/open the app on a phone or tablet (distribution policy — not a security or compliance control; implementation details TODO). The internal CRM is desktop-only.
- Works on caregiver phones and shared tablets (primary); desktop supported for owner/admin workflows in the facility tracker app pending resolution of the desktop access policy TODO above
- Offline-tolerant: must not silently lose work if WiFi is spotty
- Secure authentication and resident data storage
- Role-based access control
- Resident care data must not be sent to advertising or marketing analytics tools
- Audit trail on all care log entries from day one

## Pinned Versions

Facility tracker app: React 18 + TypeScript, Vite, Tailwind CSS, Zustand, React Router v6, lucide-react, date-fns. Production backend: Supabase (PostgreSQL + Auth + Row Level Security). Pinned versions are in `C:\Projects\alh-tracker\package.json`.
