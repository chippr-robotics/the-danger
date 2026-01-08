#!/usr/bin/env bash
# ============================================================================
# idaho.sh - The Danger Actor Manager
# "I'm Idaho!" - Ralph Wiggum
# ============================================================================
# A minimal bash actor-manager for concurrent ralph loops with self-defining actors
# Each actor gets a mailbox, a personality, and an unstoppable desire to help.
# ============================================================================

set -euo pipefail

# Colors for pretty output (because we're dangerous, not boring)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration defaults
DEFAULT_ACTORS=3
DEFAULT_MAX_ITERATIONS=50
DEFAULT_COMPLETION_PROMISE="TASK_COMPLETE"
DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="${DANGER_ROOT}/agents"
MAILBOXES_DIR="${DANGER_ROOT}/mailboxes"
STATE_DIR="${DANGER_ROOT}/.danger-state"
ORCHESTRATOR_PROMPT="${AGENTS_DIR}/cho-cho-choose.md"

# Print banner
print_banner() {
    echo -e "${RED}"
    cat << 'EOF'
  _____ _            ____
 |_   _| |__   ___  |  _ \  __ _ _ __   __ _  ___ _ __
   | | | '_ \ / _ \ | | | |/ _` | '_ \ / _` |/ _ \ '__|
   | | | | | |  __/ | |_| | (_| | | | | (_| |  __/ |
   |_| |_| |_|\___| |____/ \__,_|_| |_|\__, |\___|_|
                                       |___/
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}\"I'm Idaho!\" - Ralph Wiggum${NC}"
    echo -e "${CYAN}Actor-based concurrent ralph loops with self-defining agents${NC}"
    echo ""
}

# Usage information
usage() {
    print_banner
    echo "Usage: $0 [OPTIONS] <task-prompt>"
    echo ""
    echo "Options:"
    echo "  -a, --actors <n>           Number of concurrent actors (default: $DEFAULT_ACTORS)"
    echo "  -m, --max-iterations <n>   Max iterations per actor (default: $DEFAULT_MAX_ITERATIONS)"
    echo "  -p, --promise <text>       Completion promise string (default: $DEFAULT_COMPLETION_PROMISE)"
    echo "  -c, --claude-path <path>   Path to claude CLI (default: auto-detect)"
    echo "  -v, --verbose              Enable verbose output"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -a 5 -m 100 'Build a REST API with tests'"
    echo ""
    echo "The system will:"
    echo "  1. Spawn the cho-cho-choose orchestrator"
    echo "  2. Create actor agents with unique personalities"
    echo "  3. Run concurrent ralph loops"
    echo "  4. Coordinate via mailbox message passing"
    echo ""
}

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_actor() {
    local actor_name="$1"
    local message="$2"
    echo -e "${PURPLE}[ACTOR:${actor_name}]${NC} $message"
}

# Initialize the danger system
init_danger() {
    log_info "Initializing The Danger system..."

    # Create necessary directories
    mkdir -p "$AGENTS_DIR"
    mkdir -p "$MAILBOXES_DIR"
    mkdir -p "$STATE_DIR"

    # Check for orchestrator prompt
    if [[ ! -f "$ORCHESTRATOR_PROMPT" ]]; then
        log_error "Orchestrator prompt not found at $ORCHESTRATOR_PROMPT"
        log_info "Please ensure cho-cho-choose.md exists in the agents directory"
        exit 1
    fi

    log_success "Danger system initialized"
}

# Create mailbox for an actor
create_mailbox() {
    local actor_name="$1"
    local mailbox_path="${MAILBOXES_DIR}/${actor_name}"

    mkdir -p "$mailbox_path"
    touch "$mailbox_path/inbox.md"
    touch "$mailbox_path/outbox.md"
    touch "$mailbox_path/status.json"

    # Initialize status
    cat > "$mailbox_path/status.json" << EOF
{
    "actor": "$actor_name",
    "status": "initialized",
    "iteration": 0,
    "created_at": "$(date -Iseconds)",
    "last_activity": "$(date -Iseconds)"
}
EOF

    log_info "Created mailbox for actor: $actor_name"
    echo "$mailbox_path"
}

# Send message to actor mailbox
send_message() {
    local from_actor="$1"
    local to_actor="$2"
    local message="$3"
    local inbox_path="${MAILBOXES_DIR}/${to_actor}/inbox.md"

    if [[ -f "$inbox_path" ]]; then
        cat >> "$inbox_path" << EOF

---
**From:** $from_actor
**Time:** $(date -Iseconds)
**Message:**
$message
---
EOF
        log_info "Message sent from $from_actor to $to_actor"
    else
        log_warn "Mailbox not found for actor: $to_actor"
    fi
}

# Read messages from mailbox
read_messages() {
    local actor_name="$1"
    local inbox_path="${MAILBOXES_DIR}/${actor_name}/inbox.md"

    if [[ -f "$inbox_path" ]]; then
        cat "$inbox_path"
    fi
}

# Clear inbox after reading
clear_inbox() {
    local actor_name="$1"
    local inbox_path="${MAILBOXES_DIR}/${actor_name}/inbox.md"

    if [[ -f "$inbox_path" ]]; then
        > "$inbox_path"
    fi
}

# Create an actor agent prompt
create_actor_prompt() {
    local actor_name="$1"
    local personality="$2"
    local task="$3"
    local actor_prompt_path="${AGENTS_DIR}/${actor_name}.md"

    cat > "$actor_prompt_path" << EOF
# Agent: $actor_name

## Personality
$personality

## Role
You are an autonomous actor in The Danger system. You work collaboratively with other actors to complete tasks through message passing.

## Your Mailbox
- **Inbox:** Check ${MAILBOXES_DIR}/${actor_name}/inbox.md for messages from other actors
- **Outbox:** Write to ${MAILBOXES_DIR}/${actor_name}/outbox.md when you need to communicate
- **Status:** Update ${MAILBOXES_DIR}/${actor_name}/status.json with your progress

## Communication Protocol
1. Check your inbox at the start of each iteration
2. Process any messages and incorporate feedback
3. Do your work on the assigned task
4. Write status updates and messages to other actors as needed
5. Clear your inbox after processing

## Current Task
$task

## Guidelines
- Be collaborative - share useful discoveries with other actors
- Be focused - work on your assigned portion of the task
- Be honest - report true progress and blockers
- Be persistent - keep iterating until the task is complete

## Completion
When your part is complete, output: $DEFAULT_COMPLETION_PROMISE
EOF

    echo "$actor_prompt_path"
}

# Generate a random personality for an actor
generate_personality() {
    local personalities=(
        "Enthusiastic and detail-oriented. You love finding edge cases and writing tests."
        "Calm and methodical. You prefer clean architecture and readable code."
        "Creative and experimental. You're not afraid to try unconventional approaches."
        "Pragmatic and efficient. You focus on getting things done with minimal complexity."
        "Thorough and documentation-focused. You ensure everything is well-explained."
        "Security-minded and cautious. You always consider potential vulnerabilities."
        "Performance-obsessed. You optimize for speed and efficiency."
        "User-focused. You always consider the developer experience."
    )

    local index=$((RANDOM % ${#personalities[@]}))
    echo "${personalities[$index]}"
}

# Generate a random actor name
generate_actor_name() {
    local names=(
        "ralph" "lisa" "bart" "milhouse" "nelson" "martin"
        "todd" "rod" "sherri" "terri" "wendell" "lewis"
        "database" "janey" "uter" "allison"
    )

    local index=$((RANDOM % ${#names[@]}))
    local suffix=$((RANDOM % 1000))
    echo "${names[$index]}-${suffix}"
}

# Start a ralph loop for an actor
start_actor_loop() {
    local actor_name="$1"
    local actor_prompt="$2"
    local max_iterations="$3"
    local completion_promise="$4"
    local task="$5"
    local claude_path="$6"
    local log_file="${STATE_DIR}/${actor_name}.log"

    log_actor "$actor_name" "Starting ralph loop..."

    # Create the ralph loop state for this actor
    local state_file="${STATE_DIR}/${actor_name}-ralph.local.md"
    cat > "$state_file" << EOF
# Ralph Loop State: $actor_name

**Prompt:** See ${actor_prompt}
**Task:** $task
**Max Iterations:** $max_iterations
**Completion Promise:** $completion_promise
**Current Iteration:** 0
**Status:** running
EOF

    # Build the combined prompt
    local combined_prompt
    combined_prompt=$(cat "$actor_prompt")
    combined_prompt="${combined_prompt}

## Task Details
${task}

---
*Actor Loop Iteration 1 of ${max_iterations}*
*Check your mailbox, do your work, communicate with peers*
"

    # Run claude with the actor prompt
    if [[ -n "$claude_path" ]]; then
        echo "$combined_prompt" | "$claude_path" --print >> "$log_file" 2>&1 &
    else
        echo "$combined_prompt" | claude --print >> "$log_file" 2>&1 &
    fi

    local pid=$!
    echo "$pid" > "${STATE_DIR}/${actor_name}.pid"

    log_actor "$actor_name" "Started with PID $pid"
    echo "$pid"
}

# Monitor actors and coordinate
monitor_actors() {
    local -a pids=("$@")
    local running=true

    log_info "Monitoring ${#pids[@]} actors..."

    while $running; do
        running=false
        for pid in "${pids[@]}"; do
            if kill -0 "$pid" 2>/dev/null; then
                running=true
            fi
        done

        if $running; then
            sleep 5
            # Check mailboxes and process inter-actor messages
            process_mailboxes
        fi
    done

    log_success "All actors have completed"
}

# Process mailbox messages between actors
process_mailboxes() {
    for mailbox in "$MAILBOXES_DIR"/*; do
        if [[ -d "$mailbox" ]]; then
            local actor_name
            actor_name=$(basename "$mailbox")
            local outbox="$mailbox/outbox.md"

            # Check if there are outgoing messages to route
            if [[ -s "$outbox" ]]; then
                # Parse outbox for @mentions and route messages
                while IFS= read -r line; do
                    if [[ "$line" =~ @([a-zA-Z0-9_-]+) ]]; then
                        local target="${BASH_REMATCH[1]}"
                        send_message "$actor_name" "$target" "$line"
                    fi
                done < "$outbox"

                # Clear outbox after processing
                > "$outbox"
            fi
        fi
    done
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."

    # Kill any remaining actor processes
    for pid_file in "$STATE_DIR"/*.pid; do
        if [[ -f "$pid_file" ]]; then
            local pid
            pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid" 2>/dev/null || true
            fi
            rm -f "$pid_file"
        fi
    done

    log_info "Cleanup complete"
}

# Main orchestration function
orchestrate() {
    local num_actors="$1"
    local max_iterations="$2"
    local completion_promise="$3"
    local task="$4"
    local claude_path="${5:-}"
    local verbose="${6:-false}"

    log_info "Starting orchestration with $num_actors actors"
    log_info "Task: $task"

    # Set up trap for cleanup
    trap cleanup EXIT

    # Create orchestrator mailbox
    create_mailbox "orchestrator"

    # Create actors
    local -a actor_pids=()
    local -a actor_names=()

    for ((i=1; i<=num_actors; i++)); do
        local actor_name
        actor_name=$(generate_actor_name)
        actor_names+=("$actor_name")

        local personality
        personality=$(generate_personality)

        # Create mailbox
        create_mailbox "$actor_name"

        # Create actor prompt
        local actor_prompt
        actor_prompt=$(create_actor_prompt "$actor_name" "$personality" "$task")

        # Send initial task assignment
        send_message "orchestrator" "$actor_name" "You are actor $i of $num_actors. Your task: $task"

        log_actor "$actor_name" "Created with personality: $personality"

        # Start the actor's ralph loop
        local pid
        pid=$(start_actor_loop "$actor_name" "$actor_prompt" "$max_iterations" "$completion_promise" "$task" "$claude_path")
        actor_pids+=("$pid")
    done

    # Monitor all actors
    monitor_actors "${actor_pids[@]}"

    # Summarize results
    log_success "Orchestration complete!"
    echo ""
    echo -e "${GREEN}=== Results ===${NC}"
    for actor_name in "${actor_names[@]}"; do
        local log_file="${STATE_DIR}/${actor_name}.log"
        if [[ -f "$log_file" ]]; then
            echo -e "${CYAN}--- $actor_name ---${NC}"
            tail -20 "$log_file"
            echo ""
        fi
    done
}

# Parse command line arguments
main() {
    local num_actors="$DEFAULT_ACTORS"
    local max_iterations="$DEFAULT_MAX_ITERATIONS"
    local completion_promise="$DEFAULT_COMPLETION_PROMISE"
    local claude_path=""
    local verbose=false
    local task=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--actors)
                num_actors="$2"
                shift 2
                ;;
            -m|--max-iterations)
                max_iterations="$2"
                shift 2
                ;;
            -p|--promise)
                completion_promise="$2"
                shift 2
                ;;
            -c|--claude-path)
                claude_path="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                task="$1"
                shift
                ;;
        esac
    done

    # Validate inputs
    if [[ -z "$task" ]]; then
        usage
        echo ""
        log_error "No task provided!"
        exit 1
    fi

    print_banner
    init_danger
    orchestrate "$num_actors" "$max_iterations" "$completion_promise" "$task" "$claude_path" "$verbose"
}

# Run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
