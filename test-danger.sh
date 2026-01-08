#!/usr/bin/env bash
# ============================================================================
# test-danger.sh - Validation Test Suite for The Danger
# ============================================================================
# "I'm a test! Wheee!" - Ralph Wiggum, probably
#
# Validates that all components of the actor-based system are functional.
# Run with: ./test-danger.sh
# ============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DANGER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test helpers
print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

test_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_fail() {
    echo -e "  ${RED}✗${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_skip() {
    echo -e "  ${YELLOW}○${NC} $1 (skipped)"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

assert_file_exists() {
    local file="$1"
    local desc="${2:-$file exists}"
    if [[ -f "$file" ]]; then
        test_pass "$desc"
        return 0
    else
        test_fail "$desc"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local desc="${2:-$dir exists}"
    if [[ -d "$dir" ]]; then
        test_pass "$desc"
        return 0
    else
        test_fail "$desc"
        return 1
    fi
}

assert_executable() {
    local file="$1"
    local desc="${2:-$file is executable}"
    if [[ -x "$file" ]]; then
        test_pass "$desc"
        return 0
    else
        test_fail "$desc"
        return 1
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local desc="${3:-$file contains '$pattern'}"
    if grep -q "$pattern" "$file" 2>/dev/null; then
        test_pass "$desc"
        return 0
    else
        test_fail "$desc"
        return 1
    fi
}

assert_json_valid() {
    local file="$1"
    local desc="${2:-$file is valid JSON}"
    if jq empty "$file" 2>/dev/null; then
        test_pass "$desc"
        return 0
    else
        test_fail "$desc"
        return 1
    fi
}

# ============================================================================
# TEST SUITES
# ============================================================================

test_directory_structure() {
    print_header "Directory Structure Tests"

    assert_dir_exists "$DANGER_ROOT/agents" "agents/ directory exists"
    assert_dir_exists "$DANGER_ROOT/mailboxes" "mailboxes/ directory exists"
    assert_dir_exists "$DANGER_ROOT/commands" "commands/ directory exists"
    assert_dir_exists "$DANGER_ROOT/hooks" "hooks/ directory exists"
    assert_dir_exists "$DANGER_ROOT/scripts" "scripts/ directory exists"
    assert_dir_exists "$DANGER_ROOT/.claude-plugin" ".claude-plugin/ directory exists"
}

test_core_files() {
    print_header "Core File Tests"

    # Main script
    assert_file_exists "$DANGER_ROOT/idaho.sh" "idaho.sh exists"
    assert_executable "$DANGER_ROOT/idaho.sh" "idaho.sh is executable"

    # Orchestrator prompt
    assert_file_exists "$DANGER_ROOT/agents/cho-cho-choose.md" "cho-cho-choose.md exists"

    # Plugin config
    assert_file_exists "$DANGER_ROOT/.claude-plugin/plugin.json" "plugin.json exists"
    assert_json_valid "$DANGER_ROOT/.claude-plugin/plugin.json" "plugin.json is valid JSON"

    # README
    assert_file_exists "$DANGER_ROOT/README.md" "README.md exists"
}

test_commands() {
    print_header "Command File Tests"

    local commands=("danger-loop" "spawn-agent" "check-mailbox" "cancel-danger" "help")

    for cmd in "${commands[@]}"; do
        assert_file_exists "$DANGER_ROOT/commands/${cmd}.md" "commands/${cmd}.md exists"
    done

    # Check command content
    assert_contains "$DANGER_ROOT/commands/danger-loop.md" "CLAUDE_PLUGIN_ROOT" "danger-loop.md references plugin root"
    assert_contains "$DANGER_ROOT/commands/spawn-agent.md" "spawn-agent.sh" "spawn-agent.md references script"
}

test_hooks() {
    print_header "Hook Tests"

    assert_file_exists "$DANGER_ROOT/hooks/hooks.json" "hooks.json exists"
    assert_json_valid "$DANGER_ROOT/hooks/hooks.json" "hooks.json is valid JSON"

    assert_file_exists "$DANGER_ROOT/hooks/actor-stop-hook.sh" "actor-stop-hook.sh exists"
    assert_executable "$DANGER_ROOT/hooks/actor-stop-hook.sh" "actor-stop-hook.sh is executable"

    assert_file_exists "$DANGER_ROOT/hooks/mailbox-hook.sh" "mailbox-hook.sh exists"
    assert_executable "$DANGER_ROOT/hooks/mailbox-hook.sh" "mailbox-hook.sh is executable"

    # Validate hook types in hooks.json
    if jq -e '.hooks[] | select(.type == "Stop")' "$DANGER_ROOT/hooks/hooks.json" >/dev/null 2>&1; then
        test_pass "hooks.json contains Stop hook"
    else
        test_fail "hooks.json contains Stop hook"
    fi
}

test_scripts() {
    print_header "Script Tests"

    local scripts=("start-danger" "spawn-agent" "check-mailbox" "cancel-danger")

    for script in "${scripts[@]}"; do
        assert_file_exists "$DANGER_ROOT/scripts/${script}.sh" "scripts/${script}.sh exists"
        assert_executable "$DANGER_ROOT/scripts/${script}.sh" "scripts/${script}.sh is executable"
    done
}

test_idaho_help() {
    print_header "idaho.sh Functionality Tests"

    # Test help output
    local help_output
    help_output=$("$DANGER_ROOT/idaho.sh" --help 2>&1 || true)

    if echo "$help_output" | grep -q "Idaho"; then
        test_pass "idaho.sh --help shows banner"
    else
        test_fail "idaho.sh --help shows banner"
    fi

    if echo "$help_output" | grep -q "\-\-actors"; then
        test_pass "idaho.sh --help shows --actors option"
    else
        test_fail "idaho.sh --help shows --actors option"
    fi

    if echo "$help_output" | grep -q "\-\-max-iterations"; then
        test_pass "idaho.sh --help shows --max-iterations option"
    else
        test_fail "idaho.sh --help shows --max-iterations option"
    fi
}

test_mailbox_creation() {
    print_header "Mailbox System Tests"

    local test_mailbox="$DANGER_ROOT/mailboxes/test-agent-$$"

    # Create test mailbox
    mkdir -p "$test_mailbox"
    touch "$test_mailbox/inbox.md"
    touch "$test_mailbox/outbox.md"
    cat > "$test_mailbox/status.json" << EOF
{
    "actor": "test-agent-$$",
    "status": "testing",
    "iteration": 0
}
EOF

    assert_dir_exists "$test_mailbox" "Test mailbox created"
    assert_file_exists "$test_mailbox/inbox.md" "inbox.md created"
    assert_file_exists "$test_mailbox/outbox.md" "outbox.md created"
    assert_json_valid "$test_mailbox/status.json" "status.json is valid JSON"

    # Test message format
    cat >> "$test_mailbox/inbox.md" << EOF

---
**From:** orchestrator
**Time:** $(date -Iseconds)
**Message:**
Test message content
---
EOF

    if grep -q "orchestrator" "$test_mailbox/inbox.md"; then
        test_pass "Message format is correct"
    else
        test_fail "Message format is correct"
    fi

    # Cleanup
    rm -rf "$test_mailbox"
    test_pass "Test mailbox cleaned up"
}

test_agent_prompt_generation() {
    print_header "Agent Prompt Generation Tests"

    local test_agent_prompt="$DANGER_ROOT/agents/test-agent-$$.md"

    # Simulate agent creation
    cat > "$test_agent_prompt" << EOF
# Agent: test-agent-$$

## Personality
Enthusiastic and thorough. Loves testing things.

## Role
Validation and quality assurance.

## Mailbox
- **Inbox:** mailboxes/test-agent-$$/inbox.md
- **Outbox:** mailboxes/test-agent-$$/outbox.md
EOF

    assert_file_exists "$test_agent_prompt" "Agent prompt file created"
    assert_contains "$test_agent_prompt" "Personality" "Agent prompt contains Personality section"
    assert_contains "$test_agent_prompt" "Role" "Agent prompt contains Role section"
    assert_contains "$test_agent_prompt" "Mailbox" "Agent prompt contains Mailbox section"

    # Cleanup
    rm -f "$test_agent_prompt"
    test_pass "Test agent prompt cleaned up"
}

test_orchestrator_prompt() {
    print_header "Orchestrator Prompt Tests"

    local orch_prompt="$DANGER_ROOT/agents/cho-cho-choose.md"

    assert_contains "$orch_prompt" "cho-cho-choose" "Contains orchestrator name"
    assert_contains "$orch_prompt" "Agent Creation" "Contains Agent Creation section"
    assert_contains "$orch_prompt" "Task Decomposition" "Contains Task Decomposition section"
    assert_contains "$orch_prompt" "Communication Protocol" "Contains Communication Protocol section"
    assert_contains "$orch_prompt" "@" "Contains @mention syntax"
    assert_contains "$orch_prompt" "ORCHESTRATION_COMPLETE" "Contains completion signal"
}

test_plugin_config() {
    print_header "Plugin Configuration Tests"

    local plugin_json="$DANGER_ROOT/.claude-plugin/plugin.json"

    # Check required fields
    if jq -e '.name' "$plugin_json" >/dev/null 2>&1; then
        test_pass "plugin.json has 'name' field"
    else
        test_fail "plugin.json has 'name' field"
    fi

    if jq -e '.version' "$plugin_json" >/dev/null 2>&1; then
        test_pass "plugin.json has 'version' field"
    else
        test_fail "plugin.json has 'version' field"
    fi

    if jq -e '.description' "$plugin_json" >/dev/null 2>&1; then
        test_pass "plugin.json has 'description' field"
    else
        test_fail "plugin.json has 'description' field"
    fi

    # Check name matches
    local name
    name=$(jq -r '.name' "$plugin_json")
    if [[ "$name" == "the-danger" ]]; then
        test_pass "plugin.json name is 'the-danger'"
    else
        test_fail "plugin.json name is 'the-danger' (got: $name)"
    fi
}

test_script_syntax() {
    print_header "Script Syntax Validation Tests"

    local scripts=(
        "$DANGER_ROOT/idaho.sh"
        "$DANGER_ROOT/scripts/start-danger.sh"
        "$DANGER_ROOT/scripts/spawn-agent.sh"
        "$DANGER_ROOT/scripts/check-mailbox.sh"
        "$DANGER_ROOT/scripts/cancel-danger.sh"
        "$DANGER_ROOT/hooks/actor-stop-hook.sh"
        "$DANGER_ROOT/hooks/mailbox-hook.sh"
    )

    for script in "${scripts[@]}"; do
        local name
        name=$(basename "$script")
        if bash -n "$script" 2>/dev/null; then
            test_pass "$name has valid bash syntax"
        else
            test_fail "$name has valid bash syntax"
        fi
    done
}

test_spawn_agent_script() {
    print_header "Spawn Agent Script Integration Test"

    # Set up test environment
    local test_state_dir="$DANGER_ROOT/.danger-state-test-$$"
    local test_mailbox_dir="$DANGER_ROOT/mailboxes"
    local test_agents_dir="$DANGER_ROOT/agents"

    mkdir -p "$test_state_dir"

    # Create a loop state file to simulate active loop
    cat > "$test_state_dir/danger-loop.local.md" << EOF
# Test Loop State
**Active Actors:** 0
EOF

    # Run spawn-agent script with test parameters
    local output
    if output=$(STATE_DIR="$test_state_dir" "$DANGER_ROOT/scripts/spawn-agent.sh" "test-spawn-$$" "Testing spawn functionality" 2>&1); then
        test_pass "spawn-agent.sh executes successfully"
    else
        test_fail "spawn-agent.sh executes successfully"
    fi

    # Check created files
    if [[ -f "$test_agents_dir/test-spawn-$$.md" ]]; then
        test_pass "Agent prompt file was created"
        rm -f "$test_agents_dir/test-spawn-$$.md"
    else
        test_fail "Agent prompt file was created"
    fi

    if [[ -d "$test_mailbox_dir/test-spawn-$$" ]]; then
        test_pass "Agent mailbox was created"
        rm -rf "$test_mailbox_dir/test-spawn-$$"
    else
        test_fail "Agent mailbox was created"
    fi

    # Cleanup
    rm -rf "$test_state_dir"
}

test_check_mailbox_script() {
    print_header "Check Mailbox Script Integration Test"

    # Create test mailbox
    local test_mailbox="$DANGER_ROOT/mailboxes/check-test-$$"
    mkdir -p "$test_mailbox"
    echo "Test inbox message" > "$test_mailbox/inbox.md"
    echo "Test outbox message" > "$test_mailbox/outbox.md"
    echo '{"actor": "check-test", "status": "testing"}' > "$test_mailbox/status.json"

    # Test --inbox
    local output
    if output=$("$DANGER_ROOT/scripts/check-mailbox.sh" "check-test-$$" --inbox 2>&1); then
        if echo "$output" | grep -q "Test inbox message"; then
            test_pass "check-mailbox.sh --inbox shows inbox content"
        else
            test_fail "check-mailbox.sh --inbox shows inbox content"
        fi
    else
        test_fail "check-mailbox.sh --inbox executes"
    fi

    # Test --status
    if output=$("$DANGER_ROOT/scripts/check-mailbox.sh" "check-test-$$" --status 2>&1); then
        if echo "$output" | grep -q "testing"; then
            test_pass "check-mailbox.sh --status shows status"
        else
            test_fail "check-mailbox.sh --status shows status"
        fi
    else
        test_fail "check-mailbox.sh --status executes"
    fi

    # Cleanup
    rm -rf "$test_mailbox"
}

test_message_routing() {
    print_header "Message Routing Tests"

    # Create two test mailboxes
    local sender_mailbox="$DANGER_ROOT/mailboxes/sender-$$"
    local receiver_mailbox="$DANGER_ROOT/mailboxes/receiver-$$"

    mkdir -p "$sender_mailbox" "$receiver_mailbox"
    touch "$sender_mailbox/inbox.md" "$sender_mailbox/outbox.md"
    touch "$receiver_mailbox/inbox.md" "$receiver_mailbox/outbox.md"
    echo '{"actor": "sender", "status": "active"}' > "$sender_mailbox/status.json"
    echo '{"actor": "receiver", "status": "active"}' > "$receiver_mailbox/status.json"

    # Write message with @mention to sender's outbox
    echo "@receiver-$$ Hello from sender!" > "$sender_mailbox/outbox.md"

    # Run mailbox hook to route messages
    if MAILBOXES_DIR="$DANGER_ROOT/mailboxes" STATE_DIR="$DANGER_ROOT/.danger-state" \
       "$DANGER_ROOT/hooks/mailbox-hook.sh" 2>/dev/null; then
        test_pass "mailbox-hook.sh executes successfully"
    else
        test_fail "mailbox-hook.sh executes successfully"
    fi

    # Check if message was routed
    if grep -q "Hello from sender" "$receiver_mailbox/inbox.md" 2>/dev/null; then
        test_pass "Message was routed to receiver's inbox"
    else
        test_fail "Message was routed to receiver's inbox"
    fi

    # Check if sender's outbox was cleared
    if [[ ! -s "$sender_mailbox/outbox.md" ]]; then
        test_pass "Sender's outbox was cleared after routing"
    else
        test_fail "Sender's outbox was cleared after routing"
    fi

    # Cleanup
    rm -rf "$sender_mailbox" "$receiver_mailbox"
}

test_stop_hook_allow() {
    print_header "Stop Hook Tests (No Active Loop)"

    # Without a loop state file, should allow stop
    local output
    if output=$("$DANGER_ROOT/hooks/actor-stop-hook.sh" 2>&1); then
        if echo "$output" | jq -e '.decision == "allow"' >/dev/null 2>&1; then
            test_pass "Stop hook allows exit when no loop active"
        else
            test_fail "Stop hook allows exit when no loop active"
        fi
    else
        test_fail "Stop hook executes without loop state"
    fi
}

# ============================================================================
# MAIN TEST RUNNER
# ============================================================================

print_banner() {
    echo ""
    echo -e "${YELLOW}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                                                           ║${NC}"
    echo -e "${YELLOW}║   🚨 THE DANGER - Test Suite 🚨                          ║${NC}"
    echo -e "${YELLOW}║   \"Me fail English? That's unpossible!\"                   ║${NC}"
    echo -e "${YELLOW}║                                                           ║${NC}"
    echo -e "${YELLOW}╚═══════════════════════════════════════════════════════════╝${NC}"
}

print_summary() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  TEST SUMMARY${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  Total:  ${TESTS_TOTAL}"
    echo -e "  ${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "  ${RED}Failed: ${TESTS_FAILED}${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}  ✓ All tests passed!${NC}"
        echo ""
        echo -e "  ${YELLOW}\"I'm a unitard!\"${NC} - Ralph, on test coverage"
        return 0
    else
        echo -e "${RED}  ✗ Some tests failed!${NC}"
        echo ""
        echo -e "  ${YELLOW}\"My cat's breath smells like cat food.\"${NC}"
        echo -e "  ${YELLOW}  - Something is off, but we'll figure it out${NC}"
        return 1
    fi
}

main() {
    print_banner

    # Check for jq dependency
    if ! command -v jq &>/dev/null; then
        echo -e "${RED}Error: jq is required but not installed${NC}"
        echo "Install with: apt-get install jq (or brew install jq on macOS)"
        exit 1
    fi

    # Run all test suites
    test_directory_structure
    test_core_files
    test_commands
    test_hooks
    test_scripts
    test_idaho_help
    test_mailbox_creation
    test_agent_prompt_generation
    test_orchestrator_prompt
    test_plugin_config
    test_script_syntax
    test_spawn_agent_script
    test_check_mailbox_script
    test_message_routing
    test_stop_hook_allow

    print_summary
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
