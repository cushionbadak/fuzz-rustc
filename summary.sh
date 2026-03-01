#!/usr/bin/env bash
# Summarize fuzzing progress: artifacts breakdown, corpus size.
# Safe to run while the fuzzer is still running.
set -euo pipefail

cd "$(dirname "$0")"

fmt_count() {
    local dir=$1
    local pattern=$2
    ls "$dir"/$pattern 2>/dev/null | wc -l | tr -d ' '
}

echo "=== fuzz-rustc summary ($(date)) ==="
echo ""

# Artifacts breakdown
fmt="  %-12s %6s\n"

echo "--- Artifacts ---"
if [ -d artifacts ] && [ -n "$(ls -A artifacts 2>/dev/null)" ]; then
    crashes=$(fmt_count artifacts "crash-*")
    timeouts=$(fmt_count artifacts "timeout-*")
    ooms=$(fmt_count artifacts "oom-*")
    total=$(ls artifacts/ 2>/dev/null | wc -l | tr -d ' ')

    printf "$fmt" "crashes" "$crashes"
    printf "$fmt" "timeouts" "$timeouts"
    printf "$fmt" "ooms" "$ooms"
    printf "$fmt" "total" "$total"
else
    echo "  (none yet)"
fi

echo ""

# Corpus
echo "--- Corpus ---"
if [ -d corpus ] && [ -n "$(ls -A corpus 2>/dev/null)" ]; then
    count=$(ls corpus | wc -l | tr -d ' ')
    size=$(du -sh corpus | cut -f1)
    printf "$fmt" "inputs" "$count"
    printf "$fmt" "size" "$size"
else
    echo "  (empty)"
fi

echo ""

# Latest artifacts
if [ -d artifacts ] && [ -n "$(ls -A artifacts 2>/dev/null)" ]; then
    echo "--- Latest artifacts (newest 5) ---"
    ls -lt artifacts/ | tail -n +2 | head -5 | awk '{print "  " $0}'
fi
