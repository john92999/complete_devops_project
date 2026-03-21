import boto3
import json
client = boto3.client('s3')

def lambda_handler(event, context):

    Bucket_name = 'pjwesley7-aws-s3-from-boto3'

    delete_bucket = client.delete_bucket(
        Bucket = Bucket_name
    )

    print(delete_bucket)

    return {
        'statusCode': 200,
        'body': json.dumps(f'bucket {Bucket_name} deleted successfully')
    }

'''
Status: Succeeded
Test Event Name: delete_Test

Response:
{
  "statusCode": 200,
  "body": "\"bucket pjwesley7-aws-s3-from-boto3 deleted successfully\""
}

The area below shows the last 4 KB of the execution log.

Function Logs:
START RequestId: 2db2b3e7-f44d-48c0-94ce-c12df24456dc Version: $LATEST
{'ResponseMetadata': {'RequestId': '82AS1JS53JCBWTA1', 'HostId': 'K2P4JmxfVc367JS7dxXGWCCbpgF/7l5i17MET2tgRXgXku00cUzxmYS0Q6P5+6sUNgmzH9+1dKvSVnXGcwEUoD4mD3CumE7U', 'HTTPStatusCode': 204, 'HTTPHeaders': {'x-amz-id-2': 'K2P4JmxfVc367JS7dxXGWCCbpgF/7l5i17MET2tgRXgXku00cUzxmYS0Q6P5+6sUNgmzH9+1dKvSVnXGcwEUoD4mD3CumE7U', 'x-amz-request-id': '82AS1JS53JCBWTA1', 'date': 'Mon, 09 Mar 2026 06:16:37 GMT', 'server': 'AmazonS3'}, 'RetryAttempts': 0}}
END RequestId: 2db2b3e7-f44d-48c0-94ce-c12df24456dc
REPORT RequestId: 2db2b3e7-f44d-48c0-94ce-c12df24456dc	Duration: 643.56 ms	Billed Duration: 1379 ms	Memory Size: 128 MB	Max Memory Used: 96 MB	Init Duration: 734.79 ms

Request ID: 2db2b3e7-f44d-48c0-94ce-c12df24456dc

'''