#!/usr/bin/env bash
# The repo's definition of working: references resolve, playbooks load as skills, and no home paths,
# private IPs or common key formats ship. Scans tracked files plus untracked ones git does not ignore.
set -euo pipefail
cd "$(dirname "$0")/.."
fail=0
err() { echo "check-docs: $*" >&2; fail=1; }

# 1. Every backticked playbooks/*.md or templates/*.md path in a .md file exists.
while IFS=: read -r file ref; do
  path=${ref//\`/}
  [[ -f $path ]] || err "$file: $path does not exist"
done < <(git ls-files -z --cached --others --exclude-standard '*.md' | xargs -0 grep -oHE '`(playbooks|templates)/[^`]*\.md`')

# 2. Each playbook opens with frontmatter whose name is its basename and that has a description.
for f in playbooks/*.md; do
  b=$(basename "$f" .md)
  [[ $(head -1 "$f") == --- ]] || { err "$f: no frontmatter"; continue; }
  fm=$(sed -n '2,/^---$/p' "$f")
  grep -qE "^name: *[\"']?$b[\"']? *$" <<<"$fm" || err "$f: frontmatter name is not $b"
  grep -qE '^description: *[^ ]' <<<"$fm" || err "$f: frontmatter has no description"
done

# 3. Private-material shapes: home paths, RFC1918 and 100.64/10 addresses, real key formats.
#    Prints file:line only, so a leaked key never lands in a CI log.
private='/Users/|/home/|[A-Za-z]:[\\/]Users[\\/]'
private+='|(^|[^0-9.])(10\.[0-9]{1,3}|192\.168|172\.(1[6-9]|2[0-9]|3[01])|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7]))\.[0-9]{1,3}\.[0-9]{1,3}'
private+='|AKIA[0-9A-Z]{16}|(^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}'
private+='|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
while IFS=: read -r file line _; do
  err "$file:$line: looks like private material"
done < <(git ls-files -z --cached --others --exclude-standard ':!scripts/check-docs.sh' | xargs -0 grep -nIE "$private")

(( fail )) || echo "check-docs: ok"
exit "$fail"
