#!/usr/bin/env bash
# ============================================================================
# actor-stop-hook.sh - The Danger Actor Loop Continuation
# ============================================================================
# Intercepts stop attempts to continue actor loops and coordinate mailboxes.
# Similar to ralph-wiggum's stop hook but for multi-actor coordination.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${DANGER_ROOT}/.danger-state"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"
LOOP_STATE_FILE="${STATE_DIR}/danger-loop.local.md"

# Check if we're in an active danger loop
if [[ ! -f "$LOOP_STATE_FILE" ]]; then
    # No active loop, allow normal stop
    echo '{"decision": "allow"}'
    exit 0
fi

# Read loop state
CURRENT_ITERATION=$(grep -E "^Current Iteration:" "$LOOP_STATE_FILE" | cut -d':' -f2 | tr -d ' ' || echo "0")
MAX_ITERATIONS=$(grep -E "^Max Iterations:" "$LOOP_STATE_FILE" | cut -d':' -f2 | tr -d ' ' || echo "50")
ACTIVE_ACTORS=$(grep -E "^Active Actors:" "$LOOP_STATE_FILE" | cut -d':' -f2 | tr -d ' ' || echo "0")
COMPLETION_PROMISE=$(grep -E "^Completion Promise:" "$LOOP_STATE_FILE" | cut -d':' -f2- | xargs || echo "ORCHESTRATION_COMPLETE")

# Validate numeric values
if ! [[ "$CURRENT_ITERATION" =~ ^[0-9]+$ ]]; then
    CURRENT_ITERATION=0
fi
if ! [[ "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=50
fi

# Check if max iterations reached
if [[ "$CURRENT_ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    echo '{"decision": "allow", "reason": "Max iterations reached for danger loop"}'
    # Clean up state
    rm -f "$LOOP_STATE_FILE"
    exit 0
fi

# Check for completion promise in transcript
TRANSCRIPT_FILE="${CLAUDE_TRANSCRIPT_FILE:-}"
if [[ -n "$TRANSCRIPT_FILE" && -f "$TRANSCRIPT_FILE" ]]; then
    # Get last assistant message
    LAST_OUTPUT=$(tail -1 "$TRANSCRIPT_FILE" 2>/dev/null | jq -r '.message.content[]?.text // empty' 2>/dev/null || echo "")

    # Check for completion promise
    if [[ "$LAST_OUTPUT" == *"$COMPLETION_PROMISE"* ]]; then
        echo '{"decision": "allow", "reason": "Orchestration complete - all actors finished"}'
        rm -f "$LOOP_STATE_FILE"
        exit 0
    fi
fi

# Process mailboxes - route any pending messages
for mailbox in "$MAILBOXES_DIR"/*/; do
    if [[ -d "$mailbox" ]]; then
        outbox="${mailbox}outbox.md"
        if [[ -s "$outbox" ]]; then
            actor_name=$(basename "$mailbox")
            # Route messages to target inboxes
            while IFS= read -r line; do
                if [[ "$line" =~ @([a-zA-Z0-9_-]+) ]]; then
                    target="${BASH_REMATCH[1]}"
                    if [[ "$target" == "all" ]]; then
                        # Broadcast to all actors
                        for target_mailbox in "$MAILBOXES_DIR"/*/; do
                            target_name=$(basename "$target_mailbox")
                            if [[ "$target_name" != "$actor_name" ]]; then
                                echo -e "\n---\n**From:** $actor_name\n**Time:** $(date -Iseconds)\n$line\n---" >> "${target_mailbox}inbox.md"
                            fi
                        done
                    else
                        target_inbox="${MAILBOXES_DIR}/${target}/inbox.md"
                        if [[ -f "$target_inbox" ]]; then
                            echo -e "\n---\n**From:** $actor_name\n**Time:** $(date -Iseconds)\n$line\n---" >> "$target_inbox"
                        fi
                    fi
                fi
            done < "$outbox"
            > "$outbox"  # Clear outbox
        fi
    fi
done

# Increment iteration
NEW_ITERATION=$((CURRENT_ITERATION + 1))
sed -i "s/^Current Iteration:.*/Current Iteration: $NEW_ITERATION/" "$LOOP_STATE_FILE"

# Build the continuation prompt
ORIGINAL_PROMPT=$(grep -A 100 "^## Original Task" "$LOOP_STATE_FILE" | tail -n +2 | head -50 || echo "Continue working on the task")

# Check all actor statuses
ACTOR_STATUS=""
for mailbox in "$MAILBOXES_DIR"/*/; do
    if [[ -d "$mailbox" ]]; then
        status_file="${mailbox}status.json"
        if [[ -f "$status_file" ]]; then
            actor_name=$(basename "$mailbox")
            status=$(jq -r '.status // "unknown"' "$status_file" 2>/dev/null || echo "unknown")
            ACTOR_STATUS="${ACTOR_STATUS}\n- ${actor_name}: ${status}"
        fi
    fi
done

# Build continuation message
REASON=$(cat << EOF
## Danger Loop - Iteration $NEW_ITERATION of $MAX_ITERATIONS

### Actor Status
$ACTOR_STATUS

### Instructions
Continue coordinating the actors. Check mailboxes for messages, assign tasks, and work toward completion.

### Original Task
$ORIGINAL_PROMPT

### Completion
When all work is done and verified, output: $COMPLETION_PROMISE
EOF
)

# Return the block decision with continuation prompt
jq -n \
    --arg reason "$REASON" \
    --arg iteration "$NEW_ITERATION" \
    '{
        "decision": "block",
        "reason": $reason,
        "systemMessage": ("Danger Loop iteration " + $iteration + " - Actors are collaborating")
    }'
