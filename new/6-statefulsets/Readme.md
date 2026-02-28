![When a person authenticates the next stages will be dependent on this stage](image.png)

if there are multiple pods and multiple instances of the same pod with load balancer
![If the first request went to pod-1 and then second request went to pod-2 even though it is authenitiacted the state of it is pod-1](image-1.png)

![So for the above scenario we need to keep the state of the application in a database](image-2.png)

![If we have multiple pods and all are writing to same Persietent volume there can be issue](image-3.png)

![So here we will write VolumeClaimTempletes which will create seperate PVC for each pod which in are created in the same PV](image-4.png)

# Problem -2

![In a Typical Master slave architecture master will handle read and writes and slave will handle all the reads so for efficent and reliable replication master should be up and running first](image-5.png)

![Using Statefulset Master will be started first and all the slaves will continously sync the data from master so to achive this pod should come one by one and data should be copied from previous replica](image-6.png)

But if we use deployment resource to deploy this kind of application all the pods are created parallely if we deploy same application with stateful sets pods are created one by one.

If we have 3 replicas first pod-1 will be created and once the pod-1 is ready then second pod is created and once the second pod is ready then 3rd pod is created.

If the first pod fails to create for any reason second pod will not be craeted also if we delete the statefulset the last pod is deleted first

# Problem-3

Normally all the nodes in cluster should talk to each other for master replication for that we need a stick identity to find each other in the cluster if we use deployment it will come up with different random names.

To acheive this there should be a way to acheive a constant name for all the pods so even if the pod restarts it should get the same name

![so here using this as the anmes will be same the pods will gets it's own persistent volume](image-7.png)

![even if the pod is restarted it will get attached to the same persistent volume](image-8.png)

Also as discussed early Master should handle all the writes and Slaves should be able to sync with the master so if we use service it will talk to any pod for it requirements. So here we will use headless service to talk to the pod

![mong-0 --> Pod name, mongo --> Service name, default --> it is the namespace](image-9.png)

So when we talk uisng dns the service automatically takes the request to the master instaed of slave. To create headless service we will keep clusterIp as None.

headless service are helpful when we don't want to amke any loadbalancing

![alt text](image-10.png)
