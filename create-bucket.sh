#!/usr/bin/env bash
# AWS Emulator 上に S3 バケットを作成し、ローカルファイルをアップロード →
# ダウンロードして内容を表示するサンプル
set -euo pipefail

PORT="${EMULATOR_PORT:-9297}"
. "$HOME/.aws/emulator/${PORT}.env"

# 実 AWS に向いていないことを確認
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$ACCOUNT" != "000000000000" ]; then
  echo "Not connected to AWS Emulator (account=$ACCOUNT). Abort." >&2
  exit 1
fi

BUCKET="${1:-sample-bucket}"
KEY="${2:-hello.txt}"

# 作業用の一時ディレクトリ (終了時に削除)
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# 1. アップロードするローカルファイルを用意
SRC="$WORKDIR/upload.txt"
cat > "$SRC" <<EOF
Hello from AWS Emulator!
Created at: $(date '+%Y-%m-%d %H:%M:%S')
EOF
echo "== Local file: $SRC"
cat "$SRC"

# 2. バケット作成 (既に存在する場合はスキップ)
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "== Bucket already exists: $BUCKET"
else
  echo "== Create bucket: $BUCKET"
  aws s3api create-bucket --bucket "$BUCKET" >/dev/null
fi

# 3. アップロード
echo "== Upload: $SRC -> s3://$BUCKET/$KEY"
aws s3 cp --only-show-errors "$SRC" "s3://$BUCKET/$KEY"

# 4. バケット内のオブジェクト一覧
echo "== Objects in s3://$BUCKET"
aws s3 ls "s3://$BUCKET/"

# 5. ダウンロード
DST="$WORKDIR/download.txt"
echo "== Download: s3://$BUCKET/$KEY -> $DST"
aws s3 cp --only-show-errors "s3://$BUCKET/$KEY" "$DST"

# 6. ダウンロードしたファイルの内容を表示
echo "== Downloaded content:"
cat "$DST"
