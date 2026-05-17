# alh-tracker — Terms of Service: Data Handling and Record Ownership Addendum

**Document type:** DRAFT — FOR COUNSEL REVIEW ONLY
**Prepared:** 2026-05-10
**Status:** Preliminary draft. Not approved policy. Not legal advice. Do not publish, use in any commercial agreement, or share with any facility operator until reviewed and approved by qualified California compliance/privacy counsel.

> **IMPORTANT NOTICE:** This draft was prepared by the Product / Program Lead with AI-assisted desk research as a structured starting point for counsel engagement. It is not a legal document and does not constitute legal advice. Every provision below is preliminary and must be reviewed by qualified California compliance/privacy counsel before it is used in any commercial or operational context. Provisions marked [PENDING COUNSEL] contain open questions that must be answered before the provision can be finalized.

---

## Purpose of This Addendum

This addendum to the alh-tracker Terms of Service governs the data handling relationship between the software vendor (alh-tracker, operated by [Company Name]) and the facility operator (Customer) with respect to resident care data stored in the product.

This addendum exists because resident care records created in alh-tracker may have legal significance under California Title 22, HIPAA, and California privacy law. The parties' respective obligations regarding these records must be established before any real resident care data is stored under a commercial relationship.

---

## Section 1 — Vendor Role and Data Processing Relationship

**1.1 Service provider / data processor.** For purposes of this Agreement, [Company Name] acts as a **service provider** and **data processor** with respect to resident care data stored in alh-tracker. The Customer (facility operator) is the data controller and retains ultimate responsibility for the data and for any regulatory obligations applicable to that data under California or federal law.

**1.2 Limited use.** [Company Name] processes resident care data solely for the purpose of providing the alh-tracker service to the Customer. Resident care data is not used for:
- Advertising or marketing to any third party
- Training machine learning models without separate written consent
- Transfer to the AssistedLivingHelp platform or any other product operated by [Company Name] without explicit named operator consent

**1.3 No pooling or aggregation of identified resident data.** Resident care data is associated with the specific Customer facility account and is not pooled, aggregated, or shared across facility accounts in any identified form without explicit written consent from all relevant Customer accounts.

> [PENDING COUNSEL]: Confirm whether this service provider / data processor framing is the correct characterization under CPPA/CCPA and HIPAA for a vendor processing health-related records for RCFE operators.

---

## Section 2 — Record Ownership

**2.1 Customer owns the data.** All resident care data, care log entries, handoff summaries, shift records, and audit trail records created in alh-tracker are the property of the Customer (facility operator). [Company Name] does not claim ownership of any resident care records.

**2.2 Resident data is not [Company Name]'s product.** The product [Company Name] provides is the software service (the shift log and handoff tool). Resident care data that Customers create using that service belongs to the Customer.

**2.3 Caregiver-authored records.** Care log entries are authored by facility caregivers on behalf of the facility operator. The facility operator is responsible for the accuracy, completeness, and regulatory compliance of care log entries. [Company Name] is not responsible for the content of care log entries.

> [PENDING COUNSEL — Q1]: Counsel must confirm the record ownership framework is consistent with Title 22 § 87506 requirements regarding resident records. Specifically: if CareLogEntry records constitute § 87506 resident records, does the facility operator's ownership of those records create any obligations on the vendor regarding how those records are held, transferred, or returned?

---

## Section 3 — Data Retention

**3.1 Retention during active service.** While the Customer's account is active, [Company Name] retains all resident care data, shift records, care log entries, and audit trail records in the production database.

**3.2 Minimum retention period — [PENDING COUNSEL].** The minimum retention period for care log records is not yet defined as policy. Preliminary desk research identifies the following potentially applicable regulatory retention periods under California Title 22:
- § 87506 (resident records): 3 years post-service, if care log entries constitute resident records.
- § 87465 (medication records): 1 year, if observed care task records constitute medication records.

The vendor's obligations with respect to these retention periods have not been confirmed by counsel. **This provision will be completed after counsel answers Priority 1 Questions 1 and 2 in the counsel handoff packet (0004-counsel-handoff-packet.md).**

**3.3 Retention category — placeholder.**
- [Placeholder: CareLogEntry retention period — to be completed after Q1 answer]
- [Placeholder: ObservedCareTask retention period — to be completed after Q2 answer]
- [Placeholder: AuditTrail retention period — to be determined]
- [Placeholder: Shift records retention period — to be determined]

**3.4 No obligation to retain beyond statutory minimum.** Subject to counsel confirmation, [Company Name] is not obligated to retain resident care records beyond the statutory minimum applicable to the vendor. Customers are independently responsible for maintaining any records they are required to retain under applicable law.

> [PENDING COUNSEL — Q1, Q2]: Retention periods and the vendor's retention obligations are the primary open question in this addendum. Do not finalize this section before receiving written counsel answers to Q1 (§ 87506 resident records) and Q2 (§ 87465 medication-adjacent observations) in the counsel handoff packet.

---

## Section 4 — Account Closure and Record Disposition

**4.1 Account closure events.** This section governs what happens to resident care data when a Customer account is closed. Account closure includes: voluntary cancellation by the Customer, non-payment termination, facility closure, and operator transfer.

**4.2 Pre-closure data export.** Before account closure takes effect, [Company Name] will provide the Customer with the ability to export all resident care data in a standard machine-readable format (CSV or equivalent). Export must be initiated by the Customer prior to account termination. The Customer is responsible for downloading and retaining their exported data.

**4.3 Notice before deletion.** [Company Name] will provide the Customer with at least [30 days — confirm with counsel] written notice before any resident care data is permanently deleted following account closure, except in cases of non-payment termination where a shorter period may apply.

**4.4 Data deletion following account closure.** Following account closure and the applicable retention period:
- Active resident care data, care log entries, and shift records will be [retained for X period — PENDING COUNSEL] and then permanently deleted.
- Audit trail records will be [retained for X period — PENDING COUNSEL] and then permanently deleted.
- User account data (caregiver names, emails) will be [anonymized / deleted — PENDING COUNSEL].

**4.5 Data return.** [Company Name] does not provide physical media or printed copies of resident care records. Data return to the Customer is accomplished through the export mechanism described in Section 4.2.

**4.6 Residual data.** Following data deletion, [Company Name] may retain aggregate, de-identified, or anonymized data that does not identify any specific resident or facility.

> [PENDING COUNSEL — Q4]: The account closure behavior (retention period after closure, deletion timeline, notice requirements, and export obligations) is an open Priority 1 question. Do not finalize this section before receiving written counsel answers to Q4 in the counsel handoff packet. The disposition of AuditTrail records after account closure is particularly important — the AuditTrail may be the only record of who authored which care observation.

> [PENDING COUNSEL — Q6]: Counsel must confirm whether caregiver User identity records must be preserved in AuditTrail references after a caregiver's employment ends and their account is deactivated. If yes, the anonymization approach in Section 4.4 must be revised.

---

## Section 5 — Data Export, Return, and Deletion Rights

**5.1 Customer right to export.** At any time during active service, the Customer may export their facility's resident care data from the product. [Company Name] will provide a self-service export function for this purpose.

**5.2 Customer right to request deletion.** The Customer may request deletion of their facility's resident care data. [Company Name] will fulfill such requests subject to:
- Any applicable statutory retention obligations (see Section 3) that may prevent immediate deletion.
- The retention period after account closure defined in Section 4.4.

> [PENDING COUNSEL — Q1, Q4]: If resident care data constitutes § 87506 resident records subject to a 3-year post-service retention period, and if that retention period applies to the vendor, then the Customer's right to request deletion before that period expires may be constrained. Counsel must confirm whether the vendor must retain records over the Customer's objection in this scenario.

**5.3 Deletion on request.** For data not subject to a statutory retention obligation, [Company Name] will permanently delete Customer data within [30 days — confirm with counsel] of a written deletion request.

**5.4 Deletion confirmation.** Upon completing a deletion request, [Company Name] will provide written confirmation to the Customer that the deletion has been completed.

---

## Section 6 — HIPAA Business Associate Agreement Posture

**6.1 Status — unresolved.** As of the effective date of this Agreement, [Company Name]'s HIPAA Business Associate Agreement (BAA) posture has not been determined. Whether alh-tracker stores Protected Health Information (PHI) under HIPAA, and whether RCFE operators who use alh-tracker qualify as HIPAA Covered Entities or Business Associates, is an open question requiring counsel review.

**6.2 No BAA provided at this time.** [Company Name] does not provide a HIPAA BAA to Customers as part of the standard Terms of Service. Customers who believe they require a BAA must notify [Company Name] before storing any resident care data in the product.

**6.3 Obligation to notify.** If the Customer believes that their RCFE operates as a HIPAA Covered Entity or that their residents are Medicare or Medicaid beneficiaries whose data may constitute PHI, the Customer is responsible for notifying [Company Name] before using the product with that data.

> [PENDING COUNSEL — Q2(c), Q7]: Whether a HIPAA BAA is required for RCFE facilities whose residents may be Medicare or Medicaid beneficiaries is an open Priority 1 question. This section must not be treated as a final BAA posture. Counsel must determine: (a) whether alh-tracker's storage of medication-adjacent observations creates a BAA requirement even without dosage data, and (b) whether the Terms of Service needs a data processing agreement or BAA template at minimum for California RCFE operators.

**6.4 Interim posture.** Until counsel resolves the HIPAA BAA question, [Company Name] will:
- Not store any PHI that the Customer identifies as requiring a BAA.
- Not represent to any Customer that use of alh-tracker satisfies their HIPAA obligations.
- Not represent to any Customer that [Company Name] is a HIPAA Business Associate or Covered Entity.

---

## Section 7 — No Compliance Certification

**7.1 No regulatory compliance representation.** alh-tracker is a care observation and shift log tool. Use of alh-tracker does not satisfy, certify, or substitute for:
- Any documentation requirement under California Title 22, Division 6, Chapter 8 (RCFE regulations).
- Any incident reporting obligation under § 87211.
- Any medication administration documentation requirement under § 87465.
- Any resident records requirement under § 87506.
- Any personnel records requirement under § 87411.
- Any HIPAA compliance obligation.

**7.2 Customer remains responsible.** The Customer remains solely responsible for compliance with all applicable federal, state, and local laws and regulations governing the operation of a licensed RCFE, including documentation, reporting, retention, and disclosure obligations.

**7.3 No compliance claims permitted.** [Company Name] will not make any representation in marketing copy, product UI, customer communications, or this Agreement that use of alh-tracker satisfies any Title 22 or HIPAA requirement. Customers may not represent to CDSS or any regulatory authority that their use of alh-tracker constitutes compliance with any regulatory requirement.

---

## Section 8 — Data Security and Breach Notification

**8.1 Security obligations.** [Company Name] will implement and maintain reasonable administrative, technical, and physical safeguards to protect resident care data against unauthorized access, disclosure, or destruction.

**8.2 Breach notification.** In the event of a confirmed data breach affecting resident care data, [Company Name] will notify the Customer within [72 hours — confirm with counsel] of confirming the breach. Notification will include: a description of the data involved, the approximate timeframe of the breach, and steps taken to contain and remediate the breach.

**8.3 Customer notification obligations.** The Customer is responsible for determining and fulfilling any notification obligations to residents, family contacts, regulatory authorities, or other parties that may arise from a data breach, including any obligations under California law or HIPAA.

---

## Section 10 — Security Controls, Access, and Data Handling Standards

> **PLACEHOLDER — FOR COUNSEL REVIEW**
> This section identifies security and privacy controls the vendor intends to implement before commercial launch. It does not represent current capabilities of the prototype. Each subsection contains open questions for counsel. Do not treat any statement below as a security certification or compliance claim.

**10.1 Authentication and access control.** [Company Name] will require authenticated, named user accounts for all access to resident care data. Authentication will use secure credential handling (no plaintext passwords). Role-based access control will be enforced server-side; each user's access will be limited to the data of the specific facility for which they are authorized.

**10.2 Audit logging.** [Company Name] will maintain an append-only audit log of all create and edit operations on resident care records. The audit log will be stored in a database with write-once constraints. Audit log records will not be deleted before the expiration of the applicable record retention period.

**10.3 Encryption.** Resident care data will be encrypted in transit (HTTPS/TLS 1.2+) and at rest (database-level encryption). Encryption in transit is enforced for all production traffic.

**10.4 Backups.** [Company Name] will maintain automated backups of the production database with point-in-time recovery capability. Backup retention will be at least as long as the counsel-confirmed minimum retention period for the relevant record categories.

**10.5 Data export.** The Customer may export all resident care data from the product at any time during active service. Export is available to facility owner and admin roles only. Export events are logged in the audit trail. Export format: CSV or equivalent machine-readable format.

**10.6 User deactivation.** When a Customer deactivates a user account (e.g., a caregiver leaves employment), [Company Name] will immediately revoke all active sessions for that account. The user's identity record will be preserved in the audit trail for the duration of the applicable retention period.

**10.7 Breach notification timeline.** [Company Name] will notify the Customer within 72 hours of confirming a data breach affecting resident care data. [PENDING COUNSEL — see Section 8.2 and open question below regarding California breach notification requirements.]

> [PENDING COUNSEL — Security Controls]:
> - **Q-S1**: What specific administrative, physical, and technical safeguards must the vendor implement before storing data for HIPAA Covered Entity RCFE operators? (HIPAA Security Rule, 45 CFR Part 164 Subpart C — relevant if BAA is required.)
> - **Q-S2**: Does California law (CCPA/CPPA data security obligations) impose any specific security standards on a vendor of this type independent of HIPAA?
> - **Q-S3**: Must the vendor implement SOC 2 Type II or any other security certification before facility operators at this scale will contract? Is this a deal-blocker at the design partner stage?
> - **Q-S4**: What is the required breach notification timeline under California law for a breach affecting resident care data? Is 72 hours sufficient, or does CCPA/CPPA require a shorter window?
> - **Q-S5**: When a caregiver account is deactivated, must the identity record be preserved in the audit trail indefinitely, or may it be anonymized after the counsel-confirmed retention period expires?
> - **Q-S6**: Does the vendor's obligation to maintain an append-only audit log (Section 10.2) constitute a representation that the audit log satisfies any specific California Title 22 record-keeping requirement? (It must not — see Section 7.)

---

## Section 9 — Changes to This Addendum

[Company Name] may update this Data Handling Addendum with reasonable notice to Customers. Material changes affecting data retention, ownership, export rights, or HIPAA posture will be communicated to Customers at least [30 days — confirm with counsel] before taking effect. Continued use of the service after that period constitutes acceptance of the updated terms.

---

## Open Issues Requiring Counsel Input Before Finalization

| Section | Open question | Counsel question reference |
|---|---|---|
| 1.1 | Is "service provider / data processor" the correct characterization under CPPA/CCPA and HIPAA? | Q7 |
| 2.1 | Does Customer ownership of resident data create vendor obligations regarding how records are held or transferred? | Q1 |
| 3.2–3.3 | What retention periods apply to the vendor for CareLogEntry, ObservedCareTask, and AuditTrail records? | Q1, Q2 |
| 4.3–4.4 | What is the required notice period and retention period after account closure before deletion is permitted? | Q4 |
| 4.4 | Must caregiver User identity be preserved in AuditTrail after deactivation, or may it be anonymized? | Q6 |
| 5.2 | Can the Customer request deletion before the statutory retention period expires? | Q1, Q4 |
| 6.1–6.4 | Is a HIPAA BAA required? Does storing medication-adjacent observations without dosage trigger BAA requirement? | Q2(c), Q7 |
| 8.2 | What breach notification timeline is required under California law? | Q7 / Q-S4 |
| 10.1 | Does role-based access control satisfy any specific HIPAA Security Rule technical safeguard? | Q-S1 |
| 10.2 | Does the append-only audit log constitute a representation of regulatory compliance? Must it not. | Q-S6 |
| 10.3–10.4 | Do HIPAA Security Rule or California law impose specific encryption or backup standards? | Q-S1, Q-S2 |
| 10.6 | Must caregiver identity be preserved in audit trail after deactivation, or may it be anonymized? | Q-S5 |
| 10 (general) | Is SOC 2 Type II or other certification required or expected by RCFE operators at this scale? | Q-S3 |

---

**Do not use this document for any commercial, operational, or communications purpose until counsel has reviewed and confirmed or revised each section. This draft is a structured starting point for counsel engagement, not an approved Terms of Service or data handling policy.**
