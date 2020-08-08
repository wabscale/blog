Title: Self Hosted Kubernetes Part 4
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 4 - Persistent Volumes


## Persistent Volumes

Most apps you will run will need [persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
I would recomend either nfs-provisioner or longhorn. Both of those have charts
in the rancher catelog. Longhorn is way more powerful, but I noticed that it takes longer to
schedule pods. Longhorn should probably be your default, unless you need quick and temporary volumes
for something, then use nfs-provisioner.

