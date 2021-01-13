Title: Self Hosted Kubernetes Part 2 - Provisioning
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 2 - Provisioning

![alt logo](./images/self-hosted-kubernetes/Kubernetes-logo.png)

## Provisioning

### Dependencies

For the cluster that I set up, I had multiple physical machines on a private network that were
running proxmox. This enabled me to quickly create a template VM that had the basics of what
is needed for provisioning. On the machines / VMs that you plan to make your nodes in your cluster,
all you need to have installed is docker. One quick and easy trick that I have picked up in my
time sysadmining is that you can quickly install docker on most distributions with this:

```bash
curl https://get.docker.com/ | sh
sudo systemctl enable docker
sudo systemctl start docker
```

Once you have that installed, a restart may be required.

### Topology

It is at this point at which you need to make some topology decisions for your cluster. Assuming you
have multiple nodes, you should make some decisions about which ones will be "worker" nodes, and which
ones will be "manager" nodes. In addition to this, we will also need to run the rancher UI on one of
the nodes. It is my recommendation that you have at least 1, but no more than 3 manager nodes. You should
be strategical about where you place your manager nodes. In the event that all your manager nodes die,
there will likely be some wonky weird undefined behavior that will be quite bad.

For the cluster that I provisioned, I had two server rooms in different Boroughs of New York City with
nodes in both. All those machines are on a single private network. With this setup, I chose to have manager
nodes in both these locations. All of this was to avoid a single point of failure. In the event that one of
those buildings has some unforeseen downtime, the cluster would still have a manager.

My recommended networking setup would be that you have a private network (VPN or whatnot) that your nodes
can talk to each other on. If you need to externally expose services (further explained in the networking post),
then you should have specific nodes with public IP addresses to handle networking ingress. Again take this
for what it is, a recommendation. If you don't have the ability or time to set up a proper private network,
it is really not the biggest deal in the world.

These are the types of decisions and thought processes you will need to have when designing these types
of high availability systems.

### Rancher

Rolling Kubernetes from scratch is a hellish and annoying process. Vanilla Kube is very plug and play.
This means that it is up to you to configure lots of core features (like the networking layer).

For this, it is my opinion that it is best to use a tool that will do it for you. In my experience
rancher is the easiest and simplest way of provisioning a cluster when you are self hosting. It will
manage and add some of the basic features that you would need to do on your own if you were rolling
kubernetes from scratch (like the networking layer). It also give you an admin panel where you can
monitor and edit resources, and even launch some pre-configured "apps".

Once you have decided where in the cluster the rancher UI should live, run this command on that node.
You should then connect to that node in your browser via port 8443. ( https://<your-node-ip>:8443/ )

```shell
docker run -d --restart=unless-stopped -p 8443:443 rancher/rancher
```

This runs the rancher container on your node. Kubernetes is not currently running on the node.
This is just running the rancher server. You will need to go to the rancher UI, and create an admin
user and a cluster.

When creating the form make sure to disable the private registry, and nginx ingress. We will do those
on our own.

Towards the end of the form, they will give you a docker command to run to add kubelet
to a node. Above the command there will be some checkboxes. Check the etcd and control plane, then
run the command on your manager nodes. You will want to run the command with the etcd and control plane
options on all your manager nodes. You shouldn't run etcd and controlplane on your worker nodes. Ideally
there should be 3 or 5 nodes with control plane and etcd in your cluster. For reference, you command should look something like:

```bash
sudo docker run -d --privileged --restart=unless-stopped --net=host \
  -v /etc/kubernetes:/etc/kubernetes -v /var/run:/var/run rancher/rancher-agent:v2.4.5 \
  --server https://<racher node ip>:8443 --token <token> --ca-checksum <checksum> \
  --etcd --controlplane --worker
```

Etcd and control plane are the core services for the kubernetes api. Running those on a node makes it a manager. For your worker nodes, you will want to run the same command with the etcd and control plane options omitted.

Don't worry about remembering, or even saving that. You can get that command again by clicking "edit" in the rancher UI, then scrolling to the bottom.

The next step is to simply having patience. Provisioning and on-boarding new nodes takes time. Try not to get impatient and cancel the on-boarding process. It may mess up the state on the node, making it difficult to re-onboard the node. Most of my struggles at this stage resulted from my own impatience.

## Post provision

### Setting up Kubectl

The way you will largely be interacting with your cluster is through [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
For this, you will need a Kubernetes configuration file. You can get your kube config file from the rancher UI. If you select your cluster, there should be a button on the top right of the page for viewing the kube config file. Copy the contents of that to `~/.kube/config`. You can test that your kubectl works by seeing if you can view the
nodes in your cluster:

```bash
kubectl get nodes
```

### Rancher

The rancher UI is not super intuitive to navigate. It is my understanding that this is something that changes
enough between versions that I don't think it would be worth explaining some of the more annoying "features".
Just note that the navbar will change depending on what page you are on.
