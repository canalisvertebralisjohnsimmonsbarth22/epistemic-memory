#!/bin/bash
# Hook: Increment session counter on every session start
# Event: SessionStart (no matcher — runs on every session start)
# Maintains a JSON counter file for epistemic review cadence tracking
#
# Setup: Add this to your .claude/settings.json under "hooks":
#   "SessionStart": [{ "type": "command", "command": "bash .claude/hooks/session-counter.sh" }]

COUNTER_FILE="memory/user/session-counter.json"

if [ ! -f "$COUNTER_FILE" ]; then
  echo '{"count": 0, "last_session": null, "last_review": null, "next_review_at": 10}' > "$COUNTER_FILE"
fi

python3 -c "
import json, sys
from datetime import date

with open('$COUNTER_FILE', 'r') as f:
    data = json.load(f)

data['count'] = data.get('count', 0) + 1
data['last_session'] = str(date.today())
count = data['count']
next_review = data.get('next_review_at', 10)

with open('$COUNTER_FILE', 'w') as f:
    json.dump(data, f, indent=2)

if count >= next_review:
    print(f'Session {count} — PERIODIC REVIEW DUE (threshold: {next_review}). Run /mirror audit or /mirror gut-check.')
else:
    print(f'Session {count} (next review at {next_review})')
" 2>/dev/null

exit 0
