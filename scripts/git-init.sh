#!/bin/bash

# Check if .git directory exists
if [ -d "/crave-devspaces/Lineage22/.git" ]; then
  echo ".git exists, removing..."
  rm -rf /crave-devspaces/Lineage22
  exit 0
fi

cd /crave-devspaces/Lineage22
git init
git remote add origin https://github.com/accupara/los22.git 2>/dev/null || git remote set-url origin https://github.com/accupara/los22.git
