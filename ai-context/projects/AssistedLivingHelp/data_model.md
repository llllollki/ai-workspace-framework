# AssistedLivingHelp — Data Model

> Migrated from `AssistedLivingHelp\CLAUDE.md`. Source document retained unchanged.

## Data Sources

### Existing Data

- SQLite database containing California facility data in `facilities_ca.sqlite`

Expected usage:

- provide the initial California source dataset
- seed a vetted facility operating subset for the supported Phase 1 markets
- support search and listing pages where data quality is sufficient
- support facility-to-lead matching using dependable fields first
- provide records for later normalization and migration

Important current limitations observed in the SQLite file:

- the `facilities` table contains a broader mixed facility corpus, not a clean assisted living-only directory
- `ca_ccld_registry` currently provides the most dependable city, ZIP, phone, licensing, capacity, and status data
- canonical location fields are not yet consistently populated in `facilities`
- reviews and inspections content are not ready for product promises
- many consumer-facing enrichment fields in `facility_snapshots` are sparse or unpopulated

## Suggested Domain Model

### Lead

- id
- first_name
- last_name
- email
- phone
- preferred_contact_method
- sms_opt_in_status
- phone_call_opt_in_status
- email_opt_in_status
- relationship_to_resident
- launch_market
- hospital_anchor
- preferred_location
- budget_min
- budget_max
- care_level
- move_in_timeframe
- urgency
- notes
- status
- source
- campaign_id
- ad_set_id
- ad_id
- landing_page_variant
- assigned_to_user_id
- created_by_user_id
- last_contacted_at
- qualified_at
- created_at
- updated_at

### Resident Profile

- id
- lead_id
- age
- mobility_needs
- memory_care_needs
- medication_support_needs
- special_preferences
- diagnosis_summary

### Facility

- id
- source_id
- name
- address
- city
- state
- zip
- county
- phone
- website
- care_levels
- license_info
- description
- active
- source_status
- capacity
- source_record_type
- source_dataset
- public_visibility
- launch_market
- hospital_anchor
- preferred_contact_method
- response_speed_score
- partner_account_status
- listing_tier
- premium_add_ons
- billing_status
- account_owner_user_id

### Partner Account

- id
- facility_id
- primary_contact_name
- primary_contact_email
- primary_contact_phone
- billing_contact_name
- billing_contact_email
- billing_status
- account_status
- listing_tier
- premium_add_ons
- contract_signed_at
- renewal_date
- assigned_sales_user_id
- assigned_success_user_id
- notes
- created_at
- updated_at

### Sales Activity

- id
- partner_account_id
- user_id
- activity_type
- subject
- notes
- next_step
- due_at
- created_at

### Match

- id
- lead_id
- facility_id
- match_score
- match_reason
- generated_by
- human_reviewed
- status
- shared_with_lead_at
- shared_with_facility_at
- created_at

### Facility Outreach

- id
- lead_id
- facility_id
- outreach_channel
- outreach_status
- first_contact_at
- last_contact_at
- next_follow_up_at
- response_summary
- assigned_to_user_id
- created_at
- updated_at

### Appointment / Tour

- id
- lead_id
- facility_id
- appointment_type
- status
- proposed_at
- scheduled_for
- confirmed_at
- cancelled_at
- reschedule_reason
- created_at
- updated_at

### Consent Log

- id
- lead_id
- consent_type
- consent_text_version
- channel
- seller_scope
- granted_at
- revoked_at
- source_page
- ip_address
- user_agent

### Communication Event

- id
- lead_id
- facility_id
- appointment_id
- channel
- direction
- template_id
- delivery_status
- initiated_by
- body_summary
- created_at

### Activity / Note

- id
- lead_id
- facility_id
- user_id
- activity_type
- body
- created_at

### Internal User

- id
- username
- display_name
- role
- created_by_admin_user_id
- created_at
