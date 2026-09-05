---
name: linkedin-profile-editor
description: Use this whenever the user asks to edit, update, change, or fix anything on their LinkedIn profile (headline, About/summary, experience entries, education, skills, etc.) via a Playwright-controlled browser. Also use this if the user asks to "update my LinkedIn" or pastes new bio/headline text and wants it reflected on their profile, even if they don't mention Playwright by name. LinkedIn has no undo for profile edits, so this skill enforces confirming the exact field and new value with the user before ever submitting a change, reading the actual page before acting instead of guessing selectors, and verifying the change landed afterward.
---

# LinkedIn Profile Editor

LinkedIn profile edits are live and irreversible — there's no version history, no undo button. A wrong click updates a real profile that other people see. This skill exists to slow down at exactly the right moment (before submission) and move fast everywhere else.

The core loop is: **log in → find the real field → confirm with the user → submit → verify it landed → report before/after.** Never skip or reorder these steps.

## 1. Check login state

Navigate to `https://www.linkedin.com/in/me/` (or the user's profile URL if given) and take a snapshot. If you land on a login/checkpoint/captcha page instead of a profile, LinkedIn needs the user to authenticate themselves — 2FA and captcha challenges can't be solved by the browser tool.

Tell the user you've hit a login wall and ask them to complete login (and any 2FA/captcha) manually in the browser window, then let you know when they're through. Don't attempt to fill in credentials yourself, even if the user pastes them into the chat — treat the login boundary as theirs to cross.

## 2. Find the real field — don't guess selectors

LinkedIn's DOM is dense, dynamic, and versioned differently across accounts. Before clicking anything, take a snapshot or read the accessibility tree of the profile page to locate the actual edit affordance for the field the user mentioned (usually a pencil/edit icon near that section). Click into it and take another snapshot of the modal that opens — the field layout inside edit modals (e.g., Experience has separate title/company/date fields; About is a single textarea) varies enough that you should read it rather than assume.

Common sections and where their edit controls usually live:
- **Headline**: pencil icon on the intro card at the top of the profile (opens "Edit intro" modal — headline is one field among several, don't touch the others).
- **About**: pencil icon on the About section (single textarea).
- **Experience**: pencil icon on a specific entry opens that entry's modal with multiple fields — confirm which one the user means before editing.
- **Education**: same pattern as Experience, per-entry.

If the section the user wants isn't listed above, apply the same method: locate the section, find its edit control, open it, and read what's actually inside before touching it.

## 3. Confirm before you touch anything

This is the step that must never be skipped, rushed, or inferred. Before filling in or submitting anything:

1. Read the field's **current value** directly from the opened modal (not from memory or a guess).
2. State clearly to the user: the field name, its current value, and the exact new value you're about to set.
3. Wait for an explicit yes/confirm. If the user's original request was ambiguous about wording (e.g., they said "make my headline more senior" rather than giving exact text), propose specific final text and get that confirmed too — don't submit anything the user hasn't seen verbatim.

If the user asks you to change multiple fields in one request, confirm each one individually before submitting it, rather than batching a single "confirm all of this" at the end — it's easy for a batched confirmation to hide a field the user didn't actually mean to change.

## 4. Fill and submit

Only after explicit confirmation, fill the field with the exact confirmed value and submit/save the modal. Take a snapshot right after submitting to catch any validation error or unexpected state before assuming success.

## 5. Verify the change landed

Navigate back to (or reload) the profile page and re-read the field from the live page — not from the modal you just closed, since a modal can appear to save without the underlying page actually updating. This is the only way to be sure the edit actually persisted.

## 6. Report before/after

Give the user a short, clear summary:

```
Field: <field name>
Before: <old value>
After: <new value>
Status: confirmed live on profile
```

If verification in step 5 shows the change didn't take (old value still showing, or a different value than expected), say so plainly and don't report success — investigate or ask the user how to proceed rather than assuming it's fine.
