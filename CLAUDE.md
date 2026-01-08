# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The Danger is an actor-based concurrent AI agent system built as a Claude Code plugin. It spawns multiple AI agents that collaborate via mailbox message passing to accomplish complex tasks in parallel. Each agent runs its own iteration loop and communicates with others through inbox/outbox files.

## Architecture

```
                    cho-cho-choose (Orchestrator)
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
       Agent 1         Agent 2         Agent 3
           │               │               │
           └───────────────┼───────────────┘
                           ▼
                      MAILBOXES
                   (Message Routing)
```

**Key Components:**

- **Orchestrator (`agents/cho-cho-choose.md`)**: Master coordinator that decomposes tasks, spawns agents, and coordinates work
- **Hooks**: Control the iteration loop and message routing
  - `actor-stop-hook.sh`: Blocks stop to continue loops, processes mailboxes, checks completion promise
  - `mailbox-hook.sh`: Routes messages after Write/Edit/Bash operations via `@mention` syntax
- **Mailboxes (`mailboxes/<agent>/`)**: Each agent has `inbox.md`, `outbox.md`, and `status.json`
- **State (`.danger-state/`)**: Runtime state files, logs, and PID tracking

**Message Routing:**
- `@agent-name message` - Direct message to specific agent
- `@all message` - Broadcast to all agents
- Messages written to `outbox.md` are automatically routed to recipient inboxes

## Commands

| Command | Description |
|---------|-------------|
| `/danger-loop <task> [--actors N] [--max-iterations N]` | Start concurrent agent orchestration |
| `/spawn-agent <name> <role> [--personality "..."]` | Create new agent mid-execution |
| `/check-mailbox <agent> [--inbox\|--outbox\|--status\|--all]` | Inspect agent communications |
| `/cancel-danger [--force] [--keep-mailboxes]` | Stop all actors and cleanup |

## Standalone Usage

```bash
./idaho.sh "Your task here" --actors 5 --max-iterations 100
```

## Key Files

- `idaho.sh` - Standalone bash actor manager (runs outside Claude Code)
- `scripts/start-danger.sh` - Plugin initialization script
- `hooks/hooks.json` - Hook configuration for Claude Code
- `.danger-state/danger-loop.local.md` - Active loop state tracking

## Completion Signal

Agents signal completion by outputting `TASK_COMPLETE`. The orchestrator signals all work done with `ORCHESTRATION_COMPLETE`.
