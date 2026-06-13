#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

passed=0
failed=0
errors=()

for test_file in test/*_test.rb; do
  if ruby "$test_file" > /dev/null 2>&1; then
    echo "PASS  $test_file"
    passed=$((passed + 1))
  else
    echo "FAIL  $test_file"
    failed=$((failed + 1))
    errors+=("$test_file")
  fi
done

echo ""
echo "Results: $passed passed, $failed failed"

if [ ${#errors[@]} -gt 0 ]; then
  echo ""
  echo "Failed files:"
  for f in "${errors[@]}"; do
    echo "  $f"
    ruby "$f" 2>&1 | tail -5
  done
  exit 1
fi
