#!/usr/bin/env bash
# ============================================================================
# check-mailbox.sh - View Agent Mailbox Contents
# ============================================================================
# Displays inbox, outbox, and status for a specified agent.
# Called by the /check-mailbox command.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"

# Parse arguments
AGENT_NAME=""
SHOW_INBOX=false
SHOW_OUTBOX=false
SHOW_STATUS=false
SHOW_ALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --inbox)
            SHOW_INBOX=true
            shift
            ;;
        --outbox)
            SHOW_OUTBOX=true
            shift
            ;;
        --status)
            SHOW_STATUS=true
            shift
            ;;
        --all)
            SHOW_ALL=true
            shift
            ;;
        *)
            AGENT_NAME="$1"
            shift
            ;;
    esac
done

# Default to showing inbox if no flags specified
if ! $SHOW_INBOX && ! $SHOW_OUTBOX && ! $SHOW_STATUS && ! $SHOW_ALL; then
    SHOW_INBOX=true
fi

# Show all if requested
if $SHOW_ALL; then
    SHOW_INBOX=true
    SHOW_OUTBOX=true
    SHOW_STATUS=true
fi

# Validate agent name
if [[ -z "$AGENT_NAME" ]]; then
    echo "Error: Agent name required"
    echo "Usage: /check-mailbox <agent-name> [--inbox|--outbox|--status|--all]"
    echo ""
    echo "Available mailboxes:"
    for mailbox in "$MAILBOXES_DIR"/*/; do
        if [[ -d "$mailbox" ]]; then
            echo "  - $(basename "$mailbox")"
        fi
    done
    exit 1
fi

MAILBOX_PATH="${MAILBOXES_DIR}/${AGENT_NAME}"

if [[ ! -d "$MAILBOX_PATH" ]]; then
    echo "Error: Mailbox not found for agent: $AGENT_NAME"
    echo ""
    echo "Available mailboxes:"
    for mailbox in "$MAILBOXES_DIR"/*/; do
        if [[ -d "$mailbox" ]]; then
            echo "  - $(basename "$mailbox")"
        fi
    done
    exit 1
fi

echo "# Mailbox: $AGENT_NAME"
echo ""

# Show status
if $SHOW_STATUS; then
    echo "## Status"
    if [[ -f "$MAILBOX_PATH/status.json" ]]; then
        cat "$MAILBOX_PATH/status.json" | jq .
    else
        echo "(no status file)"
    fi
    echo ""
fi

# Show inbox
if $SHOW_INBOX; then
    echo "## Inbox"
    if [[ -s "$MAILBOX_PATH/inbox.md" ]]; then
        cat "$MAILBOX_PATH/inbox.md"
    else
        echo "(empty)"
    fi
    echo ""
fi

# Show outbox
if $SHOW_OUTBOX; then
    echo "## Outbox"
    if [[ -s "$MAILBOX_PATH/outbox.md" ]]; then
        cat "$MAILBOX_PATH/outbox.md"
    else
        echo "(empty)"
    fi
    echo ""
fi

echo "---"
echo "*\"I sleep in a drawer!\" - Mailboxes are cozy homes for messages.*"
