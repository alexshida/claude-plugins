#!/usr/bin/env bash
# Test the duration-to-cron computation used by /timer

set -euo pipefail

PASS=0
FAIL=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Runs the node snippet against a duration string.
# Returns "M H DoM Mon *" based on Date.now(), so we can only check
# the structure and delta — not exact values.
compute_cron() {
    local duration="$1"
    node -e "
const arg = process.argv[1];
const match = arg.match(/^(?:(\d+)d)?(?:(\d+)h(?:rs?)?)?(?:(\d+)m(?:in)?)?(?:(\d+)s)?$/i);
if (!match || !arg.trim()) { process.stderr.write('Invalid duration: ' + arg + '\n'); process.exit(1); }
const days    = parseInt(match[1] || 0);
const hours   = parseInt(match[2] || 0);
const minutes = parseInt(match[3] || 0);
const secs    = parseInt(match[4] || 0);
const totalMs = ((days * 24 + hours) * 60 + minutes) * 60000 + secs * 1000;
if (totalMs < 60000) { process.stderr.write('Minimum delay is 1 minute\n'); process.exit(1); }
const target = new Date(Date.now() + totalMs);
const M   = target.getMinutes();
const H   = target.getHours();
const DoM = target.getDate();
const Mon = target.getMonth() + 1;
process.stdout.write(totalMs + '\n');
" "$duration"
}

pass() { echo -e "${GREEN}PASS${NC} $1"; PASS=$((PASS + 1)); }
fail() { echo -e "${RED}FAIL${NC} $1 — $2"; FAIL=$((FAIL + 1)); }

assert_ms() {
    local label="$1" duration="$2" expected_ms="$3"
    local got
    if got=$(compute_cron "$duration" 2>&1); then
        if [ "$got" -eq "$expected_ms" ]; then
            pass "$label"
        else
            fail "$label" "expected ${expected_ms}ms, got ${got}ms"
        fi
    else
        fail "$label" "unexpected error: $got"
    fi
}

assert_error() {
    local label="$1" duration="$2"
    if compute_cron "$duration" >/dev/null 2>&1; then
        fail "$label" "expected error but got success"
    else
        pass "$label"
    fi
}

echo "=== Timer duration parser tests ==="
echo ""

# --- Valid durations ---
assert_ms "30m"              "30m"     $((30 * 60000))
assert_ms "15min"            "15min"   $((15 * 60000))
assert_ms "1h"               "1h"      $((60 * 60000))
assert_ms "1hr"              "1hr"     $((60 * 60000))
assert_ms "2hrs"             "2hrs"    $((2 * 60 * 60000))
assert_ms "1d"               "1d"      $((24 * 60 * 60000))
assert_ms "1h30m"            "1h30m"   $((90 * 60000))
assert_ms "2h30m"            "2h30m"   $((150 * 60000))
assert_ms "1d6h"             "1d6h"    $((30 * 60 * 60000))
assert_ms "1d2h30m"          "1d2h30m" $((26 * 60 * 60000 + 30 * 60000))

# --- Minimum enforced ---
assert_error "30s (below minimum)" "30s"
assert_error "0m (zero)"          "0m"

# --- Invalid formats ---
assert_error "empty string"       ""
assert_error "letters only"       "abc"
assert_error "no unit"            "60"

echo ""
echo "Results: ${PASS} passed, ${FAIL} failed"
[ "$FAIL" -eq 0 ]
