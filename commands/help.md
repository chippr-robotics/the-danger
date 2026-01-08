# The Danger - Help

*"I'm learnding!" - Let's learn together.*

## What is The Danger?

The Danger is an actor-based extension of the ralph-wiggum technique. Instead of a single AI running in a loop, we spawn multiple AI agents that:

1. Work concurrently on different aspects of your task
2. Communicate via mailbox message passing
3. Self-organize under the cho-cho-choose orchestrator
4. Iterate until everything is complete

## Available Commands

| Command | Description |
|---------|-------------|
| `/danger-loop <task>` | Start the full actor system |
| `/spawn-agent <name> <role>` | Create a new agent mid-run |
| `/check-mailbox <agent>` | Inspect agent communications |
| `/cancel-danger` | Stop all running actors |
| `/help` | Show this help message |

## Quick Start

```
/danger-loop "Build a todo app with React frontend and Node backend"
```

This will:
1. Spawn the orchestrator (cho-cho-choose)
2. Create specialized agents for frontend, backend, tests, etc.
3. Run concurrent ralph loops
4. Coordinate via mailboxes until done

## Directory Structure

```
the-danger/
├── agents/           # Agent prompt files
│   └── cho-cho-choose.md
├── mailboxes/        # Inter-agent communication
│   ├── orchestrator/
│   └── <agent-name>/
├── commands/         # Slash commands
├── hooks/            # Event hooks
├── scripts/          # Shell utilities
├── .danger-state/    # Runtime state & logs
└── idaho.sh          # Standalone runner
```

## Standalone Usage

You can also run The Danger outside of Claude Code:

```bash
./idaho.sh "Your task here" --actors 5 --max-iterations 100
```

## Philosophy

- **Parallel over Sequential**: Multiple agents working simultaneously
- **Communication over Isolation**: Agents share discoveries and coordinate
- **Iteration over Perfection**: Keep improving until it's right
- **Personality over Uniformity**: Each agent brings unique perspective

## Tips

1. **Clear Tasks**: Be specific about what you want
2. **Right-size Actors**: More actors isn't always better
3. **Check Mailboxes**: See how agents are coordinating
4. **Trust the Process**: Let it iterate

---

*"Mrs. Krabappel and Principal Skinner were in the closet making babies and I saw one of the babies and the baby looked at me!" - Complex systems can seem mysterious, but they're just agents passing messages.*
