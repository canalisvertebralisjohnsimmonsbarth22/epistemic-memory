# Observe — Passive Behavioral Evidence Collector

Automatically collects evidence about the user from how they work — not what they say about themselves, but what their choices reveal. Runs silently at conversation end alongside `/harvest`. Writes to an evidence log, not directly to the portrait.

**This skill is never invoked by the user.** It runs automatically as a step in your end-of-session harvest — the two are a single atomic operation. Can also be invoked standalone for manual catch-up. No output is shown unless the observation is worth surfacing (see Step 4).

## Trigger Condition

Runs at conversation end when the session was **substantive** (same gate as harvest) AND involved at least one of:

- The user made a **judgment call** where reasonable people would disagree
- The user **pushed back** on a suggestion, revealing a priority or value
- The user's **behavior contradicted** something in the existing profile
- The user **revealed something personal** unprompted (not in response to `/mirror interview`)
- The user's **process** (how they worked, what they skipped, what they lingered on) showed something not captured in the profile

If none of these occurred — a purely mechanical session — write nothing. The absence of signal is not signal.

## Instructions

### Step 1: Load Current Profile (silent)

Read these files to know what's already captured:

- `memory/user/` — all profile files (identity, drives, creative life, etc.)
- `memory/user/tensions.md`
- `memory/user/observations.md` (the evidence log — check for duplicates)

Paths are relative to your project's memory root.

### Step 2: Scan the Conversation (silent)

Review the full conversation. You're looking for **behavioral evidence**, not self-report. The distinction matters:

| Type | Example | What to record |
|------|---------|----------------|
| **Judgment under ambiguity** | Chose to foreground one approach over another despite the alternative having stronger surface-level support | "Prioritized X over Y when structuring an argument — reveals weighting of [value]" |
| **Pushback** | Rejected a suggestion to add more caveats | "Resists hedging when the data supports a claim — prefers confident statement + honest limitation section over distributed uncertainty" |
| **Process signal** | Spent 20 minutes on a sentence, moved on from a section in 30 seconds | "Allocates attention to [X], trusts instinct on [Y]" |
| **Contradiction** | Profile says X, but this session they did Y | Log as tension seed with both data points |
| **Unprompted reveal** | Mentioned something about family, past, feelings while working | Record the reveal and what it might connect to |

**Do NOT record:**
- Task outcomes (those go in harvest/git)
- Opinions about tools, libraries, APIs (ephemeral)
- Things already well-established in the profile (unless this session strengthens or complicates them)
- Anything that requires interpretive leaps beyond one step from the evidence

### Step 3: Write Observations

Append to `memory/user/observations.md`. Each observation is a dated entry with this structure:

```markdown
## YYYY-MM-DD — [short label]

**Evidence:** [What happened — the observable behavior, in 1-2 sentences]
**Suggests:** [What this might indicate about the person — one interpretive step only]
**Therefore:** [How this should change my behavior — one concrete directive for future sessions. What should I do, offer, avoid, or preempt based on this pattern?]
**Connects to:** [Existing belief name, if any, or "new" if this doesn't map to current profile]
**Strength:** [single | confirming | complicating | contradicting]
```

Strength meanings:
- **single** — first observation of this pattern. Low weight alone.
- **confirming** — consistent with an existing belief. Nudges confidence up.
- **complicating** — adds nuance to an existing belief without contradicting it.
- **contradicting** — conflicts with an existing belief. Should trigger a tension log entry.

The `Therefore` field converts observation into action. It should be specific enough to trigger a concrete behavioral change — not "be more attentive" but "when X happens, do Y." Prescriptives accumulate: when multiple observations converge on the same directive, that's a strong behavioral signal.

Write 0-3 observations per session. Zero is fine. Three is the ceiling — if you're seeing more, you're over-interpreting.

### Step 4: Surface or Stay Silent

**Default: stay silent.** Don't announce "I noticed 2 things about you today."

**Exception — surface when:**
- An observation **contradicts** an existing belief at conf ≥ 0.70. This is important enough to flag: "Something I noticed this session doesn't match what I thought I knew about you — I've logged it in the observation file. Worth discussing next time you run `/mirror`."
- That's it. One exception. Everything else accumulates silently.

### Step 5: Tension Escalation

If an observation has strength = **contradicting**:

1. Write the observation to `observations.md` as normal
2. Also add a dated entry to `memory/user/tensions.md` with status **watching**
3. Update the `challenged` date on the relevant belief in its profile file
4. Surface per Step 4 rules

## Synthesis (not this skill's job)

The observation log is **raw evidence**. It does not update portrait files directly. Evidence gets synthesized into the portrait during:

- `/mirror` — reads observations.md and weaves confirmed patterns into the portrait
- `/mirror audit` — flags observations that haven't been synthesized yet
- **Periodic review** (every 10 sessions) — batch synthesis pass

This separation is intentional. Observations are cheap, frequent, and low-commitment. Portrait updates are expensive, infrequent, and should require pattern confirmation across multiple observations.

## Delivery Mode

Observe runs at session end, scanning the full conversation (or its compressed summary) for observation-worthy behavior in a single pass. There is no live mid-conversation mode — the infrastructure to support ambient attention during task-focused work was evaluated and found unreliable.

## Design Principles

- **Behavior over self-report.** What someone does under pressure reveals more than what they say about themselves in reflection. Both matter, but this skill watches the doing.
- **One interpretive step.** "They chose X over Y" → "They value Z" is one step. "They chose X over Y" → "They value Z because of childhood experience W" is two steps. Stay at one.
- **Accumulate, don't conclude.** Three observations of the same pattern across different sessions = real signal. One observation = a note in a file. The synthesis pass decides what earns portrait status.
- **Absence is not evidence.** Not seeing a behavior doesn't mean it's not there. Don't log "they didn't do X."
- **Protect the relationship.** These observations serve the collaboration. If writing something down would feel like surveillance rather than attentiveness if the user read it, don't write it.
