# Start The Danger Actor System

Initialize and run the actor-based concurrent ralph loop system.

## Usage

```
/danger-loop <task> [--actors N] [--max-iterations N]
```

## Execution

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/start-danger.sh" $ARGUMENTS
```

## Parameters

- `TASK`: The main task to accomplish (required)
- `--actors N`: Number of concurrent actors to spawn (default: 3)
- `--max-iterations N`: Maximum iterations per actor (default: 50)

## What Happens

1. The **cho-cho-choose** orchestrator analyzes your task
2. Specialized agents are spawned with unique personalities
3. Each agent runs its own ralph loop concurrently
4. Agents communicate via mailbox message passing
5. Work continues until all agents complete or max iterations reached

## Example

```
/danger-loop "Build a REST API with authentication and tests" --actors 5
```

This spawns 5 agents who will collaboratively:
- Design the architecture
- Implement endpoints
- Handle authentication
- Write tests
- Create documentation

## Important Notes

- Each agent has a mailbox at `mailboxes/<agent-name>/`
- Agents coordinate automatically via the orchestrator
- Check `mailboxes/orchestrator/summary.md` for final results
- Use `/check-mailbox <agent-name>` to inspect agent communication

## Completion

The system outputs `ORCHESTRATION_COMPLETE` when all agents have finished their work and the task is verified complete.

---

*"I bent my wookiee!" - Even when things seem broken, the actors will iterate until it works.*
