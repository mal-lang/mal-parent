#!/bin/sh

set -e

cd "$(dirname "$0")/.."

if [ $# -eq 0 ]; then
  set +e
  xml_files="$(
    git ls-tree -r --name-only --full-name --full-tree HEAD |
    grep "\.xml$" |
    grep -v "^pom\.xml$"
  )"
  set -e
  if [ -z "$xml_files" ]; then
    exit
  fi
  xml_files_head="$(echo "$xml_files" | head -n 1)"
  xml_files_tail="$(echo "$xml_files" | tail -n +2)"
  xml_files="$xml_files_head"
  if [ -n "$xml_files_tail" ]; then
    xml_files="$xml_files$(
      echo "$xml_files_tail" |
      tr "\n" "\0" |
      xargs -0 printf ",%s"
    )"
  fi
  unset xml_files_head
  unset xml_files_tail
else
  xml_files="$1"
  shift
  if [ $# -ne 0 ]; then
    xml_files="$xml_files$(printf ",%s" "$@")"
  fi
fi

echo "Formatting xml"
mvn -B -q -Dincludes="$xml_files" xml-format:xml-format
