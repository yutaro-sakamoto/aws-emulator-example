#!/usr/bin/env bash
# デプロイした CDK スタックを AWS Emulator から削除する
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/emulator-env.sh

npx cdk destroy --force
