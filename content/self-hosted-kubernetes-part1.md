Title: Self Hosted Kubernetes Part 1 - Overview
Date: 2020-08-07
Category: Kubernetes

# A comprehensive guide to Self Hosted Kubernetes Part 1 - Overview

In this multi part series I'm going to take you through, step by step how to set up a fully self
hosted Kubernetes cluster. There will be some expectations of prior knowledge in general docker
skills, and some Kubernetes terms. I'll try to link to the Kubernetes docs when those terms
come up.

## Overview

- [Provisioning](/self-hosted-kubernetes-part-2-provisioning.html)
    - Topology
    - Rancher
- [Monitoring](/self-hosted-kubernetes-part-3-monitoring.html)
    - Rancher Monitoring
    - Kubernetes Dashboard
- [Persistent Volumes](/self-hosted-kubernetes-part-4-persistent-volumes.html)
    - Longhorn
    - Longhorn nfs
- Database (mariadb)
    - Setup
    - Backups
- Networking
    - Firewalls
    - Traefik
    - Middlewares
    - Ingress Nodes
    - DNS
- Deployment guide
    - pods
    - deployments
    - services
    - exposing services through traefik ingress
    - locking down services with traefik middlewares
- Example deployment (etherpad)
    - config files
    - create secrets
    - deploy
- Maintenance
    - cordoning node
    - draining node
    - minimizing downtime



## Motivations

The motivation for this series came after I set up a self hosted kube cluster for the OSIRIS lab
at NYU. What I found in this process was that most of the guides and docs where focused on cloud
hosted clusters.

One general complaint I have about the kubernetes ecosystem is that there is little uniform consensus
on what services and tools are standard. What this means is that there is not one agreed upon standard
for how to monitor resources, or how to handle ingress for example.

For more advanced admins, this a really good thing. It created choice and competition with the tools and
systems that admins choose to use. It fosters an ecosystem where tools are constantly evolving and
getting better.

For those starting off in their odyssey in Kubernetes, this lack of consensus in tooling adds a layer of
complication. People new to kube may not know which tool to use. Not all tools are available to all clusters.

What you will find is that there are no two kubernetes clusters that are equal. That means that most guides
that focus on how to set up a single tool may be written to specifically fit a specific cluster on a specific
cloud provider. My hope with this series is to be as general as possible and focus on those that seem to be
largely left out in kubernetes guides and documentation: those that self host.

My last anecdote related to my motivations is that it is my belief that the Kubernetes documentation is
hot garbage. They do an excellent job of explaining some of the more abstract theories that went into how
the built in resources fit together. What it lacks is concise example configurations. What I need as a
more advanced user that knows what most of the features of kubernetes do is example configuration files.
In this, the kubernetes documentation fails. There are some features in which they explain what a feature
does, and what its importance is, but they do not include how to define it in the configuration yaml.
This is quite frustrating. I find myself wasting time just trying to figure out what some feature I know
about is represented as in yaml.

Try not to let my complains discourage you though! Kubernetes is still an immensely powerful and cool tool that
will enable you to add some very cool features to your deployments.
