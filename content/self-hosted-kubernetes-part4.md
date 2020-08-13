Title: Self Hosted Kubernetes Part 4
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 4 - Persistent Volumes

In your journey into distributed computing, you will find that you often need persistent data. Pods are disposible. You should design your deployments in such a way that a pod can die at any given time, without it affecting availibity. One way we do this is persisting data across pods lifecycles. Kubernetes solution to this problem is called Persistent Volumes. They are sometimes refered to as simply PV's. These are not to be confused with Persistent Volume Claims (PVC). A PVC is generally the resource that you would define in yaml for a deployment. It is the resource that connects a volume to a pod. When a PVC is created, it will create a corresponding PV.

In the Kubernetes ecosystem there are many providers and types of Persistent Volumes. You define the types of PVs that you cluster supports in a StorageClass resource. In that resource, you can also define whatever default values a volume of that type should have (like how many replicas, etc.). 

There are many types of StorageClasses. Some, like AWS's Elastic Block Store (EBS), are specific to a cloud provider.

In many occasions you will also find a need to have shared data across many pods. This is when you have multiple pods / container using the same PVC. These are refered to as multi-mounts. Some StorageClasses support this feature, while some do not. We will need a StorageClass that supports multi mounts later when we are setting up the traefik ingress.


## Persistent Volumes

Most apps you will run will need [persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
I would recomend either nfs-provisioner or longhorn. Both of those have charts
in the rancher catelog. Longhorn is way more powerful, but I noticed that it takes longer to
schedule pods. Longhorn should probably be your default, unless you need quick and temporary volumes
for something, then use nfs-provisioner.

