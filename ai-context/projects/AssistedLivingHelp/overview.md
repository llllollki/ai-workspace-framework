# AssistedLivingHelp — Project Overview

> Migrated from `AssistedLivingHelp\CLAUDE.md`. Source document retained unchanged.

## Purpose

Build `Assisted Living Help`, a lead generation and placement-support platform for assisted living focused on selected California launch markets first, with the ability to expand across California and later across the United States.

The Phase 1 product should operate primarily as a guided matching and scheduling service, not just a gated directory.

The platform should have:

- A public-facing website and landing pages for paid social and local search traffic
- A guided questionnaire that captures lead information and care needs
- An automated confirmation flow that tells the family what happens next
- A backend application for lead management, matching, outreach, scheduling, and concierge follow-up
- A business development workflow for recruiting and managing facility partners
- A data layer backed initially by `facilities_ca.sqlite`

## Recommended Product Positioning

The MVP should be framed as a concierge-style assisted living matching service for defined hospital-centered markets.

Primary promise to the lead:

- tell us about your needs
- get matched with likely-fit facilities
- receive help scheduling calls or tours
- stay informed by SMS, email, and phone as needed

Secondary experience:

- signed-in or identified users may browse the vetted facility subset
- facility browsing supports trust and research, but it should not be the main conversion requirement for paid social traffic

Provider-side business goal:

- recruit assisted living facilities in the supported launch markets
- convert them into paying listing partners
- offer premium add-ons that increase visibility and operational support
- create a repeatable local-market business development motion

## Marketing And Acquisition Strategy

Phase 1 acquisition is expected to begin with Meta and other social ads targeting people looking for assisted care in the supported launch markets.

Recommended acquisition flow:

1. User clicks a Meta/social ad or a local landing page
2. User lands on a market-specific page tied to a hospital-centered service area
3. User completes a short guided questionnaire
4. User submits contact information and communication preferences
5. User receives immediate confirmation that the request was received
6. System creates or updates the lead record
7. System matches the lead to likely-fit facilities
8. Internal team and automation begin outreach and scheduling coordination

The platform should track attribution for:

- channel
- campaign
- ad set
- ad creative
- landing page variant
- referral source
- submit timestamp

## Current Data Reality

The current `facilities_ca.sqlite` database is useful, but it should not yet be treated as a fully product-ready directory database.

Important observations from the current SQLite file:

- The database contains ingestion and pipeline-oriented tables, not just clean application tables
- The facility corpus is broader than a pure assisted living directory and includes multiple facility types and naming conventions
- The strongest California-specific structured source currently appears to be the `ca_ccld_registry` table
- Canonical facility records are not yet fully enriched for search and discovery use
- Several desirable consumer-facing fields are currently sparse or empty

Implications:

- The MVP must be built around the subset of data that is reliable today
- Phase 1 should use a vetted operating subset, not the whole raw facility corpus
- Matching should emphasize dependable fields first
- Advanced filters such as pricing, amenities, reviews, websites, and live availability should be treated as future enrichment

## Initial Geographic Scope

- Phase 1: selected California hospital-centered markets only
- Phase 2: broader California expansion
- Phase 3: nationwide expansion across the USA

The architecture, routing, content model, and data model should be state-aware long term, but the product launch should be intentionally narrow.

## Phase 1 Launch Markets

Phase 1 should focus only on specific hospital-centered markets and the surrounding assisted living service area.

Initial hospital anchors:

- Temecula Valley Hospital
- Inland Valley Hospital
- Rancho Springs Hospital
- Loma Linda University Medical Center - Murrieta
- Menifee Global Medical Center

Phase 1 implications:

- The public site should present itself as a focused regional service, not a statewide directory
- Market pages, ad copy, matching, and internal routing should all be tied to these launch markets
- Leads and facilities should be tagged by `launch_market` and `hospital_anchor`
- The Phase 1 facility subset should be filtered to the cities, ZIP codes, and counties that support these hospital-centered markets

## Business Goal

Generate qualified assisted living leads and route those leads to facilities that can accommodate them, while helping families move from inquiry to scheduled calls or tours.

The system should collect enough information from each lead to:

- identify the inquirer and the prospective resident
- capture contact details and communication preferences
- understand care, timing, geography, and budget needs
- match the lead with relevant facilities
- coordinate scheduling for calls or tours
- track which facilities were contacted and how they responded
- support internal follow-up and concierge workflows

The business should also generate revenue by signing facility partners and selling listing and premium service packages.

## Non-Functional Requirements

- mobile-friendly responsive website
- clear separation between public site and internal backend
- public site should use `AssistedLivingHelp.com`
- internal admin should use `admin.AssistedLivingHelp.com`
- secure authentication and storage of personal information
- extensible architecture for multi-state rollout
- SEO-conscious structure for public content pages
- auditability for lead sharing and follow-up activity
- ability to expand from hospital-centered launch markets to broader regional and statewide coverage

## Early Architecture Direction

This is a starting point, not a locked decision.

### Frontend

- marketing website plus guided intake flow
- market-specific landing pages for paid traffic
- confirmation pages plus logged-in-only facility search
- information architecture centered around launch markets and hospital-area discovery

### Backend

- API layer for leads, facilities, matching, communication, consent, outreach, and scheduling
- admin dashboard for internal staff at `admin.AssistedLivingHelp.com`
- admin-controlled employee account management with username/password credentials
- workflows for manual lead entry, lead updates, outreach, and appointment lifecycle management
- partner CRM workflows for sales, onboarding, renewals, and account management

### Database

- read initially from the current SQLite facility dataset
- introduce a primary application database for leads, communications, consent, matches, outreach, appointments, and staff workflows
- build a vetted application-facing facility model from the reliable SQLite subsets
- optionally migrate normalized facility data later

## Compliance And Legal Guardrails

This document is a product and implementation brief, not legal advice. Counsel should review the final workflows, consent language, privacy disclosures, vendor setup, and go-live configuration.

### Privacy And Data Collection

The product should be designed as if strong California privacy requirements apply from day one.

Requirements:

- make notice at collection a mandatory launch requirement
- provide a clear notice at or before data collection
- the notice at collection should describe categories collected, purposes, categories of recipients, retention approach, and whether personal information is sold or shared for advertising
- publish a privacy policy that explains collection, use, sharing, retention, and consumer rights handling
- if ad-tech practices could count as selling or sharing, provide a compliant opt-out path and handle Global Privacy Control conservatively
- document retention periods and deletion/correction workflows
- minimize the amount of sensitive information collected upfront
- store communication preferences and opt-out status per channel

### Sensitive Health-Like Intake Data

The questionnaire may collect information that is highly sensitive in practice, even if the business is not a HIPAA-covered entity.

Requirements:

- do not collect detailed diagnosis, medication support, or similar health information during initial signup unless strictly necessary
- do not send questionnaire answers about health, care needs, diagnosis, mobility, or similar sensitive data to ad platforms for targeting or retargeting
- do not upload sensitive intake responses to Meta or similar platforms for audience building
- do not place Meta pixels, session replay, or similar tracking on intake steps, account pages, or pages where sensitive care information is submitted or viewed
- avoid privacy promises the business cannot fully support
- do not claim HIPAA compliance unless counsel confirms it is accurate and operationally true
- define retention limits and deletion rules for sensitive intake data

### Consent For SMS, Calls, Email, And Facility Sharing

Consent should be explicit, logged, and channel-specific.

Requirements:

- collect and log consent for SMS, email, and phone communication separately where appropriate
- disclose that the company may contact the lead to help with matching and scheduling
- obtain clear consent before sharing lead information with third-party facilities
- prefer identified-facility authorization or a tightly defined sharing scope instead of vague partner consent
- if facilities will send automated marketing texts or calls directly, gather seller-specific consent for each facility or keep those contacts manual until a compliant model is in place
- maintain internal do-not-contact suppression and revocation handling
- keep auditable consent records for website forms, Meta lead forms, phone intake, and manual CRM entry
- separate marketing consent from privacy acknowledgment and from any account creation flow
- make sure family-facing lead-sharing permissions and provider-facing marketing/sales outreach permissions are tracked separately

### Advertising And Fairness

Because the service is housing-related, ad targeting and delivery should be reviewed conservatively.

Requirements:

- avoid targeting or excluding audiences in ways that could create unlawful discrimination risk
- review ad copy, lookalike strategies, audience filters, and automation with housing sensitivity in mind
- avoid misleading claims about guaranteed placement, guaranteed availability, or guaranteed timelines
- clearly identify when the platform is a matching and coordination service rather than the facility itself
- avoid ad copy that implies hospital affiliation, medical-provider status, or government endorsement unless true
- clearly disclose any sponsored, featured, or priority placement in the consumer experience

### Email, Calling, And Telemarketing Guardrails

- marketing email must support unsubscribe and suppression handling
- calling and texting workflows must respect consent, revocation, and do-not-call handling
- automated confirmations should be clearly distinguishable from broader marketing campaigns
- the business should keep logs showing what was sent, why, and under what consent state
- maintain written do-not-call and SMS suppression procedures, including internal suppression handling and review of National Do Not Call obligations

### Security And Access Control

- role-based access for staff
- separate permission model for public users and internal staff
- public users may access only logged-in facility search and their own customer-facing account data
- internal admin access must be staff-only even if the admin app shares the same repo or deployment
- employee accounts should be created by admins, not public signup
- audit logs for lead sharing and edits
- secure storage of lead data
- vendor review for messaging, CRM, and analytics tools
- limited access to sensitive intake fields
- internal database policies must require staff membership or staff role checks, not merely any authenticated user
- written contracts with facilities and key vendors covering permitted use, security, breach handling, and deletion/return of lead data
- disclosure logs showing what lead information was shared, with whom, when, why, and under what consent basis
- encryption and incident-response planning for lead and care-related data
- partner contracts should also define package terms, billing terms, permitted use of lead data, and restrictions on reuse or resale

## Delivery Roles, Workstreams, And Handoffs

These roles should be used when applicable throughout planning, implementation, testing, launch, and operations.

The purpose of these roles is to create clear ownership and reliable handoffs across the project.

### Core Roles

- `Product / Program Lead`: owns priorities, scope, acceptance criteria, release readiness, and final business decisions
- `Compliance / Privacy Counsel`: reviews consent language, notice at collection, privacy disclosures, facility-sharing rules, ad-tech use, partner contracts, and launch-risk decisions
- `Technical Architect`: owns system boundaries, data model integrity, security architecture, integration patterns, and cross-cutting technical decisions
- `Developer`: implements features, fixes defects, adds tests, updates technical notes, and hands completed work to QA
- `QA / Test Lead`: validates acceptance criteria, regressions, edge cases, consent behavior, workflow behavior, and release readiness
- `Data / Matching Specialist`: owns SQLite source review, facility subset quality, mapping rules, matching logic validation, and data-quality checks
- `Operations / Concierge Workflow Lead`: owns real-world lead handling, outreach flow, scheduling flow, escalation rules, and operational usability requirements
- `Business Development / Partner Success Lead`: owns partner onboarding, package rules, facility communications, renewals, and provider workflow requirements
- `Content / Marketing Operations`: owns landing-page copy, ad and campaign messaging, confirmation messaging, disclosure placement, and approved funnel variants
- `Security / DevOps`: owns environments, secrets, access control, audit logging, deployment controls, monitoring, and incident readiness

### Role Usage Principles

- every work item should have one primary owner
- every work item should have at least one reviewer when review is needed
- acceptance criteria should be defined before implementation begins
- specialist roles should be pulled in whenever a task touches their area
- legal and compliance review should be performed by real qualified counsel before launch-critical decisions are finalized

### Collaboration Rules

- every work item must have one primary owner, one reviewer when applicable, and explicit acceptance criteria
- Compliance / Privacy Counsel must review any change involving consent, privacy disclosures, lead sharing, SMS/calling flows, ad-tech, or sensitive intake fields before release
- Technical Architect must review any change affecting data model, permissions, integrations, matching logic, or system-wide technical patterns before the work is considered complete
- Developer moves a task to QA only after implementation, relevant automated checks, and implementation notes are complete
- QA / Test Lead tests all completed work against requirements, regression risks, and edge cases
- if QA finds defects, the task returns to Developer with clear findings
- Developer fixes the issues and returns the task to QA for retest
- the Developer -> QA -> Developer -> QA loop continues until QA passes the work
- a task is not complete until QA passes it and the Product / Program Lead accepts it when business validation is required
- data-related changes require validation by the Data / Matching Specialist before release
- workflow changes affecting staff operations or facility coordination require sign-off from the Operations / Concierge Workflow Lead
- no launch-blocking compliance or security issue may be waived informally; the risk owner and Product / Program Lead must record the decision explicitly

### Standard Handoff Flow

1. `Product / Program Lead` defines the task, scope, and acceptance criteria.
2. `Compliance / Privacy Counsel`, `Technical Architect`, `Data / Matching Specialist`, or `Operations / Concierge Workflow Lead` review early when the task touches their area.
3. `Developer` implements the change.
4. `QA / Test Lead` tests the change.
5. If QA finds issues, `Developer` fixes them.
6. `QA / Test Lead` retests the work.
7. `Product / Program Lead` accepts the work for release when business validation is required.
8. `Security / DevOps` handles deployment readiness and production release controls when applicable.

## Pinned Versions

_TODO: Record pinned versions here once the stack, templates, and skills are formally locked._
