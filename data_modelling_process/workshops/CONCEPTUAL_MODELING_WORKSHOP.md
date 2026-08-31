# CONCEPTUAL_MODELING_WORKSHOP.md — 90-Min Cross-Functional Workshop Facilitation Guide

> **Goal:** Resolve a gently ambiguous business concept (e.g., "What is a *subscription*?") and produce a **shared conceptual model** with assigned owners for logical/physical design.  
> **Participants:** 6–10 people (Business SMEs, BAs, Data Engineer, Data Modeller, Product Owner)  
> **Frequency:** Monthly or per strategic initiative

---

## Pre-Workshop (Async, 1 Week Before)

| Task | Owner | Done? |
|------|-------|-------|
| Select topic (one concept, cross-domain) | Data Modeller | ☐ |
| Invite: 2 SMEs per domain, 1 BA, 1 DE, 1 PO | Data Modeller | ☐ |
| Distribute: Current definitions (glossary, docs, ERDs) | Data Modeller | ☐ |
| Prepare: Miro/whiteboard template (see below) | Data Modeller | ☐ |
| Collect: "What breaks today?" from each invitee | BA | ☐ |

**Topic Selection Criteria:**
- Spans ≥ 2 domains (e.g., Billing + Product + Support)
- Causing rework / incidents / reconciliation pain
- No single owner today
- Strategic value (revenue, compliance, customer experience)

**Example Topics:**
- "Subscription" (Product defines features, Billing defines pricing, Support defines entitlements)
- "Customer" (CRM = account holder, Billing = payer, Product = user, Marketing = lead)
- "Product" (Catalog = sellable, Inventory = stockable, Finance = revenue-recognisable)
- "Location" (Shipping = address, Tax = jurisdiction, Network = node, Regulatory = region)

---

## Workshop Agenda (90 Minutes)

| Time | Activity | Method | Output |
|------|----------|--------|--------|
| 0:00–0:10 | **Context & Ground Rules** | Facilitator presents | Shared understanding |
| 0:10–0:25 | **Event Storming** | Silent sticky notes → group | Business process timeline |
| 0:25–0:40 | **Concept Extraction** | Affinity mapping → naming | Candidate entities |
| 0:40–0:55 | **Grain & Key Definition** | Per entity: "One row = ?" + "Business key = ?" | Grain + Key cards |
| 0:55–1:10 | **Relationship Mapping** | Draw lines + cardinality | Conceptual ERD |
| 1:10–1:20 | **Conflict Resolution** | Dot voting on disputes | Decisions recorded |
| 1:20–1:30 | **Owners & Next Steps** | Assign logical/physical owners | Action items |

---

## Detailed Facilitation Guide

### 1. Context & Ground Rules (10 min)

**Say:**
> "We're here to define **[Concept]** once, together. No 'right' answer — only shared understanding. Output = conceptual model + owners. Not a physical design yet."

**Ground Rules:**
- One conversation at a time
- Business language > technical jargon
- "I think" → "The business rule is..."
- Parking lot for out-of-scope items
- Decisions by consent (no strong objection), not consensus

**Show:** Current state pain points (collected async) — 1 slide.

---

### 2. Event Storming (15 min)

**Materials:** Virtual sticky notes (Miro/Mural) or physical wall + Sharpies.

**Steps:**
1. **Silent brainstorm (5 min):** "Write every *event* that happens in the lifecycle of [Concept]. One per sticky. Verb + Noun. e.g., 'Subscription Created', 'Payment Failed', 'Trial Converted'."
2. **Timeline (5 min):** Group sticks on horizontal timeline. Cluster duplicates. Order chronologically.
3. **Identify actors (3 min):** Add coloured stickies for *who* triggers each event (Customer, System, Billing, Support).
4. **Spot pain (2 min):** Red dot on events where "things break today."

**Facilitator Tip:** If > 30 events, timebox clustering. Focus on *business* events, not technical logs.

---

### 3. Concept Extraction (15 min)

**Materials:** Same board, new column/section.

**Steps:**
1. **Affinity map (5 min):** From events, extract *nouns* that persist (not events). Group similar. e.g., "Subscription", "Plan", "Customer", "Payment Method", "Entitlement".
2. **Name & Define (7 min):** For each cluster:
   - Agree on **singular name** (e.g., `Subscription`, not `Subscriptions`)
   - Write **one-sentence business definition**
   - Identify **lifecycle states** (Created → Active → Paused → Cancelled → Expired)
3. **Filter (3 min):** Keep only concepts that:
   - Have independent identity
   - Have attributes beyond the event
   - Are referenced by other concepts

**Output:** 5–8 **Concept Cards** (name + definition + states).

---

### 4. Grain & Key Definition (15 min)

**For EACH Concept Card:**

| Question | Capture On Card |
|----------|-----------------|
| **Grain:** "One row represents..." | `One row per Subscription per billing period` |
| **Business Key:** What does the business call it? | `subscription_id` (from Billing) + `plan_code` (from Product) |
| **Does the key change?** | `subscription_id` immutable; `plan_code` changes on upgrade |
| **History needed?** | Yes — state changes, price changes, pauses |
| **Authoritative Source?** | Billing (for id, dates, amount); Product (for plan features) |

**Facilitator Tip:** Use a **Grain Template** on the board:
```
ENTITY: _______________
GRAIN: One row per _______________
BUSINESS KEY: _______________
KEY CHANGES? Y/N → If Y: SCD2 / Vault new record
HISTORY: None / State / Full / Audit
SOURCE: _______________
```

---

### 5. Relationship Mapping (15 min)

**Draw on board (or Miro ERD):**

1. Place Concept Cards as boxes
2. Draw lines for **relationships** (not FKs — business relationships)
3. Label each line:
   - **Verb phrase**: "Subscription **has** Plan"
   - **Cardinality**: 1:1, 1:M, M:N
   - **Optionality**: Mandatory / Optional
4. Resolve M:N → **Bridge Concept** (e.g., `Subscription_Entitlement`)

**Example Output:**
```
Customer (1) ───< places >─── (M) Subscription
Subscription (M) ───< has >─── (1) Plan
Subscription (1) ───< uses >─── (M) Payment_Method
Subscription (M) ───< grants >─── (M) Entitlement  → BRIDGE: Subscription_Entitlement
```

**Check:** Every relationship makes sense *in business language*.

---

### 6. Conflict Resolution (10 min)

**Common Disputes & Resolution:**

| Dispute | Technique |
|---------|-----------|
| "Is a Trial a Subscription?" | Dot vote: 3 options — Yes / No / Separate Entity. Majority wins; minority documents concern. |
| "Who owns the Customer definition?" | Map responsibilities: CRM=identity, Billing=payment, Product=entitlement. Assign *steward* per attribute. |
| "Plan is just a reference table" | Test: Does it have lifecycle? Attributes beyond code? If yes → Entity. If no → Reference. |

**Record:** Decision + rationale + dissenting view in **Workshop Decisions Log**.

---

### 7. Owners & Next Steps (10 min)

| Concept | Logical Owner | Physical Owner | Target Date | Notes |
|---------|---------------|----------------|-------------|-------|
| Subscription | BA (Billing) | Data Modeller | W+2 | |
| Plan | BA (Product) | Data Engineer | W+2 | Reference or Entity? |
| Entitlement | BA (Product) | Data Modeller | W+3 | New bridge needed |
| ... | | | | |

**Commitments:**
- Logical model draft → 1 week
- Physical model + ADR → 2 weeks
- Review session → 3 weeks

**Close:** Photo of board → transcribe to Confluence/Git → share with all invitees + stakeholders.

---

## Miro / Whiteboard Template

```
┌─────────────────────────────────────────────────────────────────────┐
│ EVENT STORMING TIMELINE                                              │
│ [Subscription Created] → [Trial Started] → [Payment Collected] →    │
│ [Subscription Activated] → [Plan Changed] → [Subscription Paused] → │
│ [Subscription Cancelled] → [Subscription Expired]                   │
│                                                                     │
│ ACTORS:  🟦 Customer   🟩 System   🟨 Billing   🟧 Support          │
│ PAIN:    🔴 [Payment Failed]  🔴 [Trial Conversion Mismatch]        │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ CONCEPT:     │  │ CONCEPT:     │  │ CONCEPT:     │  │ CONCEPT:     │
│ Subscription │  │ Plan         │  │ Customer     │  │ Entitlement  │
│ ──────────── │  │ ──────────── │  │ ──────────── │  │ ─────────── │
│ Def: ...     │  │ Def: ...     │  │ Def: ...     │  │ Def: ...    │
│ States: ...  │  │ States: ...  │  │ States: ...  │  │ States: ... │
│ Grain: ...   │  │ Grain: ...   │  │ Grain: ...   │  │ Grain: ...  │
│ BK: ...      │  │ BK: ...      │  │ BK: ...      │  │ BK: ...     │
│ History: Y   │  │ History: N   │  │ History: Y   │  │ History: Y  │
│ Source: Bill │  │ Source: Prod │  │ Source: CRM  │  │ Source: Prd │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ CONCEPTUAL ERD                                                       │
│                                                                     │
│  Customer ──────< places >────── Subscription                       │
│       │                                    │                        │
│       │                                    │                        │
│       │                              < has >                        │
│       │                                    │                        │
│       │                              < uses >                       │
│       │                                    │                        │
│       │                              < grants >                     │
│       │                                    ▼                        │
│       │                        Subscription_Entitlement             │
│       │                                    │                        │
│       │                              < grants >                     │
│       │                                    │                        │
│       ▼                                    ▼                        │
│  Payment_Method                      Entitlement                    │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ DECISIONS LOG                                                        │
│ ☐ Trial = separate entity (Subscription_Trial) — 6/8 votes          │
│ ☐ Plan = reference table (no lifecycle) — 7/8 votes                 │
│ ☐ Entitlement bridge required — unanimous                           │
│ ☐ Customer steward = Jane (CRM) for identity; John (Billing) for $  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Post-Workshop Deliverables (Within 24 Hours)

| Artefact | Location | Owner |
|----------|----------|-------|
| Workshop Notes (this template filled) | Confluence / Git `workshops/YYYY-MM-DD_<topic>/` | Facilitator |
| Conceptual ERD (Mermaid `.mmd` + PNG) | `workshops/.../conceptual_erd.mmd` | Data Modeller |
| Concept Cards (markdown table) | `workshops/.../concept_cards.md` | BA |
| Decisions Log | `workshops/.../decisions.md` | Facilitator |
| Action Items (with owners/dates) | Jira/Linear epic + tickets | Data Modeller |
| Recording (if virtual) | Team drive | Facilitator |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Symptom | Prevention |
|--------------|---------|------------|
| **Solutioning too early** | "We need a bridge table here" in Event Storming | Ban technical terms until Relationship Mapping |
| **Domain dominance** | One SME defines everything | Facilitator enforces round-robin; dot voting |
| **Scope creep** | "Let's also fix Customer while we're here" | Parking lot visible; timebox each section |
| **No decision** | "Let's take it offline" on every conflict | Consent-based: "Any strong objection? No → decided." |
| **No follow-through** | Workshop happens, nothing ships | Action items in sprint tracker; review session booked |

---

## Facilitator Cheat Sheet (Print This)

```
TIMEBOXES:  10 / 15 / 15 / 15 / 15 / 10 / 10 = 90 min
PHRASES:
  "What does the business call this?"
  "One row represents...?"
  "What uniquely identifies it?"
  "Can it exist without the other?"
  "Does the key change? What happens then?"
  "Who owns this definition?"
  "Any strong objection? [Silence = consent]"
PARKING LOT: Visible, revisit at end if time
DECISION LOG: Every dispute → decision + rationale + dissent
ACTION ITEMS: Owner + Date + Deliverable (no "discuss further")
```