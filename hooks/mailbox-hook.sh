#!/usr/bin/env bash
# ============================================================================
# mailbox-hook.sh - Process Mailbox Messages After Tool Use
# ============================================================================
# Routes messages between actors after file operations.
# Enables real-time inter-agent communication.
# ============================================================================

set -euo pipefail

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MAILBOXES_DIR="${MAILBOXES_DIR:-${DANGER_ROOT}/mailboxes}"
STATE_DIR="${STATE_DIR:-${DANGER_ROOT}/.danger-state}"

# Only process if mailboxes exist
if [[ ! -d "$MAILBOXES_DIR" ]]; then
    exit 0
fi

# Check for any outbox with pending messages
MESSAGES_ROUTED=0

shopt -s nullglob
for mailbox in "$MAILBOXES_DIR"/*/; do
    if [[ -d "$mailbox" ]]; then
        outbox="${mailbox}outbox.md"

        if [[ -s "$outbox" ]]; then
            actor_name=$(basename "$mailbox")

            # Process each line looking for @mentions
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Skip empty lines
                [[ -z "$line" ]] && continue

                # Find @mentions
                if [[ "$line" =~ @([a-zA-Z0-9_-]+) ]]; then
                    target="${BASH_REMATCH[1]}"
                    timestamp=$(date -Iseconds)

                    if [[ "$target" == "all" ]]; then
                        # Broadcast to all actors except sender
                        for target_mailbox in "$MAILBOXES_DIR"/*/; do
                            target_name=$(basename "$target_mailbox")
                            if [[ "$target_name" != "$actor_name" && -d "$target_mailbox" ]]; then
                                cat >> "${target_mailbox}inbox.md" << EOF

---
**From:** $actor_name
**Time:** $timestamp
**Type:** broadcast

$line
---
EOF
                                MESSAGES_ROUTED=$((MESSAGES_ROUTED + 1))
                            fi
                        done
                    else
                        # Direct message to specific actor
                        target_inbox="${MAILBOXES_DIR}/${target}/inbox.md"
                        if [[ -f "$target_inbox" ]]; then
                            cat >> "$target_inbox" << EOF

---
**From:** $actor_name
**Time:** $timestamp
**Type:** direct

$line
---
EOF
                            MESSAGES_ROUTED=$((MESSAGES_ROUTED + 1))
                        fi
                    fi
                fi
            done < "$outbox"

            # Clear the outbox after processing
            > "$outbox"

            # Update actor status
            status_file="${mailbox}status.json"
            if [[ -f "$status_file" ]]; then
                # Update last_activity timestamp
                tmp_file=$(mktemp)
                jq --arg time "$(date -Iseconds)" '.last_activity = $time' "$status_file" > "$tmp_file" && mv "$tmp_file" "$status_file"
            fi
        fi
    fi
done
shopt -u nullglob

# Log routing activity if messages were routed
if [[ $MESSAGES_ROUTED -gt 0 ]]; then
    echo "[mailbox-hook] Routed $MESSAGES_ROUTED messages" >> "${STATE_DIR}/mailbox.log" 2>/dev/null || true
fi

exit 0
