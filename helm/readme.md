Helm helps you manage kubernetes application - helm chart helps you define install and upgrade even the most complex Kubernetes Application

# problem-1

If we need to deploy a simple spring boot application we need

1. deployment
2. service
3. ingress
4. secret

If it's a complex application we may require many other manifest as well as PV etc. After cretaing the manifest files we will aply using the kubectl apply -f command as the application increasing the complexity of storing and applying them also increases

If we want to package all the manifest files into a single bundle apply as a package with just a single command that's where HELM comes into the picture.

![alt text](image.png)

Just like we install apt for ubuntu, we can install the helm using a single command, In helm terminology the bundle is called as Chart this chart can be installed with just a single command

Therefore helm chart is nothing but a packaged version of our application manifest files.

![alt text](image-1.png)

# Problem-2

let's say our spring boot application depends on MongoDB. deploying this spring boot onto a cluster we need Mongo DB first and then the Spring Boot Application

Application dependencies can be easily handled in helm. In this we simply sam that our springboot application dependent on MongoDB.

# Problem-3

With plain manifest we can't deploy the same manifest as it is in all environment because sometimes mongoDB uri will be hard coded
the mongodb uri will changes from environment to environment.

With helm we can replace the hardcoded values with placeholders and we can pass the values to these placeholders from external files using values.yaml

![alt text](image-2.png)

for QA it can be different, Prod the value we can change

# problem-4

Let's say we deploy an application with plain kubernetes resources and let's call it v1, then we made some updates and applied the resources v2. butthis time when we verify the application there is some error to amke it work we need to rollback to the previous version.

Some resources like secrets donot support direct rolebacks with Kubectl

But when we install the same application with helm, Helm creates a release and stores it in the form of a kubernets secret and when we update it creates a revision for the release. With this we can rollback to previous version with a single command.

![alt text](image-3.png)

Also with helm we can package our application and share it with teams

# Architecure of helm

Helm is a command line tool when we do operation with helm cli behind the scene it uses it's library to create the manifest files and then intercat with the kubernets and handle application deployment, Rollout, Rollback smoothly

As needed it downloads the charts from ArtifactHub which is a chart repository

As it interacts with Kube-API-Server it requires a connection to the kubernetes cluster
helm use the same configuration used by ~./kube/config unless specifically specified.

Note: helm is installed outside the kubernetes cluster and not inside

https://github.com/pelthepu/todo-api

https://github.com/pelthepu/helm/tree/main/todo-api
