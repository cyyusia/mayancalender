#!/usr/bin/env bash
# docs/ 내용을 gh-pages 브랜치로 배포합니다.
# 작업 트리를 건드리지 않고 임시 인덱스로 트리를 만들어 커밋합니다.
set -euo pipefail
cd "$(dirname "$0")"

git diff --quiet && git diff --cached --quiet || {
  echo "커밋되지 않은 변경이 있습니다. 먼저 커밋하세요." >&2; exit 1; }

git push origin main

GIT_INDEX_FILE=$(mktemp -u)  # 파일이 아닌 경로만 (빈 파일은 git이 거부)
export GIT_INDEX_FILE
trap 'rm -f "$GIT_INDEX_FILE"' EXIT

git read-tree --prefix= main:docs
tree=$(git write-tree)
commit=$(git commit-tree "$tree" -p refs/heads/gh-pages -m "deploy: main의 docs/ 동기화")
git update-ref refs/heads/gh-pages "$commit"
git push origin gh-pages

echo "배포 완료 → https://tzolkinthemayancalendar.com/"
