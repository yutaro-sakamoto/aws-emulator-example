# AWS CLI / CDK を AWS Emulator に向けるための環境変数。各スクリプトから source して使う。
#   EMULATOR_PORT: エミュレータのポート (既定 9297)
PORT="${EMULATOR_PORT:-9297}"
EMU_DIR="$HOME/.aws/emulator/$PORT"

export AWS_ENDPOINT_URL="https://127.0.0.1:$PORT"
export AWS_SHARED_CREDENTIALS_FILE="$EMU_DIR/emulator_credentials"
export AWS_CONFIG_FILE="$EMU_DIR/config"
export AWS_CA_BUNDLE="$EMU_DIR/ca.pem"          # AWS CLI 用 (Docker で起動した場合も有効)
export NODE_EXTRA_CA_CERTS="$EMU_DIR/ca.pem"    # CDK CLI (Node.js / AWS SDK for JS v3) 用
export AWS_EC2_METADATA_DISABLED=true
export AWS_REGION=us-east-1
export AWS_DEFAULT_REGION=us-east-1
export AWS_PAGER=""

# 実 AWS の認証情報が使われないように消しておく
unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_PROFILE AWS_DEFAULT_PROFILE \
  AWS_WEB_IDENTITY_TOKEN_FILE AWS_ROLE_ARN AWS_ROLE_SESSION_NAME AWS_CONTAINER_CREDENTIALS_RELATIVE_URI \
  AWS_CONTAINER_CREDENTIALS_FULL_URI AWS_CONTAINER_AUTHORIZATION_TOKEN

# 実 AWS に向いていないことを確認
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
if [ "$ACCOUNT" != "000000000000" ]; then
  echo "Not connected to AWS Emulator (account=$ACCOUNT). Abort." >&2
  exit 1
fi
