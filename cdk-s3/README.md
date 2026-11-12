# cdk-s3

S3 バケットを 1 つ作成する CDK (TypeScript) プロジェクトを、AWS Emulator にデプロイするサンプル。

## 前提

- AWS Emulator が起動していること (既定ポート 9297。別ポートは `EMULATOR_PORT=<port>` で指定)
- Node.js 22 / AWS CLI v2

## 使い方

```bash
npm ci
npm run build && npm test             # 型チェックとユニットテスト

./scripts/deploy.sh                   # cdk bootstrap + cdk deploy (エミュレータ向け)
./scripts/test-upload-download.sh     # バケットへアップロード → ダウンロードして内容を比較
./scripts/destroy.sh                  # cdk destroy
```

`scripts/emulator-env.sh` は、AWS CLI と CDK CLI をエミュレータに向ける環境変数を設定します。
このとき、アカウントが `000000000000` であることを確認し、実 AWS には接続しないようにしています。

## CI

`.github/workflows/cdk-s3.yml` は以下を順に実行します。

1. 最新の AWS Emulator をインストールし、テレメトリを無効にして起動する
2. ビルドとユニットテストを実行する
3. deploy、アップロード/ダウンロードテスト、destroy を実行する
