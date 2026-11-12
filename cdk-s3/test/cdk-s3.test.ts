import * as cdk from 'aws-cdk-lib/core';
import { Template } from 'aws-cdk-lib/assertions';
import { CdkS3Stack } from '../lib/cdk-s3-stack';

test('S3 バケットが 1 つ作成される', () => {
  const app = new cdk.App();
  const stack = new CdkS3Stack(app, 'TestStack');
  const template = Template.fromStack(stack);

  template.resourceCountIs('AWS::S3::Bucket', 1);
  template.hasOutput('BucketName', {});
});
