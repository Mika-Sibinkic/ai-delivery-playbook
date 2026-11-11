#!/usr/bin/env bash
# The repo's definition of working: backticked playbooks/ and templates/ paths exist, playbooks have skill
# frontmatter, and no home paths, private IPs, emails, common key formats, Windows default machine names
# (DESKTOP-*), Tailscale (.ts.net) or quick-tunnel (trycloudflare) hostnames ship. Other hostnames and
# names need the denylist below. Scans tracked files plus untracked ones git does not ignore.
# --self-test plants one sample per pattern and fails if any sample passes.
set -euo pipefail
cd "$(dirname "$0")/.."
git rev-parse --git-dir >/dev/null 2>&1 || { echo "check-docs: needs a git checkout" >&2; exit 2; }

if [[ ${1-} == --self-test ]]; then
  plant=scripts/self-test-plant.md
  trap 'rm -f "$plant"' EXIT
  scripts/check-docs.sh >/dev/null || { echo "check-docs self-test: tree is not clean to start" >&2; exit 1; }
  # Key samples are split with '' so this file never holds a matching literal.
  samples=(
    '/Users/someone/x' '/home/someone/x' 'C:\Users\x' 'c:\users\x' 'C:\\Users\\x' 'C:/Users/x'
    '10.1.2.3' '172.20.1.1' '192.168.1.1' '100.100.1.1' 'someone@example.com'
    'DESKTOP-ABC123' 'box.tail1234.ts.net' 'https://a-b.trycloudflare.com'
    'AKIA''ABCDEFGHIJKLMNOP' 'sk-''abcdefghijklmnopqrstuvwx' 'ghp_''abcdefghijklmnopqrstuvwxyz0123456789'
    'github_pat_''abcdefghijklmnopqrstuv' 'xoxb-''1234567890' 'AIza''abcdefghijklmnopqrstuvwxyz012345678'
    '-----BEGIN RSA ''PRIVATE KEY-----' '`playbooks/no-such-file.md`'
  )
  missed=0
  for s in "${samples[@]}"; do
    printf '%s\n' "$s" >"$plant"
    if scripts/check-docs.sh >/dev/null 2>&1; then echo "check-docs self-test: missed $s" >&2; missed=1; fi
  done
  (( missed )) || echo "check-docs self-test: ok, ${#samples[@]} samples caught"
  exit "$missed"
fi

fail=0
err() { echo "check-docs: $*" >&2; fail=1; }
# git grep exits 1 when nothing matches; that is clean. Any other nonzero exit is a broken scan.
scan() { local rc=0; git grep --untracked -nI "$@" || rc=$?; return $(( rc == 1 ? 0 : rc )); }

# 1. Every backticked playbooks/*.md or templates/*.md path in a .md file exists.
refs=$(scan -oE '`(playbooks|templates)/[^`]*\.md`' -- '*.md') || err "path scan failed"
while IFS=: read -r file line ref; do
  [[ -n $file ]] || continue
  path=${ref//\`/}
  [[ -f $path ]] || err "$file:$line: $path does not exist"
done <<<"$refs"

# 2. Each playbook opens with frontmatter whose name is its basename and that has a description.
for f in playbooks/*.md; do
  b=$(basename "$f" .md)
  [[ $(head -1 "$f") == --- ]] || { err "$f: no frontmatter"; continue; }
  fm=$(sed -n '2,/^---$/p' "$f")
  grep -qE "^name: *[\"']?$b[\"']? *$" <<<"$fm" || err "$f: frontmatter name is not $b"
  grep -qE '^description: *[^ ]' <<<"$fm" || err "$f: frontmatter has no description"
done

# 3. Private-material shapes: home paths (including lowercase and JSON-escaped Windows ones), RFC1918 and
#    100.64/10 addresses, emails, DESKTOP-*, .ts.net and trycloudflare hostnames, real key formats.
#    Prints file:line only, so a leaked key never lands in a CI log.
private='/Users/|/home/|[A-Za-z]:(\\{1,2}|/)[Uu]sers'
private+='|(^|[^0-9.])(10\.[0-9]{1,3}|192\.168|172\.(1[6-9]|2[0-9]|3[01])|100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7]))\.[0-9]{1,3}\.[0-9]{1,3}'
private+='|[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z.]{2,}|\.ts\.net|DESKTOP-[A-Z0-9]+|trycloudflare'
private+='|AKIA[0-9A-Z]{16}|(^|[^A-Za-z0-9])sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}'
private+='|xox[abprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
# Client and person names can't go in this public file. List them one per line in
# .git/info/check-docs-denylist, which git never commits; matching ignores case.
deny=()
denyfile=$(git rev-parse --git-path info/check-docs-denylist)
if [[ -f $denyfile ]]; then
  while IFS= read -r name; do [[ -z ${name// /} ]] || deny+=(-e "$name"); done <"$denyfile"
fi
leaks=$(scan -E "$private" -- ':!scripts/check-docs.sh') || err "private-material scan failed"
if (( ${#deny[@]} )); then
  names=$(scan -iF "${deny[@]}" -- ':!scripts/check-docs.sh') || err "denylist scan failed"
  leaks+=$'\n'$names
fi
while IFS=: read -r file line _; do
  [[ -z $file ]] || err "$file:$line: looks like private material"
done <<<"$leaks"

(( fail )) || echo "check-docs: ok"
exit "$fail"
