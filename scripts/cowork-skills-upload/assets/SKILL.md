---
name: escalate-issue-to-line-manager
description: |
  Reports important information or incidents to your line manager via email or
  Teams. Use when user says: "report this to my manager", "escalate this",
  "escalate to [manager name]", "flag this to my boss", "notify my line manager",
  "tell my manager about [issue]", "urgent update for my manager", "let my
  manager know about [incident]". Handles three criticality levels — Notify,
  Important, Critical — and can optionally start a coordination Teams chat.

  Do NOT use for: general "who is my manager" lookups, scheduling meetings with
  your manager, replying to an existing thread from your manager, or writing
  broader updates aimed at leadership or the wider team (use stakeholder-comms
  for audience-targeted leadership/team updates).
cowork:
  category: communication
  icon: Megaphone
---

# Report Important Information to my Line Manager

Quickly notify your line manager of an issue, incident, or important update —
delivered as an email or Teams message, with an optional coordination chat.

## When NOT to Use

- General manager lookups ("who is my manager") — use people tools directly
- Scheduling a meeting with your manager — use schedule-meeting
- Replying inline to an existing thread from your manager — use Outlook reply directly
- Updates aimed at leadership broadly or the wider team — use stakeholder-comms

## Workflow

1. **Resolve the manager.** Call `GetManagerDetails` to get name and email. If
   no manager is configured, stop and tell the user.
2. **Gather context with one combined question.** Use `AskUserQuestion` to ask:
   - Channel: Email or Teams message
   - Criticality: Notify, Important, or Critical
   - Topic / what happened (free text — or reference an existing email/Teams message ID)
   - Anyone else to copy in (optional)
3. **If referencing existing content**, retrieve it first: `GetMessage` for an
   email, `GetChatMessage` for a Teams message. Quote the relevant excerpt in
   the body.
4. **Draft the message** using this template:

   - **Subject / headline:** `[CRITICAL] | [IMPORTANT] | [FYI] — <topic>`
     (only Critical and Important get a bracketed prefix; Notify uses plain subject)
   - **Body:**
     - *What happened* — one or two sentences
     - *Impact* — who/what is affected
     - *What I need from you* — explicit ask, or "for awareness, no action needed"
     - *Source* — link or quote of the underlying email/message if applicable

5. **Preview and confirm before sending.** Show the full drafted subject and
   body. Ask: "Send this now, or change anything?" Do NOT send Critical or
   Important messages without explicit confirmation. Notify-level may send
   directly if the user has already approved the draft.
6. **Send:**
   - Email mode: `SendEmailWithAttachments` to manager (CC any extra recipients).
   - Teams mode: `PostMessage` with `recipients=[manager email, ...extras]`.
7. **Optional coordination chat** — only for Important or Critical, and only
   if the user said yes in step 2: `CreateChat` (group if extras included)
   with topic = `<criticality> — <short topic>` (e.g. `Critical — Prod outage 02 May`).

## Guardrails

- Never send a Critical or Important message without showing the full draft and
  getting explicit confirmation.
- If the manager cannot be resolved, stop — do not guess or fall back to
  skip-level without asking.
- Do not create a coordination chat unless the user opted in.
- Keep the message concise — manager's time is the constraint.