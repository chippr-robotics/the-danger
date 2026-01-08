#!/usr/bin/env bash
# ============================================================================
# cancel-danger.sh - Stop All Actor Processes
# ============================================================================
# Terminates all running actors and cleans up state.
# Called by the /cancel-danger command.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="${DANGER_ROOT}/.danger-state"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"

# Parse arguments
FORCE=false
KEEP_MAILBOXES=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --keep-mailboxes)
            KEEP_MAILBOXES=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo "# Canceling The Danger"
echo ""

# Kill any running actor processes
KILLED=0
for pid_file in "$STATE_DIR"/*.pid 2>/dev/null; do
    if [[ -f "$pid_file" ]]; then
        pid=$(cat "$pid_file")
        actor_name=$(basename "$pid_file" .pid)

        if kill -0 "$pid" 2>/dev/null; then
            if $FORCE; then
                kill -9 "$pid" 2>/dev/null || true
                echo "Force killed: $actor_name (PID $pid)"
            else
                kill "$pid" 2>/dev/null || true
                echo "Terminated: $actor_name (PID $pid)"
            fi
            ((KILLED++))
        else
            echo "Already stopped: $actor_name"
        fi

        rm -f "$pid_file"
    fi
done

if [[ $KILLED -eq 0 ]]; then
    echo "No running actors found."
fi

# Remove loop state
if [[ -f "${STATE_DIR}/danger-loop.local.md" ]]; then
    rm -f "${STATE_DIR}/danger-loop.local.md"
    echo "Removed loop state file."
fi

# Handle mailboxes
if $KEEP_MAILBOXES; then
    echo "Keeping mailboxes for inspection."
else
    if [[ -d "$MAILBOXES_DIR" ]]; then
        # Clear mailbox contents but keep structure
        for mailbox in "$MAILBOXES_DIR"/*/; do
            if [[ -d "$mailbox" ]]; then
                > "${mailbox}inbox.md" 2>/dev/null || true
                > "${mailbox}outbox.md" 2>/dev/null || true
            fi
        done
        echo "Cleared mailbox contents."
    fi
fi

echo ""
echo "## Summary"
echo "- Actors terminated: $KILLED"
echo "- Mailboxes preserved: $KEEP_MAILBOXES"
echo "- State cleaned: true"
echo ""
echo "The Danger has been neutralized."
echo ""
echo "---"
echo "*\"When I grow up, I want to be a principal or a caterpillar.\" - There's always next time.*"
