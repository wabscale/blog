Title: Self Hosted Kubernetes Part 4
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 4 - Persistent Volumes

In your journey into distributed computing, you will find that you often need persistent data. Pods are disposible. You should design your deployments in such a way that a pod can die at any given time, without it affecting availibity. One way we do this is persisting data across pods lifecycles. Kubernetes solution to this problem is called Persistent Volumes. They are sometimes refered to as simply PV's. These are not to be confused with Persistent Volume Claims (PVC). A PVC is generally the resource that you would define in yaml for a deployment. It is the resource that connects a volume to a pod. When a PVC is created, it will create a corresponding PV.

In the Kubernetes ecosystem there are many providers and types of Persistent Volumes. You define the types of PVs that you cluster supports in a StorageClass resource. In that resource, you can also define whatever default values a volume of that type should have (like how many replicas, etc.). 

There are many types of StorageClasses. Some, like AWS's Elastic Block Store (EBS), are specific to a cloud provider.

In many occasions you will also find a need to have shared data across many pods. This is when you have multiple pods / container using the same PVC. These are refered to as multi-mounts. Some StorageClasses support this feature, while some do not. We will need a StorageClass that supports multi mounts later when we are setting up the traefik ingress.


## Persistent Volumes

I would recomend using both [nfs-provisioner](https://github.com/rancher/charts/tree/master/proposed/nfs-provisioner/v0.3.0) and [longhorn](https://longhorn.io/). Both of those have charts in the rancher catelog. Longhorn is way more powerful, but I noticed that it takes longer to provision PVs than I would like. Longhorn is maintained by Rancher, so you can expect good support for it. On the other hand, the nfs-provisioner is not being actively maintained. Dispite this, it seems like a lot of people are using it for quick and dirty PVs. 

### Longhorn

Longhorn is a super powerful StorageClass that is totally inclusive to your cluster. What I mean by that is that Longhorn has all the features of a cloud storge class but it will exist fully within your cluster. This has some advantages, and some disadvantages. On the one hand Longhorn is perfect for getting a cloud like StorageClass when your self hosting. On the other hand, your data is still dependent on your clusters stability. If your cluster becomes unrecoverably corrupted or broken, you may not be able to recover the data you had in longhorn. This is why you should schedule _external_ backups of all your critical data.

Longhorn does have a pretty nice UI where you can manage your PVs. You can schedule snapshots and backups of volumes. 

TODO: fillin longhorn ui image

You can either install Longhorn via the Rancher UI, or just through helm. Installing via helm is significantly simpler. All you need to do is add the longhorn helm repo and install it with your options.

```bash
# Add and update repo
helm repo add longhorn https://charts.longhorn.io
helm repo update

# Install via helm 3
kubectl create namespace longhorn-system
helm install longhorn longhorn/longhorn --namespace longhorn-system
```

Once this is deployed, you can verify it created a StorageClass with:

```bash
kubectl get sc --all-namespaces
```

### nfs-provisioner

Network file system has been around forever. Its not particularly efficent, nor does it have lots of powerful features but it does have one thing: it works. The nfs-provisioner project was a part of proposal to be merged into kubernetes as a default StorageClass. I think this was a great proposal that should have been merged. It is irritating that Kube does not come with a basic StorageClass.

Despite is deprication, it is availible from the Rancher library catelog to be installed. For now at least, Rancher is maintaining it. You can either install nfs-provisioner from the rancher library catelog, or you can helm install it from source.

This provisioner runs only in a [Stateful Set](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) which does not have persisted storage across reboots by default. You can easily add this persistents (given that ou have already installed longhorn). With the rancher UI you can enable persistence and select which Storage Class you would like to back your data up with (probably longhorn). I would say adding persistent with longhorn is a must. Longhorn is designed to handle a great deal more failover than nfs, so having your nfs volumes backed up by rancher should give peace of mind.

If you would like to helm install, you can run (given you've downloaded [it](/files/self-hosted-kubernetes/nfs-provisioner.tgz))

```bash
# Install with helm 3
kubectl create namespace nfs-provisioner
helm install ./nfs-provisioner \
  --namespace nfs-provisioner \
  --values 'persistence.enabled=true,persistence.storageClassName=longhorn,persistence.size=8Gi'

# You may want to edit these values to fit your needs
# Specifically, having the underlying longhorn volume be 8GB may be limiting for your needs
```


## Recommendations

I would recommend that you make nfs-provisioner your default storage class. It is faster than longhorn. If you have a critical serice (like a database) then you can and should manually specify longhorn as a PVCs storage class.

## Mistakes I made (that you should learn from)

Both these storage classes run within your cluster as their own independent services. Kubernetes will not stop you from deleting these services, even if they are actively supporting existing PVs. For this I extend this warning, _delete any existing PVs being used before deleting a service like nfs-provisioner_. Kube will not handle this mistake cleanly. 

I once deleted my nfs-provisioner before deleting the outstanding PVs. It was a bit of a mess to fix. I had to delete the `spec.finalizers` field in the borked PVs, then restart the underling hosts that the pods using the borked PVs existed on. This lead to a non-insignificant amount of downtime (about 1 hour). Obviously that is fully unacceptable. Learn from my mistakes.

