#!/bin/sh

set -eu

cd "$(dirname "$0")/../../.."

set +e
changed_json="$(
  git diff --cached --name-only --diff-filter=ACMR |
  grep "\.json$"
)"
set -e

if [ -z "$changed_json" ]; then
  exit
fi

echo "Formatting $(echo "$changed_json" | wc -l) json files"
echo "$changed_json" | while IFS= read -r file; do
  # shellcheck disable=SC2005
  echo "$(jq . "$file")" >"$file"
done
echo "$changed_json" | tr "\n" "\0" | xargs -0 git add -f
