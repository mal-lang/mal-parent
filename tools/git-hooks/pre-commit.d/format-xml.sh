#!/bin/sh

set -eu

cd "$(dirname "$0")/../../.."

set +e
changed_xml="$(
  git diff --cached --name-only --diff-filter=ACMR |
  grep "\.xml$" |
  grep -v "^pom\.xml$"
)"
set -e

if [ -z "$changed_xml" ]; then
  exit
fi

# shellcheck source=../../scripts/utils.sh
. tools/scripts/utils.sh

echo "Formatting $(echo "$changed_xml" | wc -l) xml files"
mvn -B -q -Dincludes="$(comma_list "$changed_xml")" xml-format:xml-format
echo "$changed_xml" | tr "\n" "\0" | xargs -0 git add -f
