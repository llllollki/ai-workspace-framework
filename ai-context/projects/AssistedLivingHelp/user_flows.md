# AssistedLivingHelp — User Flows and Status Models

> Migrated from `AssistedLivingHelp\CLAUDE.md`. Source document retained unchanged.

## Required User Flows

### Lead / Consumer Flow

1. Visitor lands on a market-specific page from ads, search, referral, or direct traffic
2. Visitor sees a clear service promise and begins the guided questionnaire
3. Visitor submits lead details and communication permissions
4. System creates or updates the lead
5. Visitor receives immediate confirmation on-screen, and by email/SMS where permitted
6. System generates initial matches or queues the lead for internal review
7. Team and automation coordinate outreach to one or more facilities
8. Visitor receives updates as scheduling progresses
9. Visitor reviews suggested facilities and scheduled options

### Internal Team Flow

1. New lead appears in backend application
2. Team can also create a lead manually from a phone call, referral, or offline inquiry
3. Team reviews and updates lead profile, attribution, and contact data
4. Team reviews the system-generated matches
5. Team approves, edits, or overrides the facility shortlist
6. Team shares the lead with appropriate facilities
7. System and staff track facility responses and scheduling progress
8. Team communicates updates to the family
9. Team continues editing lead details as new information is learned

### Business Development / Partner Flow

1. Team identifies target facilities in the launch market
2. Team reaches out to facility decision-makers
3. Team tracks outreach, meetings, and follow-ups
4. Facility chooses a listing package and any premium add-ons
5. Team onboards the facility and publishes or upgrades the profile
6. Facility begins receiving or being prioritized for relevant lead opportunities based on package rules and matching rules
7. Team reviews partner performance, renewals, and upsell opportunities

## Suggested Workflow Status Models

One status is not enough. The platform should maintain separate status models.

### Lead Status

- new
- intake_in_progress
- qualified
- unqualified
- assigned
- matching_in_progress
- matched
- closed_won
- closed_lost

### Facility Outreach Status

- not_contacted
- queued
- contacted
- follow_up_needed
- responded
- declined
- no_response
- waitlisted

### Partner Account Status

- prospect
- contacted
- interested
- meeting_scheduled
- proposal_sent
- negotiating
- won
- active
- at_risk
- churned

### Appointment / Tour Status

- not_started
- requested
- options_received
- proposed_to_family
- confirmed
- reschedule_requested
- cancelled
- completed
- no_show
