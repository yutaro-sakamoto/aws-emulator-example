#!/usr/bin/env bash
# CDK スタックを AWS Emulator に bootstrap → deploy する
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/emulator-env.sh

npx cdk bootstrap aws://000000000000/us-east-1
npx cdk deploy --require-approval never --outputs-file cdk-outputs.json
