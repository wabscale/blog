Title: Self Hosted Kubernetes Part 4 - Persistent Volumes
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 4 - Persistent Volumes

![alt logo](./images/self-hosted-kubernetes/Kubernetes-logo.png)


In your journey into distributed computing, you will find that you often need persistent data. Pods are disposable. You should design your deployments in such a way that a pod can die at any given time, without it affecting availability. One way we do this is persisting data across pods lifecycles. Kubernetes solution to this problem is called Persistent Volumes. They are sometimes refereed to as simply PV's. These are not to be confused with Persistent Volume Claims (PVC). A PVC is generally the resource that you would define in yaml for a deployment. It is the resource that connects a volume to a pod. When a PVC is created, it will create a corresponding PV.

In the Kubernetes ecosystem there are many providers and types of Persistent Volumes. You define the types of PVs that you cluster supports in a StorageClass resource. In that resource, you can also define whatever default values a volume of that type should have (like how many replicas, etc.).

There are many types of StorageClasses. Some, like AWS's Elastic Block Store (EBS), are specific to a cloud provider.

In many occasions you will also find a need to have shared data across many pods. This is when you have multiple pods / container using the same PVC. These are refereed to as multi-mounts. Some StorageClasses support this feature, while some do not. We will need a StorageClass that supports multi mounts later when we are setting up the traefik ingress.


## Persistent Volumes

Most apps you will run will need [persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). At the core of most all distributed systems is efficient sharing of data. One of the most simple ways to do this in Kubernetes is persistent volumes. These allow us to share filesystems between containers. One very important thing to note is that not all storage classes are the same. Storage classes refer to different types of persistent volumes. You may want one type of volume for one service, and a different for another.

The main difference that you will need to decide on a case by case basis is which [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) you need. For the most part, this is going to be a decision between if it will be `ReadWriteOnce` or `ReadWriteMany`. ReadWriteOnce means that the volume will only ever be able to be mounted to one container at a time. ReadWriteMany is where you can mount the volume on multiple containers at once.

I would recommend running [longhorn](https://rancher.com/products/longhorn/) and longhorn-nfs. [Longhorn](https://rancher.com/products/longhorn/) is maintained by Rancher and provides some of the creature comforts of persistent volume solutions on hosted platforms (like EBS). [Longhorn](https://rancher.com/products/longhorn/) provides a pertty web interface where you can manage volumes, setup backup and snapshot schedules, and perform maintenance when necessary. [Longhorn](https://rancher.com/products/longhorn/) only supports ReadWriteOnce, which can be very limiting depending on your application. For my needs, I use longhorn-nfs. With longhorn-nfs, it creates a [longhorn](https://rancher.com/products/longhorn/) volume that is used by a completely separate nfs storage class. This allows us to have a pretty easy to set up storage class that can do multi mounts. Since the underlying volume is just a [longhorn](https://rancher.com/products/longhorn/) volume, we can also setup snapshots, and backups just like any other [longhorn](https://rancher.com/products/longhorn/) volume.
