#!/usr/bin/env bash
# NC-OS privacy check. Fails if anything in the repo matches the private blocklist.
#
# The blocklist (one term per line: names, emails, hostnames, usernames, paths...) is
# NEVER stored in this repo. It comes from:
#   - $NCOS_BLOCKLIST (the text itself, used by CI from an encrypted secret), or
#   - the file $NCOS_BLOCKLIST_FILE (default ~/.config/nc-os/privacy-blocklist.txt) on a dev machine.
#
# Matched terms are never printed (CI logs are public): only file and line numbers.
#
# Usage: scripts/privacy-check.sh [--staged|--all|--history]
#   --staged   files staged for commit (pre-commit hook)
#   --all      every tracked file (default)
#   --history  every tracked file plus all commit messages and author/committer details
set -uo pipefail
mode="${1:---all}"

terms="${NCOS_BLOCKLIST:-}"
if [ -z "$terms" ]; then
  f="${NCOS_BLOCKLIST_FILE:-$HOME/.config/nc-os/privacy-blocklist.txt}"
  if [ -f "$f" ]; then terms="$(cat "$f")"; fi
fi
if [ -z "$(printf '%s' "$terms" | tr -d '[:space:]')" ]; then
  if [ "${NCOS_ALLOW_NO_BLOCKLIST:-}" = "1" ]; then
    echo "privacy-check: no blocklist available, skipping term check (allowed for this run)."
    exit 0
  fi
  echo "privacy-check: BLOCKED. No private blocklist found." >&2
  echo "  Set NCOS_BLOCKLIST, or create ~/.config/nc-os/privacy-blocklist.txt (one term per line)." >&2
  exit 1
fi

pat="$(mktemp)"; trap 'rm -f "$pat"' EXIT
printf '%s\n' "$terms" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | grep -v -e '^$' -e '^#' > "$pat"
count=$(wc -l < "$pat")

fail=0
check_files() {
  # $@ = files
  for file in "$@"; do
    [ -f "$file" ] || continue
    hits=$(grep -I -n -i -F -f "$pat" -- "$file" 2>/dev/null | cut -d: -f1 | paste -sd, -)
    if [ -n "$hits" ]; then echo "privacy-check: personal data in $file (line(s) $hits)" >&2; fail=1; fi
    # file and folder names count too
    if printf '%s\n' "$file" | grep -q -i -F -f "$pat"; then echo "privacy-check: personal data in a file or folder name (path withheld)" >&2; fail=1; fi
  done
}

case "$mode" in
  --staged)
    mapfile -d '' files < <(git diff --cached --name-only --diff-filter=ACMR -z)
    tmpd="$(mktemp -d)"
    for file in "${files[@]}"; do mkdir -p "$tmpd/$(dirname "$file")"; git show ":$file" > "$tmpd/$file" 2>/dev/null; done
    # check the staged version of each file, not the working copy
    pushd "$tmpd" >/dev/null; check_files "${files[@]}"; popd >/dev/null
    rm -rf "$tmpd"
    # the commit's author and committer details
    for who in "$(git config user.name)" "$(git config user.email)"; do
      if printf '%s\n' "$who" | grep -q -i -F -f "$pat"; then echo "privacy-check: your git user.name or user.email matches the blocklist; use your GitHub no-reply address." >&2; fail=1; fi
    done
    ;;
  --all|--history)
    mapfile -d '' files < <(git ls-files -z)
    check_files "${files[@]}"
    if [ "$mode" = "--history" ]; then
      if git log --all --format='%an%n%ae%n%cn%n%ce%n%B' | grep -q -i -F -f "$pat"; then
        echo "privacy-check: personal data in commit history (authors, emails or messages)." >&2; fail=1
      fi
    fi
    ;;
  *) echo "usage: $0 [--staged|--all|--history]" >&2; exit 2 ;;
esac

if [ "$fail" -ne 0 ]; then
  echo "privacy-check: FAILED. Remove the personal data before committing (see docs/PRIVACY.md)." >&2
  exit 1
fi
echo "privacy-check: OK ($count blocklist terms checked)."
