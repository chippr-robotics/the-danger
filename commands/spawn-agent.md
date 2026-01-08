# Spawn a New Agent

Dynamically create and start a new agent actor with a specified role.

## Usage

```
/spawn-agent <name> <role> [--personality "description"]
```

## Execution

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/spawn-agent.sh" $ARGUMENTS
```

## Parameters

- `name`: Unique identifier for the agent (required)
- `role`: The agent's specialty/focus area (required)
- `--personality`: Custom personality description (optional)

## Examples

```
/spawn-agent security-chief "Handle all authentication and authorization"
```

```
/spawn-agent test-ninja "Write comprehensive unit and integration tests" --personality "Paranoid about edge cases, writes tests for tests"
```

## What Gets Created

1. Agent prompt file at `agents/<name>.md`
2. Mailbox directory at `mailboxes/<name>/`
   - `inbox.md` - Incoming messages
   - `outbox.md` - Outgoing messages
   - `status.json` - Current status

## Agent Communication

Once spawned, agents can:
- Receive tasks via their inbox
- Send messages using @mentions in outbox
- Check status of other agents
- Request help from the orchestrator

---

*"The doctor said I wouldn't have so many nosebleeds if I kept my finger outta there." - Every agent has their role, even if unconventional.*
