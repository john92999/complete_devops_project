import boto3
import json

client = boto3.client('ec2')

def lambda_handler(event, context):

    create_instance = client.run_instances(
        ImageId='ami-0f58b397bc5c1f2e8',
        InstanceType='t2.micro',
        MinCount=1,
        MaxCount=1,
        Placement={
            'AvailabilityZone': 'ap-south-1a'
        }
    )

    instance_id = create_instance['Instances'][0]['InstanceId']

    print(instance_id)

    return {
        "statusCode": 200,
        "body": json.dumps(f"EC2 Instance Created: {instance_id}")
    }