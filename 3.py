import json
import boto3
client = boto3.client('s3')

def lambda_handler(event, context):
    create_s3bucket = client.create_bucket(
        Bucket = 'pjwesley7-aws-s3-from-boto3',
        CreateBucketConfiguration = {
            'LocationConstraint': 'ap-south-1'
        }
    )
    print(create_s3bucket)

    return{
        'statusCode': 200,
        'body': json.dumps('Bukcet created Successfully')
    }

'''
Status: Succeeded
Test Event Name: test

Response:
{
  "statusCode": 200,
  "body": "\"Bukcet created Successfully\""
}

The area below shows the last 4 KB of the execution log.

Function Logs:
START RequestId: bea6d482-2ba8-42a5-8ef5-db26ed4599e1 Version: $LATEST
{'ResponseMetadata': {'RequestId': 'X49R3V4ZYYH0SFDT', 'HostId': 'dRxy4YtgnhmUeeFAGa1eucUUs1rvsmZ9YwdtYQxYZOBSjTagjDVGVoIWN+0Si8hPMZru6xngiLk=', 'HTTPStatusCode': 200, 'HTTPHeaders': {'x-amz-id-2': 'dRxy4YtgnhmUeeFAGa1eucUUs1rvsmZ9YwdtYQxYZOBSjTagjDVGVoIWN+0Si8hPMZru6xngiLk=', 'x-amz-request-id': 'X49R3V4ZYYH0SFDT', 'date': 'Mon, 09 Mar 2026 05:58:28 GMT', 'location': 'http://pjwesley7-aws-s3-from-boto3.s3.amazonaws.com/', 'x-amz-bucket-arn': 'arn:aws:s3:::pjwesley7-aws-s3-from-boto3', 'content-length': '0', 'server': 'AmazonS3'}, 'RetryAttempts': 0}, 'Location': 'http://pjwesley7-aws-s3-from-boto3.s3.amazonaws.com/', 'BucketArn': 'arn:aws:s3:::pjwesley7-aws-s3-from-boto3'}
END RequestId: bea6d482-2ba8-42a5-8ef5-db26ed4599e1
REPORT RequestId: bea6d482-2ba8-42a5-8ef5-db26ed4599e1	Duration: 1130.87 ms	Billed Duration: 1683 ms	Memory Size: 128 MB	Max Memory Used: 95 MB	Init Duration: 551.88 ms

Request ID: bea6d482-2ba8-42a5-8ef5-db26ed4599e1


'''