#!/bin/sh

set -eu

cd "$(dirname "$0")/../.."

mvn \
  versions:display-property-updates \
  versions:display-plugin-updates \
  versions:display-dependency-updates
