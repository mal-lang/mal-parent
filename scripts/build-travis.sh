#!/bin/sh

set -e

expected_os="linux"
expected_dist="focal"
expected_jdk="openjdk11"
expected_slug="mal-lang/mal-parent"
expected_branch="master"

#
# Verify that branch should be built
#

if [ "$TRAVIS_BRANCH" = "gh-pages" ]; then
  echo "Skipping build and deploy, current branch is \"$TRAVIS_BRANCH\""
  exit 0
fi

#
# Build
#

mvn -B clean install site

#
# Verify that build should be deployed
#

if [ "$TRAVIS_OS_NAME" != "$expected_os" ]; then
  echo "Skipping deploy, current os \"$TRAVIS_OS_NAME\" != \"$expected_os\""
  exit 0
fi

if [ "$TRAVIS_DIST" != "$expected_dist" ]; then
  echo "Skipping deploy, current dist \"$TRAVIS_DIST\" != \"$expected_dist\""
  exit 0
fi

if [ "$TRAVIS_JDK_VERSION" != "$expected_jdk" ]; then
  echo "Skipping deploy, current jdk \"$TRAVIS_JDK_VERSION\" != \"$expected_jdk\""
  exit 0
fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
  echo "Skipping deploy, pull request"
  exit 0
fi

if [ "$TRAVIS_REPO_SLUG" != "$expected_slug" ]; then
  echo "Skipping deploy, current slug \"$TRAVIS_REPO_SLUG\" != \"$expected_slug\""
  exit 0
fi

if [ "$TRAVIS_BRANCH" != "$expected_branch" ]; then
  echo "Skipping deploy, current branch \"$TRAVIS_BRANCH\" != \"$expected_branch\""
  exit 0
fi

#
# Verify environment variables for deploy
#

if [ -z "$GITHUB_TOKEN" ]; then
  >&2 echo "Error: \$GITHUB_TOKEN is not set"
  exit 1
fi

if [ -z "$GPG_SECRET_KEY" ]; then
  >&2 echo "Error: \$GPG_SECRET_KEY is not set"
  exit 1
fi

if [ -z "$GPG_EXECUTABLE" ]; then
  >&2 echo "Error: \$GPG_KEYNAME is not set"
  exit 1
fi

if [ -z "$GPG_KEYNAME" ]; then
  >&2 echo "Error: \$GPG_KEYNAME is not set"
  exit 1
fi

if [ -z "$GPG_PASSPHRASE" ]; then
  >&2 echo "Error: \$GPG_PASSPHRASE is not set"
  exit 1
fi

if [ -z "$OSSRH_USERNAME" ]; then
  >&2 echo "Error: \$OSSRH_USERNAME is not set"
  exit 1
fi

if [ -z "$OSSRH_PASSWORD" ]; then
  >&2 echo "Error: \$OSSRH_USERNAME is not set"
  exit 1
fi

#
# Deploy
#

sudo apt-get -y update
sudo apt-get -y install expect xqilla

GPG_TTY=$(tty)
export GPG_TTY

# Import GPG key
echo "$GPG_SECRET_KEY" |
base64 --decode 2>/dev/null |
"$GPG_EXECUTABLE" --import --batch >/dev/null 2>&1

# Trust GPG key
"scripts/set-trust.exp" "$GPG_KEYNAME"

# Deploy
mvn -B -s "scripts/settings.xml" clean deploy site -Pdeploy

version="$(echo "/*:project/*:version/text()" | xqilla -i "pom.xml" "/dev/stdin")"

# Skip release and site for snapshot
if echo "$version" | grep -- "-SNAPSHOT$" >/dev/null 2>&1; then
  echo "Skipping release and site for snapshot"
  exit 0
fi

# Release
mvn -B -s "scripts/settings.xml" nexus-staging:release

# Site
cp -fpR "target/site" "site"
