import * as cdk from 'aws-cdk-lib/core';
import * as s3 from 'aws-cdk-lib/aws-s3';
import { Construct } from 'constructs';

export class CdkS3Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // サンプル用の S3 バケット (名前は CloudFormation が自動生成)
    const bucket = new s3.Bucket(this, 'SampleBucket', {
      // スタック削除時にバケットも削除する (中身が残っていると削除に失敗する)
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // テストスクリプトがバケット名を取得するための出力
    new cdk.CfnOutput(this, 'BucketName', { value: bucket.bucketName });
  }
}
