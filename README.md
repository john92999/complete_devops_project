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
_ This is the main element of the policy
_ This can contain or or array of statements

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
