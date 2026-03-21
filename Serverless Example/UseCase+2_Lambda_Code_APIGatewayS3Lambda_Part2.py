import json
import boto3
client = boto3.client('s3')

def lambda_handler(event, context):
    s3_bucket = client.get_object(
        Bucket = 'main-bucket-for-complete-devops-project-3',
        Key = 'Use+Case+2_Bucket1_Json.json'
    )

    data_bytes = s3_bucket['Body'].read()
    data_strings = data_bytes.decode("UTF-8")
    data_dict = json.loads(data_strings)

    return{
        'statusCode' : 200,
        'body': data_dict 
    }