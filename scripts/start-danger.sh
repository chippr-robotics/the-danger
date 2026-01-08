#!/usr/bin/env bash
# ============================================================================
# start-danger.sh - Initialize The Danger Actor System
# ============================================================================
# Sets up the danger loop state and orchestrator for concurrent actor runs.
# Called by the /danger-loop command.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${DANGER_ROOT}/.danger-state"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"
AGENTS_DIR="${DANGER_ROOT}/agents"

# Defaults
DEFAULT_ACTORS=3
DEFAULT_MAX_ITERATIONS=50
COMPLETION_PROMISE="ORCHESTRATION_COMPLETE"

# Parse arguments
TASK=""
NUM_ACTORS=$DEFAULT_ACTORS
MAX_ITERATIONS=$DEFAULT_MAX_ITERATIONS

while [[ $# -gt 0 ]]; do
    case "$1" in
        --actors)
            NUM_ACTORS="$2"
            shift 2
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        *)
            if [[ -z "$TASK" ]]; then
                TASK="$1"
            else
                TASK="$TASK $1"
            fi
            shift
            ;;
    esac
done

if [[ -z "$TASK" ]]; then
    echo "Error: No task provided"
    echo "Usage: /danger-loop <task> [--actors N] [--max-iterations N]"
    exit 1
fi

# Create directories
mkdir -p "$STATE_DIR"
mkdir -p "$MAILBOXES_DIR/orchestrator"

# Initialize orchestrator mailbox
touch "$MAILBOXES_DIR/orchestrator/inbox.md"
touch "$MAILBOXES_DIR/orchestrator/outbox.md"
cat > "$MAILBOXES_DIR/orchestrator/status.json" << EOF
{
    "actor": "orchestrator",
    "status": "initializing",
    "iteration": 0,
    "actors_spawned": 0,
    "created_at": "$(date -Iseconds)",
    "last_activity": "$(date -Iseconds)"
}
EOF

# Create loop state file
cat > "${STATE_DIR}/danger-loop.local.md" << EOF
# The Danger - Active Loop State

**Status:** running
**Started:** $(date -Iseconds)
**Max Iterations:** $MAX_ITERATIONS
**Current Iteration:** 0
**Target Actors:** $NUM_ACTORS
**Active Actors:** 0
**Completion Promise:** $COMPLETION_PROMISE

## Original Task
$TASK

## Actor Registry
(Actors will be registered here as they are spawned)

## Notes
- Check mailboxes/ for inter-agent communication
- Each actor has inbox.md, outbox.md, and status.json
- Use @mentions in outbox to route messages
EOF

# Output the initial orchestrator prompt
cat << EOF

# The Danger - Actor System Initialized

**Task:** $TASK
**Actors:** $NUM_ACTORS
**Max Iterations:** $MAX_ITERATIONS

You are now the **cho-cho-choose** orchestrator. Your mission:

1. **Analyze the Task**: Break down "$TASK" into parallelizable sub-tasks
2. **Design Actors**: Create $NUM_ACTORS specialized agents with unique roles
3. **Spawn Agents**: For each agent, create their prompt file in agents/
4. **Coordinate**: Use mailboxes to coordinate work between actors
5. **Verify**: Ensure all parts integrate correctly

## Quick Start

For each actor you want to create:

1. Create their prompt at \`agents/<name>.md\` with personality and role
2. Create their mailbox at \`mailboxes/<name>/\` with inbox.md, outbox.md, status.json
3. Send them their initial task via their inbox

## Mailbox Communication

Write to an actor's \`outbox.md\` with @mentions:
- \`@actor-name message\` - Direct message
- \`@all message\` - Broadcast to everyone

## Completion

When all actors have completed and work is verified, output:
\`$COMPLETION_PROMISE\`

---

*Read agents/cho-cho-choose.md for your full orchestrator prompt.*
*"I'm learnding!" - Begin orchestration now.*

EOF
