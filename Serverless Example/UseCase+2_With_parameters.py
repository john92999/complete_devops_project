import boto3
import json
client = boto3.client('s3')

def lambda_handler(event, context):

    bucket = event['bucket']
    key = event['key']

    response = client.get_object(
        Bucket = bucket,
        Key = key
    )

    data_bytes = response['Body'].read()
    data_strings = data_bytes.decode("UTF-8")
    data_dict = json.loads(data_strings)

    return{
        'statusCode' : 200,
        'body': data_dict
    }