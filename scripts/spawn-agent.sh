#!/usr/bin/env bash
# ============================================================================
# spawn-agent.sh - Create a New Actor Agent
# ============================================================================
# Dynamically creates an agent with prompt file and mailbox.
# Called by the /spawn-agent command.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="${DANGER_ROOT}/agents"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"
STATE_DIR="${DANGER_ROOT}/.danger-state"

# Parse arguments
AGENT_NAME=""
AGENT_ROLE=""
AGENT_PERSONALITY=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --personality)
            AGENT_PERSONALITY="$2"
            shift 2
            ;;
        *)
            if [[ -z "$AGENT_NAME" ]]; then
                AGENT_NAME="$1"
            elif [[ -z "$AGENT_ROLE" ]]; then
                AGENT_ROLE="$1"
            else
                AGENT_ROLE="$AGENT_ROLE $1"
            fi
            shift
            ;;
    esac
done

# Validate inputs
if [[ -z "$AGENT_NAME" ]]; then
    echo "Error: Agent name required"
    echo "Usage: /spawn-agent <name> <role> [--personality \"description\"]"
    exit 1
fi

if [[ -z "$AGENT_ROLE" ]]; then
    echo "Error: Agent role required"
    echo "Usage: /spawn-agent <name> <role> [--personality \"description\"]"
    exit 1
fi

# Sanitize agent name
AGENT_NAME=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

# Default personality if not provided
if [[ -z "$AGENT_PERSONALITY" ]]; then
    PERSONALITIES=(
        "Enthusiastic and thorough. Loves diving deep into problems."
        "Calm and methodical. Prefers clean, well-organized solutions."
        "Creative and bold. Not afraid to try unconventional approaches."
        "Pragmatic and efficient. Focuses on getting things done right."
        "Detail-oriented and cautious. Catches edge cases others miss."
    )
    AGENT_PERSONALITY="${PERSONALITIES[$((RANDOM % ${#PERSONALITIES[@]}))]}"
fi

# Create mailbox
MAILBOX_PATH="${MAILBOXES_DIR}/${AGENT_NAME}"
mkdir -p "$MAILBOX_PATH"
touch "$MAILBOX_PATH/inbox.md"
touch "$MAILBOX_PATH/outbox.md"
cat > "$MAILBOX_PATH/status.json" << EOF
{
    "actor": "$AGENT_NAME",
    "status": "spawned",
    "iteration": 0,
    "role": "$AGENT_ROLE",
    "created_at": "$(date -Iseconds)",
    "last_activity": "$(date -Iseconds)"
}
EOF

# Create agent prompt
AGENT_PROMPT="${AGENTS_DIR}/${AGENT_NAME}.md"
cat > "$AGENT_PROMPT" << EOF
# Agent: $AGENT_NAME

## Personality
$AGENT_PERSONALITY

## Role
$AGENT_ROLE

## Mailbox
- **Inbox:** ${MAILBOX_PATH}/inbox.md - Check for messages from other actors
- **Outbox:** ${MAILBOX_PATH}/outbox.md - Write messages using @mentions
- **Status:** ${MAILBOX_PATH}/status.json - Update your status

## Communication Protocol

### Receiving Messages
Check your inbox at the start of each iteration. Messages look like:
\`\`\`
---
**From:** orchestrator
**Time:** 2024-01-15T10:30:00Z
**Message:**
Your task assignment here
---
\`\`\`

### Sending Messages
Write to your outbox with @mentions:
- \`@agent-name Your message\` - Direct message
- \`@orchestrator Status update\` - Report to coordinator
- \`@all Announcement\` - Broadcast to everyone

### Updating Status
Modify your status.json to reflect:
- \`"status": "working"\` - Actively processing
- \`"status": "blocked"\` - Waiting for something
- \`"status": "complete"\` - Finished your work

## Guidelines

1. **Check inbox first** - Process any messages before starting work
2. **Stay focused** - Work on your assigned role
3. **Communicate** - Share discoveries that help others
4. **Be honest** - Report true progress and blockers
5. **Iterate** - Keep improving until your work is complete

## Completion

When your assigned work is complete:
1. Update status.json to \`"status": "complete"\`
2. Send summary to @orchestrator
3. Output: ACTOR_TASK_COMPLETE
EOF

# Update loop state if exists
LOOP_STATE="${STATE_DIR}/danger-loop.local.md"
if [[ -f "$LOOP_STATE" ]]; then
    # Increment active actors count
    CURRENT_ACTORS=$(grep -E "^Active Actors:" "$LOOP_STATE" | cut -d':' -f2 | tr -d ' ' || echo "0")
    NEW_ACTORS=$((CURRENT_ACTORS + 1))
    sed -i "s/^Active Actors:.*/Active Actors: $NEW_ACTORS/" "$LOOP_STATE"

    # Add to registry
    echo "- **$AGENT_NAME**: $AGENT_ROLE" >> "$LOOP_STATE"
fi

# Output confirmation
cat << EOF

# Agent Spawned: $AGENT_NAME

**Role:** $AGENT_ROLE
**Personality:** $AGENT_PERSONALITY

**Prompt:** $AGENT_PROMPT
**Mailbox:** $MAILBOX_PATH/

The agent is ready to receive tasks. Send a message to their inbox to assign work:

\`\`\`
Write to: $MAILBOX_PATH/inbox.md

---
**From:** orchestrator
**Time:** $(date -Iseconds)
**Message:**
Your initial task assignment here
---
\`\`\`

---
*"My cat's breath smells like cat food." - $AGENT_NAME is ready to help!*

EOF
