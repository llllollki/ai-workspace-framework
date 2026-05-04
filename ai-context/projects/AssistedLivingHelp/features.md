# AssistedLivingHelp — Features and Product Capabilities

> Migrated from `AssistedLivingHelp\CLAUDE.md`. Source document retained unchanged.
> For pricing numbers, optional add-ons, sales scripts, and BD operational detail, see `business_development.md`.

## Core Product Areas

### 1. Public Website

The website is the customer-facing acquisition and trust-building layer.

Goals:

- attract users in the supported launch markets who are looking for assisted living help
- present a trustworthy, professional, conversion-oriented experience
- route visitors into a guided intake flow
- let identified users review matched or relevant facilities

Design direction:

- use [Avvo](https://www.avvo.com/) as a reference for clarity, trust-building structure, and conversion patterns
- do not copy Avvo directly
- borrow only high-level patterns such as strong search/discovery framing, trust sections, and clear calls to action

### 2. Guided Questionnaire And Lead Capture

The Phase 1 conversion flow should be a short guided questionnaire rather than requiring full browsing first.

Recommended first-session questionnaire fields:

- full name
- email address
- phone number
- preferred contact method
- relationship to resident
- hospital area / launch market
- desired city or region
- move-in timeframe
- general care category
- budget comfort or budget range
- whether the family wants help scheduling calls or tours
- best time to contact

Fields that may be captured later through follow-up:

- more detailed care needs
- memory care needs
- mobility needs
- deeper clinical details
- medication support needs
- room preferences
- diagnosis history
- payer details
- special preferences

Questionnaire design requirements:

- optimize for completion rate first
- use progressive profiling instead of asking everything upfront
- apply data minimization at first touch
- clearly distinguish required and optional questions
- allow save-and-resume or follow-up completion where possible
- support both website forms and Meta lead form ingestion
- keep Meta/social lead forms limited to top-of-funnel contact capture and non-sensitive matching inputs

### 3. Automated Confirmation And Customer Communications

When a lead submits information, the platform should immediately confirm receipt and set expectations.

The confirmation layer should support:

- on-screen confirmation page
- email confirmation
- SMS confirmation when the user has given appropriate permission

Phase 1 MVP communications note:

- Google Workspace should be treated as the primary MVP email system
- Google Voice should be treated as the primary MVP phone number and SMS workflow
- manual outreach and follow-up are acceptable defaults for MVP
- do not assume a fully automated Resend/Twilio-style communications layer unless the operating plan changes

The confirmation message should say:

- the request was received
- the team will help identify facilities and coordinate calls or tours
- when the family should expect the next update
- how the family can correct details or reply

Customer communication requirements:

- communication timeline must be visible internally
- all outbound communications should be logged
- the system should support SMS, email, and phone-call workflows
- communication preference and opt-out status must be respected
- MVP implementation should support manual Google Workspace and Google Voice operations even if deeper automation is deferred

### 4. Facility Discovery And Match Presentation

After submission, leads should be able to see facilities available in the supported Phase 1 markets and/or receive a shortlist of likely-fit matches.

For the MVP, this should be interpreted as a vetted facility subset within the supported launch markets, not the full raw SQLite dataset.

Recommended Phase 1 facility scope:

- prioritize RCFE / elderly residential care records backed by reliable licensing and location data
- use `ca_ccld_registry` as the strongest Phase 1 operating base
- treat broader canonical facility records as enrichment candidates, not automatically display-ready records
- exclude or carefully filter facilities with non-active or non-public statuses
- restrict launch inventory to the geographic catchment areas for the five hospital anchors

Data caveats for v1:

- geographic search is only dependable where location fields are actually populated
- pricing, availability, amenities, services, websites, and reviews should not be treated as consistently available yet
- matching should rely on dependable fields such as city, ZIP, county, facility type, capacity, and licensing status

Discovery experience should support over time:

- search by city, ZIP code, county, or region
- search by hospital service area / launch market
- filter by care level and reliably available attributes first
- facility detail pages
- transparent match explanations

Phase 1 logged-in discovery requirements:

- `/facilities` should include a search and filter section above the results list
- Phase 1 family-facing filters should use understandable language and dependable fields first
- the primary Phase 1 filters should be type of home, ZIP code, city, county, and capacity when populated
- facility type / care category may power the user-facing "type of home" filter
- licensing and public-visibility status should be used primarily for internal curation and public display eligibility, not as a primary family-facing filter unless the wording is clear
- advanced filters such as pricing, amenities, reviews, websites, and live availability should remain future-phase, not Phase 1 defaults
- clicking a facility result should open a dedicated profile page for that vetted facility record
- the Phase 1 facility profile page should show dependable fields such as name, city, state, ZIP, county, phone, type of home, capacity when available, and licensing status when present and clearly understandable
- the Phase 1 facility profile page should include a call to action back into intake or matching help, so browsing supports conversion rather than replacing the concierge flow
- both facility search and facility profile pages are logged-in user features only
- Phase 1 should stay intentionally narrow and should not assume map search, a heavy faceted directory, partner self-service, or rich sparse-data experiences

Match presentation requirements:

- state whether matches are automated, human-reviewed, or both
- support no-results and weak-match fallback paths
- avoid implying live availability unless verified
- allow internal overrides and suppressions

### 5. Backend Lead Management Application

The backend application is an internal CRM and operations tool.

Core goals:

- track all submitted leads
- allow internal staff to create leads manually from calls, referrals, or offline inquiries
- allow staff to edit lead information at any time
- update lead status throughout the lifecycle
- manage matching, facility outreach, and scheduling
- record all communication, notes, and outcomes

The backend should support:

- lead list and lead detail views
- manual lead creation
- lead edit capability
- lead status updates
- lead assignment and ownership
- source and attribution tracking
- facility matching workflow
- facility outreach tracking
- appointment / tour tracking
- notes, tasks, reminders, and activity history

### 6. Facility Outreach And Scheduling Orchestration

Scheduling should be treated as a first-class workflow, because facilities will not respond in the same way or at the same speed.

The system should support:

- outreach to facilities by SMS, email, or phone workflow as appropriate
- per-facility preferred communication method
- tracking when a lead was shared with a facility
- tracking whether the facility responded
- tracking proposed times, confirmed times, declines, no response, and waitlists
- reschedule and cancellation handling
- human escalation when facilities do not respond promptly

Recommended operating model:

- automation handles confirmation and standard follow-ups where appropriate
- human staff fills the gaps when facilities are slow, inconsistent, or require manual coordination
- the system should record both automated and manual outreach in one timeline

### 7. Business Development And Facility Partnerships

The platform should include a provider-facing business development motion focused on facilities in the same launch markets served on the consumer side.

Business development goals:

- identify top facilities in each launch market
- reach out to facilities and introduce the family-matching service
- sign facilities up for paid listing packages
- upsell premium service add-ons
- track partner responsiveness, relationship health, and revenue

Phase 1 partner acquisition focus:

- prioritize the strongest and most relevant facilities in the Temecula, Murrieta, Menifee, Inland Valley, and surrounding service areas
- start with facilities that are most likely to benefit from family referrals and scheduling help
- focus on facilities that are operationally responsive and a good fit for concierge coordination

Facility partner value proposition:

- exposure to qualified local families looking for assisted living support
- placement into the vetted matching workflow
- help coordinating calls and tours
- stronger profile visibility in the consumer experience
- opportunity to purchase premium positioning and service support

## Revenue Model

The initial revenue strategy should combine recurring listing fees with optional premium add-ons.

### Core Paid Offering

Each participating facility should be offered a paid listing package.

Core listing package may include:

- presence in the partner facility network
- standard facility profile
- eligibility to receive matched family inquiries
- basic profile information displayed in the consumer experience
- standard reporting on lead and match activity

### Premium Add-Ons

Premium offerings may include:

- scheduling support for calls and visits
- priority listings in match results or directory placement
- more robust facility profiles
- expanded photos, amenities, and descriptive sections
- featured placement on market pages
- faster human follow-up support
- enhanced lead reporting
- responsiveness coaching or account management

### Commercial Principles

- pricing should be simple enough for early sales conversations
- the core package should be easy to explain and easy to buy
- premium add-ons should map to clear business outcomes such as visibility, speed, and coordination support
- premium placement should be disclosed clearly and should not undermine match quality or user trust
- partnership revenue rules should not create misleading claims about guaranteed placement or guaranteed move-ins

For specific pricing numbers, package tiers, optional add-ons, contract concepts, partner segmentation, and BD metrics, see `business_development.md`.

## Matching Logic

Leads should be matched to facilities based on:

- launch market / hospital service area
- geography
- care level
- memory care and mobility needs
- capacity
- licensing status
- budget when reliable pricing exists
- operational responsiveness over time

Initial matching can be rules-based.

Phase 1 matching should:

- prefer fields that are actually present and dependable
- allow manual overrides
- eventually incorporate facility responsiveness and partnership strength

Commercial safeguards:

- partner status may influence whether a facility is actively worked by the internal team
- premium listing status may influence visibility only within clearly defined and trust-preserving rules
- sponsored or prioritized placement should never override core safety, fit, or compliance constraints

## Functional Requirements

### Website

- public homepage
- market-specific landing pages for supported launch regions
- guided questionnaire flow
- educational and trust-building content
- confirmation page after submission
- public user signup, login, logout, and password reset
- logged-in-only facility search across the vetted facility subset, with a search and filter section above results
- logged-in-only facility profile pages for vetted records
- consent and preference capture
- provider / facility partnership information page

### Backend / Admin

- admin authentication
- admin-managed employee account creation with username and password
- staff-only access to the internal admin experience
- lead list view
- lead detail view
- manual lead creation
- lead edit capability
- lead status update capability
- lead contact data update capability
- lead intake/profile update capability
- source and campaign tracking
- facility list view
- lead-to-facility matching workflow
- facility outreach workflow
- appointment / tour workflow
- notes and activity tracking
- tasks, reminders, and follow-up queue
- search and filtering
- partner prospect list
- partner account detail view
- partner outreach and sales pipeline
- package and add-on tracking
- partner onboarding workflow
- billing-status tracking
- partner performance reporting

## Recommended Implementation Phases

### Phase 0: Discovery And Setup

- review SQLite schema and field quality
- define the exact Phase 1 facility subset
- define the exact city / ZIP / county coverage around each hospital anchor
- define public visibility rules for facility statuses
- define consent, privacy, and facility-sharing rules with counsel
- choose application stack
- define MVP data model
- define brand direction and landing page strategy
- define partner package structure, sales workflow, and billing approach

Primary roles for Phase 0:

- Product / Program Lead
- Compliance / Privacy Counsel
- Technical Architect
- Data / Matching Specialist
- Operations / Concierge Workflow Lead

### Phase 1: MVP Intake, Matching, And Concierge Ops

- market landing pages
- guided questionnaire
- attribution tracking
- automated confirmation flow
- lead dashboard
- matching workflow
- facility outreach workflow
- tour / appointment workflow
- core communications logging
- partner prospecting workflow
- partner onboarding workflow
- listing tier and add-on configuration

Primary roles for Phase 1:

- Technical Architect
- Developer
- QA / Test Lead
- Data / Matching Specialist
- Operations / Concierge Workflow Lead
- Business Development / Partner Success Lead
- Content / Marketing Operations

### Phase 2: Guided Facility Discovery And Portal

- identified-user shortlist and browsing
- facility detail pages
- richer match presentation
- customer status updates and timeline
- premium profile enhancements
- clearer featured / sponsored placement handling

### Phase 3: Optimization And Expansion

- improved scoring and responsiveness weighting
- reporting and funnel analytics
- deeper automation
- broader California market rollout
- partner performance reporting
- renewals and upsell workflows

### Phase 4: Multi-State Expansion

- state-aware routing and navigation
- national data ingestion
- geographic scaling strategy

Release gate for launch-critical work:

- Compliance / Privacy Counsel reviews launch-blocking consent, privacy, lead-sharing, and ad-tech items
- QA / Test Lead clears launch-blocking defects and regression risks
- Security / DevOps clears launch-blocking security, access, and deployment readiness items
