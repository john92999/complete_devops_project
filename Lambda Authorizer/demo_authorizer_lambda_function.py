def lambda_handler(event, context):
    
    #1 Log the event
    print('The event data is below')
    print(event)

    authorization = 'Deny'

    #2 Validate the  token
    if event['authorizationtoken'] == '123456':
        authorization = 'Allow'
    else:
        authorization = 'Deny'
    
#3 . Generate the IAM Policy

    authorizationpolicy = {"principalId": "johnpolicy","policyDocument": {"Version": "2012-10-17","Statement": [{"Action": "execute-api:Invoke","Effect": authorization,"Resource": ["arn:aws:execute-api:ap-south-1:730335252201:ajtgpzesli/*/GET/students"]}]}}
    
    return authorizationpolicy
