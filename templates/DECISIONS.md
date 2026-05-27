# Decisions — <PROJECT NAME>

> Lightweight ADR (Architecture Decision Record).
> One entry per non-obvious choice. The point is **why**, not what.
> Once you write one, don't edit it — write a new entry that supersedes if you change your mind.
>
> _Example entries lean on a Next.js + Supabase + tradespeople-quote-management context. Replace with your own decisions — the ADR shape (Context / Decision / Alternatives / Consequences) is domain-agnostic._

---

## Template

### YYYY-MM-DD — <short title>
**Status**: accepted | superseded by #<n> | reversed

**Context**: What problem are we solving? What constraints exist?

**Decision**: What did we choose?

**Alternatives considered**:
- Option A: why rejected
- Option B: why rejected

**Consequences**: What does this commit us to? What becomes harder?

---

## Examples (replace with real decisions)

### 2026-05-26 — Use server actions for mutations, API routes only for webhooks
**Status**: accepted

**Context**: Need a consistent pattern for "user submits form" vs "external service calls us." Mixing both styles for the same purpose creates inconsistent code.

**Decision**: All user-initiated mutations go through server actions (`'use server'`). API routes are only for webhooks (Stripe, etc.) and for endpoints called by non-browser clients (mobile, third-party).

**Alternatives considered**:
- All API routes (more traditional): rejected because server actions are simpler and progressively enhanced.
- Mixed by feature (whatever feels right): rejected because inconsistency = harder onboarding for future maintenance.

**Consequences**: Server actions are tied to React/Next.js. If we move off Next.js, the migration is non-trivial. Acceptable for v1.

---

### 2026-05-26 — Money stored as integer cents
**Status**: accepted

**Context**: Floating-point money rounding errors are a classic bug source. Decimal types are awkward across JS/Postgres/JSON.

**Decision**: All monetary amounts stored as `integer` cents in the DB. Conversion to display happens only at the UI layer (Intl.NumberFormat with `style: 'currency'`).

**Alternatives considered**:
- `numeric(10,2)` in Postgres: works but awkward in JS where it becomes a string.
- Floating point: rejected, well-known rounding issues.

**Consequences**: Every UI render of money needs the conversion. Worth it for correctness.

---

### 2026-05-26 — Phone-only signup for v1 (no email)
**Status**: accepted

**Context**: Target users (small-business contractors) have low email adoption. Most prefer WhatsApp/SMS.

**Decision**: V1 signup is phone + SMS verification only. Email is optional after signup.

**Alternatives considered**:
- Email-only: rejected, would lose ~30% of users at signup.
- Both upfront: rejected, friction.

**Consequences**: Need an SMS provider with coverage in the target market. Twilio chosen. ~$0.05 per signup. Costs scale linearly.

---

### YYYY-MM-DD — <next decision here>
