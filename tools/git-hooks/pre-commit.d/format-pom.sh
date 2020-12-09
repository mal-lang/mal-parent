#!/bin/sh

set -eu

cd "$(dirname "$0")/../../.."

set +e
changed_pom="$(
  git diff --cached --name-only --diff-filter=ACMR |
  grep "^pom\.xml$"
)"
set -e

if [ -z "$changed_pom" ]; then
  exit
fi

# shellcheck source=../../scripts/utils.sh
. tools/scripts/utils.sh

echo "Formatting $(echo "$changed_pom" | wc -l) pom.xml files"
mvn -B -q -Dincludes="$(comma_list "$changed_pom")" xml-format:xml-format tidy:pom
echo "$changed_pom" | tr "\n" "\0" | xargs -0 git add -f
