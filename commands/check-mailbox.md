# Check Agent Mailbox

View the inbox, outbox, and status of a specific agent.

## Usage

```
/check-mailbox <agent-name> [--inbox|--outbox|--status|--all]
```

## Execution

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/check-mailbox.sh" $ARGUMENTS
```

## Parameters

- `agent-name`: The name of the agent to inspect (required)
- `--inbox`: Show only inbox messages (default)
- `--outbox`: Show only outbox messages
- `--status`: Show only status JSON
- `--all`: Show everything

## Examples

```
/check-mailbox security-chief --all
```

```
/check-mailbox orchestrator --status
```

## Special Mailboxes

- `orchestrator` - The cho-cho-choose master coordinator
- Agent mailboxes are created when agents spawn

## Mailbox Contents

### inbox.md
Messages received from other agents:
```
---
**From:** orchestrator
**Time:** 2024-01-15T10:30:00Z
**Message:**
Please review the authentication module
---
```

### outbox.md
Messages to be routed to other agents:
```
@coder-bart I found a security issue in the login flow
@all Authentication module review complete
```

### status.json
Current agent state:
```json
{
  "actor": "security-chief",
  "status": "working",
  "iteration": 12,
  "last_activity": "2024-01-15T10:45:00Z"
}
```

---

*"My cat's breath smells like cat food." - Sometimes the messages are profound, sometimes they're not.*
