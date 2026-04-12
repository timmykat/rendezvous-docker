#!/bin/sh

# An example hook script to verify what is about to be pushed.  Called by "git
# push" after it has checked the remote status, but before anything has been
# pushed.  If this script exits with a non-zero status nothing will be pushed.
#
# This hook is called with the following parameters:
#
# $1 -- Name of the remote to which the push is being done
# $2 -- URL to which the push is being done
#
# If pushing without using a named remote those arguments will be equal.
#
# Information about the commits which are being pushed is supplied as lines to
# the standard input in the form:
#
#   <local ref> <local oid> <remote ref> <remote oid>
#
# This sample shows how to prevent push of commits where the log message starts
# with "WIP" (work in progress).

#!/bin/bash
set -e

# Get current branch name
branch=$(git rev-parse --abbrev-ref HEAD)

# Only allow pushes from main (adjust if needed)

# Ensure we have latest remote refs
git fetch -q

# Count migration files changed vs origin/main
nmig=$(git diff --name-only origin/main...HEAD | grep -c "db/migrate/" || true)

# If migrations exist, ask for confirmation
if [[ "$nmig" -gt 0 ]]; then
  echo "⚠️  This push includes $nmig migration(s):"
  git diff --name-only origin/main...HEAD | grep "db/migrate/" || true
  echo "Continue? (y/n): "
  read query < /dev/tty
  echo

  if [[ ! "$query" =~ ^[yY]$ ]]; then
    echo "🚫 Cancelling push"
    exit 1
  fi
fi

exit 0
