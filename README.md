# The Danger 🚨

> *"I'm in danger!"* - Ralph Wiggum, moments before enlightenment

```
  _____ _            ____
 |_   _| |__   ___  |  _ \  __ _ _ __   __ _  ___ _ __
   | | | '_ \ / _ \ | | | |/ _` | '_ \ / _` |/ _ \ '__|
   | | | | | |  __/ | |_| | (_| | | | | (_| |  __/ |
   |_| |_| |_|\___| |____/ \__,_|_| |_|\__, |\___|_|
                                       |___/
```

**An actor-based concurrent AI agent system built on the ralph-wiggum technique.**

Like Ralph Wiggum, this system may seem simple at first. But beneath that paste-eating exterior lies a sophisticated multi-agent orchestration framework that will have your codebase generating itself while you sleep.

## What Is This?

Remember the `ralph-wiggum` plugin? That beautiful disaster that runs Claude in a loop until your code works?

**The Danger** is Ralph with friends. Multiple AI agents working together, passing notes like elementary schoolers, each with their own personality and specialty. It's like a software development team, except everyone actually reads their emails.

## How It Works

```
┌──────────────────────────────────────────────────────────┐
│                    cho-cho-choose                        │
│                 (The Orchestrator)                       │
│        "I choo-choo-choose you to build this API"       │
└─────────────────────┬────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
        ▼             ▼             ▼
   ┌─────────┐  ┌─────────┐  ┌─────────┐
   │ Agent 1 │  │ Agent 2 │  │ Agent 3 │
   │ "Bart"  │  │ "Lisa"  │  │"Milhouse│
   │ Backend │  │Frontend │  │ Tests"  │
   └────┬────┘  └────┬────┘  └────┬────┘
        │            │            │
        └────────────┼────────────┘
                     │
              ┌──────┴──────┐
              │  MAILBOXES  │
              │ (The Drama) │
              └─────────────┘
```

Each agent:
- Has a **personality** (yes, really)
- Runs their own **ralph loop** (concurrent chaos)
- Communicates via **mailboxes** (like passing notes in class)
- Works on their **specialty** (divide and conquer)

## Quick Start

### As a Claude Code Plugin

1. Clone into your project:
```bash
git clone https://github.com/chippr-robotics/the-danger.git .claude/plugins/the-danger
```

2. Start the danger:
```bash
/danger-loop "Build me a REST API with authentication, tests, and documentation"
```

3. Watch the magic (or horror, depending on your perspective)

### Standalone Mode

For the brave souls who want to run this outside Claude Code:

```bash
./idaho.sh "Your ambitious task here" --actors 5 --max-iterations 100
```

*"I'm Idaho!"* - The script, probably

## Commands

| Command | What it does |
|---------|-------------|
| `/danger-loop <task>` | Unleash the agents |
| `/spawn-agent <name> <role>` | Create a new agent mid-chaos |
| `/check-mailbox <agent>` | Spy on agent communications |
| `/cancel-danger` | Pull the emergency brake |
| `/help` | Cry for help |

## The Cast

### cho-cho-choose (The Orchestrator)
*"I choo-choo-choose you!"*

The master coordinator. Analyzes tasks, spawns agents, and keeps everyone on track. Like a project manager, but actually useful.

### Dynamic Agents
Each agent gets randomly assigned a personality:
- **Enthusiastic Debugger**: *"Every bug is a friend I haven't met!"*
- **Paranoid Tester**: *"But what if the user enters a negative infinity?"*
- **Minimalist Architect**: *"If we delete this file, we don't have to maintain it"*
- **Documentation Evangelist**: *"Comments are just code hugs"*

## Directory Structure

```
the-danger/
├── agents/                 # Agent personality files
│   └── cho-cho-choose.md   # The orchestrator prompt
├── mailboxes/              # Inter-agent communication
│   ├── orchestrator/       # Boss's inbox
│   └── <agent-name>/       # Each agent gets one
├── commands/               # Slash commands
├── hooks/                  # The magic sauce
├── scripts/                # Shell utilities
├── .claude-plugin/         # Plugin config
├── .danger-state/          # Runtime state (gitignored)
├── idaho.sh               # Standalone runner
└── README.md              # You are here
```

## How Agents Communicate

Agents use mailboxes like responsible adults who've read their email:

```markdown
# mailboxes/bart-420/outbox.md

@lisa-123 Hey, I finished the API endpoints. Your turn for the frontend!
@orchestrator Backend complete, moving to optimization
@all Coffee break? Just kidding, we're AIs
```

Messages get automatically routed to recipient inboxes. It's like Slack, but everyone actually reads their messages.

## FAQ

**Q: Is this production ready?**
A: *"Me fail English? That's unpossible!"*

**Q: How many agents should I use?**
A: Start with 3-5. More isn't always better. It's like a standup meeting - after 7 people, everyone's just waiting for their turn to not pay attention.

**Q: What if the agents disagree?**
A: The orchestrator handles conflicts. Democracy is great, but sometimes you need a benevolent dictator who also happens to be an AI prompt.

**Q: Can agents spawn other agents?**
A: Yes! It's agents all the way down. We call this "the danger" for a reason.

**Q: Is this just a complicated way to run Claude in parallel?**
A: Yes. But with *personality*.

## Philosophy

> *"The doctor said I wouldn't have so many nosebleeds if I kept my finger outta there."*
> - Ralph Wiggum, on iterative development

The Danger embraces several key principles:

1. **Parallel > Sequential**: Why have one AI when you can have five arguing?
2. **Iteration > Perfection**: Keep trying until it works or you hit max iterations
3. **Communication > Isolation**: Agents that share are agents that care
4. **Personality > Uniformity**: Different perspectives catch different bugs

## Safety Features

- **Max Iterations**: Because infinite loops are only fun in theory
- **Completion Promises**: Agents can't lie about being done (they have to *actually* be done)
- **Mailbox Logging**: Full audit trail of agent drama
- **Emergency Cancel**: `/cancel-danger` when things get too real

## Contributing

PRs welcome! Before submitting:

1. Make sure your code passes the vibe check
2. Add a Ralph Wiggum quote if appropriate
3. Test with at least 3 concurrent agents
4. Document any new ways the system can go hilariously wrong

## License

MIT - Because sharing is caring, and Ralph would want it that way.

## Credits

Built on the shoulders of giants:
- [ralph-wiggum](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum) - The OG iterative loop
- Claude Code - The platform that makes this possible
- The Simpsons - For 35+ years of quotable wisdom

---

<p align="center">
  <i>"I bent my wookiee!"</i><br>
  <small>- Ralph Wiggum, on merge conflicts</small>
</p>

<p align="center">
  <b>Go forth and be dangerous.</b>
</p>
