# Cancel The Danger

Stop all running actors and clean up the system.

## Usage

```
/cancel-danger [--force] [--keep-mailboxes]
```

## Execution

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/cancel-danger.sh" $ARGUMENTS
```

## Parameters

- `--force`: Immediately kill all processes without graceful shutdown
- `--keep-mailboxes`: Preserve mailbox contents for debugging

## What Happens

1. Sends termination signal to all running actors
2. Waits for graceful shutdown (unless --force)
3. Cleans up PID files and state
4. Optionally preserves or clears mailboxes
5. Reports final status of each actor

## Examples

```
/cancel-danger
```

Graceful shutdown - actors finish current iteration then stop.

```
/cancel-danger --force
```

Immediate termination - for when things go sideways.

```
/cancel-danger --keep-mailboxes
```

Stop actors but keep mailbox history for post-mortem analysis.

## Recovery

After cancellation, you can:
- Review logs in `.danger-state/<agent>.log`
- Check mailboxes for last communications
- Restart with `/danger-loop` using the same or modified task

---

*"I'm in danger!" - Sometimes you need the escape hatch. No shame in it.*
