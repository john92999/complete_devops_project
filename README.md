IAM has

1. UserGroups --> Groups in which we can add users
2. Users --> Users
3. Roles --> If we want to attach policiy to a service ued we define it in role
4. Policies --> All the policies what can be done and what cannot be done are defined here, here we will define Authorization policy
5. Identity Providers --> If there are other identity proviers like Microsoft Active Directories they will be defined here
6. Account settings --> Settings

Scenario 1: A new employee has joined the team

![alt text](image.png)
![alt text](image-1.png)
![alt text](image-2.png)
![alt text](image-3.png)
![alt text](image-4.png)

Scenario 2 - An application running in ec2 requires permissions to create/delete other AWS resources

![alt text](image-5.png)
In role we need to create trust ploicies, here as ec2 requires it we give the trust policy to ec2 if, For Cross account we give it to AWS account
![alt text](image-6.png)
![alt text](image-7.png)
![alt text](image-8.png)
![alt text](image-9.png)
![alt text](image-10.png)
![alt text](image-11.png)
![alt text](image-12.png)

Scenario 3: Consider we have 5 admins who require same set of permissions, so rather that managing policy at user level, we manage it at the group level
![alt text](image-13.png)
![alt text](image-14.png)
![alt text](image-15.png)

IAM Policy --> A policy is an object in AWS thet when associated with an identity or resources defines their permission.
AWS evaluates these policy when an IAM Principal (user or role) makes a request.

```
policy = {
    <version_block>
    <id_block>
    <statement_block>
}

```

```
"Version": ("2008-10-17" | "2012-10-17")
"Id": optional (eg: "Admin_policy" | "x45gwhug-2663-46f1-a904-12bjbj45iw45")

```

Statement:
--> This is the main element of the policy
--> This can contain or or array of statements

```
"Statement": [{...}, {...}]

<statement> = {
    <sid_block?> --> Optional,
    <principal_block?>  --> Optional,
    <effect_block>,
    <action_block>,
    <resources_block>,
    <condition_block>  --> Optional
}

```

Action, Resources and ConditionKeys - https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazons3.html

Activity 1: Lets create an IAM Policy for full access on s3

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "",
            "Action":  "",
            "Resource": ""
        }
    ]
}

```

![alt text](image-16.png)
![alt text](image-17.png)
![alt text](image-18.png)
![alt text](image-19.png)
![alt text](image-20.png)

Now lets create an IAM User with console access
![alt text](image-21.png)
![alt text](image-22.png)
![alt text](image-23.png)
![alt text](image-24.png)

Now login as the qtdevops user in the different browser/incognito mode
![alt text](image-25.png)

Lets try to access anything apart from s3 (ec2)
![alt text](image-26.png)

So except s3 remaining all will be deny

Arn Format
arn:partition:service:region:account-id:resource-type/resource-id

Global Conditional Keys
https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_condition-keys.html

In AWS we have AWS policy generator and Simulator to check if the policies are correct or not

Automating User/Role/Policy Managment

--> There are 2 possible ways of automation
--> By Command line and then enhancing the scripts
--> BY AWS SDK using code from this

Lets create an IAM User with Administrator permissions who will automate the user creation

![alt text](image-27.png)

Now to enable access to the admin after installation of AWS CLI

![alt text](image-28.png)

Verify if the access is working or not. The output will be different to you but the command should not throw an error

![alt text](image-29.png)

AWS IAM Commands - https://docs.aws.amazon.com/cli/latest/reference/iam/

![alt text](image-30.png)

Now lets verify in the console

![alt text](image-31.png)

Now give the password for the ironman user as Avengers@123

We need to create login profile

![alt text](image-32.png)
