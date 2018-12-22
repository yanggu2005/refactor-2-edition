#!/usr/bin/env bash

# find out Added/Copied/Modified/Renamed/C(T)hanged markdown files
committingMarkdowns=$(git diff HEAD --name-only --diff-filter=ACMRT -- '*.md')

if [[ -n "$committingMarkdowns" ]]; then
  prettier --write ${committingMarkdowns} --loglevel silent
  git add ${committingMarkdowns}
fi
