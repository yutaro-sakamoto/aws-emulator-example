#!/usr/bin/env bash
# デプロイ済みスタックのバケットにファイルをアップロード → ダウンロードし、
# 内容が一致することを確認するテスト。不一致なら終了コード 1。
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/emulator-env.sh

STACK="${STACK_NAME:-CdkS3Stack}"
KEY="test/hello-$(date +%s).txt"

# CloudFormation の出力からバケット名を取得
BUCKET=$(aws cloudformation describe-stacks --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" --output text)
if [ -z "$BUCKET" ] || [ "$BUCKET" = "None" ]; then
  echo "BucketName output not found in stack $STACK" >&2
  exit 1
fi
echo "== Bucket: $BUCKET"

# 作業用ディレクトリとアップロードしたオブジェクトは終了時に片付ける
# (オブジェクトが残っていると cdk destroy でバケットを削除できない)
WORKDIR=$(mktemp -d)
cleanup() {
  aws s3 rm --only-show-errors "s3://$BUCKET/$KEY" || true
  rm -rf "$WORKDIR"
}
trap cleanup EXIT

# 1. ローカルファイルを用意
SRC="$WORKDIR/upload.txt"
cat > "$SRC" <<TXT
Hello from AWS Emulator (CDK)!
Created at: $(date '+%Y-%m-%d %H:%M:%S')
TXT
echo "== Local file:"
cat "$SRC"

# 2. アップロード
echo "== Upload: s3://$BUCKET/$KEY"
aws s3 cp --only-show-errors "$SRC" "s3://$BUCKET/$KEY"
aws s3 ls "s3://$BUCKET/test/"

# 3. ダウンロードして内容を表示
DST="$WORKDIR/download.txt"
echo "== Download: s3://$BUCKET/$KEY"
aws s3 cp --only-show-errors "s3://$BUCKET/$KEY" "$DST"
echo "== Downloaded content:"
cat "$DST"

# 4. 内容を比較
if cmp -s "$SRC" "$DST"; then
  echo "== OK: downloaded content matches"
else
  echo "== NG: downloaded content differs" >&2
  diff "$SRC" "$DST" >&2 || true
  exit 1
fi
