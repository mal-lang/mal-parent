#!/bin/sh

set -eu

cd "$(dirname "$0")/../../.."

set +e
changed_java="$(
  git diff --cached --name-only --diff-filter=ACMR |
  grep "\.java$"
)"
set -e

if [ -z "$changed_java" ]; then
  exit
fi

# shellcheck source=../../scripts/google-java-format.sh
. tools/scripts/google-java-format.sh

latest_name="$(get_latest_name)"
fmt_jar="$PWD/tools/$latest_name"

if [ ! -f "$fmt_jar" ]; then
  echo "Downloading $latest_name"
  latest_url="$(get_latest_url)"
  wget -qO "$fmt_jar" "$latest_url"
fi

echo "Formatting $(echo "$changed_java" | wc -l) java files"
echo "$changed_java" | tr "\n" "\0" | xargs -0 java -jar "$fmt_jar" --replace
echo "$changed_java" | tr "\n" "\0" | xargs -0 git add -f
