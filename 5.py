import boto3
import json
client = boto3.client('s3')

def lambda_handler(event, context):
    list_bucket = client.list_buckets()
    print(list_bucket['Buckets'][0]['Name'])

'''

Status: Succeeded
Test Event Name: List_test

Response:
null

The area below shows the last 4 KB of the execution log.

Function Logs:
START RequestId: c92559eb-74f8-429d-b5d0-1990197d27bc Version: $LATEST
{'ResponseMetadata': {'RequestId': 'M9DEGK5QF6179KG8', 'HostId': 'kudkz7us3R4FtO9Ws2WaYUERLclPEfPwxMtlggb23x9z0QOPUewf+HmqbLtfDXWEszhsiWVbk2I=', 'HTTPStatusCode': 200, 'HTTPHeaders': {'x-amz-id-2': 'kudkz7us3R4FtO9Ws2WaYUERLclPEfPwxMtlggb23x9z0QOPUewf+HmqbLtfDXWEszhsiWVbk2I=', 'x-amz-request-id': 'M9DEGK5QF6179KG8', 'date': 'Mon, 09 Mar 2026 06:25:22 GMT', 'content-type': 'application/xml', 'transfer-encoding': 'chunked', 'server': 'AmazonS3'}, 'RetryAttempts': 0}, 'Buckets': [{'Name': 'main-bucket-for-complete-devops-project-3', 'CreationDate': datetime.datetime(2026, 3, 2, 10, 27, 40, tzinfo=tzlocal()), 'BucketArn': 'arn:aws:s3:::main-bucket-for-complete-devops-project-3'}], 'Owner': {'ID': 'd79f62a1c32c1519ff981b11d34e94e58d154b7264e3096915a559818583aca0'}}
END RequestId: c92559eb-74f8-429d-b5d0-1990197d27bc
REPORT RequestId: c92559eb-74f8-429d-b5d0-1990197d27bc	Duration: 270.06 ms	Billed Duration: 1091 ms	Memory Size: 128 MB	Max Memory Used: 96 MB	Init Duration: 820.29 ms

Request ID: c92559eb-74f8-429d-b5d0-1990197d27bc


'''