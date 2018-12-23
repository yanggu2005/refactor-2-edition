#!/usr/bin/env bash

# find out Added/Copied/Modified/Renamed/C(T)hanged markdown files
committingMarkdowns=$(git diff HEAD --name-only --diff-filter=ACMRT -- '*.md')

if [[ -n "$committingMarkdowns" ]]; then
  # 正文中英文词的前后不应该加空格
  # 找到合适的prettier选项之前暂时注释掉
  # prettier --write ${committingMarkdowns} --loglevel silent
  git add ${committingMarkdowns}
fi
