Title: Self Hosted Kubernetes Part 3 - Monitoring
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 3 - Monitoring

![alt logo](./images/self-hosted-kubernetes/Kubernetes-logo.png)

## Monitoring

### Rancher
Rancher has some level of built in monitoring. You can see in the on your cluster page some wheels showing
basic metrics like CPU and RAM usage across your cluster. If you want more in depth monitoring from
rancher, you can enable their dashboard. On rancher 2.4.6 (what I'm currently running) there is a big
`try dashboar` button in the top right corner of the cluster page. This will set up grafana to monitor
your resources. Some of the grafana metrics will then be integrated into the rancher cluster page.

### Kube Dashboard
The rancher UI with grafana is pretty good, but they dont always cover everything.
The primary advantage of the kubernetes-dashboard over rancher and grafana is that kube dashboard will
show you everything. You will be able to see any and all resources that are on the cluster, and
they will be refered to by what kube calls them. This naming consistency and completeness in what
is displayed to you makes it my prefered dashboard while I'm working on a cluster.

The deployment of the kube dashboard deserves a bit of explaination. You will need to create a service
account and add some "roll binding" to the account. for the dashboard, along with the dashboard itself.
The dashboard deployment yaml is pulled from the github release page of the
[dashboard repo](https://github.com/kubernetes/dashboard/releases).

All the configuration you should need to create the kube dashboard is [here](/files/self-hosted-kubernetes/kubernetes-dashboard/).
There is a deploy script in that directory. Once that is up and running, it will not be publically exposed.

#### Port forwarding
You have multiple options for how you can access the dashboard. The recommended way is to do a port forward
through kubectl. That is where you map a port on your local machine to a service on your cluster. In our case,
we would want to map, say port 8443, on our local machine to 443 on the kubernetes dashboard service.
You can then access the dashboard at [](https://localhost:8443).

```bash
kubectl port-forward service/kubernetes-dashboard 8443:443 -n kubernetes-dashboard
```

#### NodePort
The option that I found to be more convenient was exposing the service as a
[NodePort](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport). This solution only
works for me because of the topology of the network of my cluster. Since I have an internal network, and
an external firewall, I can get onto the internal VPN and connect to the kube dashboard securely. You can
easily change the kubernetes dashboard to a NodePort by running:

```bash
kubectl edit service/kubernetes-dashboard -n kubernetes-dashboard
```

Then go down to the spec of the service and replace `type: ClusterIP` with `type: NodePort`. Saving the
file should apply the change. If you chose this option, I would recommend that you do a quick port scan from an
external computer to verify that the dashboard wasn't accidentially exposed.

#### Authenticating
When you get to the dashboard, you will need to either authenticate with either a kube config file, or a token.
If you want to authenticate with a token, you can run this command to get it:

```shell
kubectl -n kubernetes-dashboard describe secret admin-user-token | grep ^token
```

The other, potenially easier and faster solution is to just give it your kube config file you got earlier. It should
be saved at `~/.kube/config`.

#### Customization
The settings page in the kubernetes dashboard is certainly worth a visit. You can edit how many resources will apear
in a list. I would recomend increasing this from the default 10 items. There is also a dark them option in that menu
that your retnas will greatly appreciate.
