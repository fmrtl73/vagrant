This repository contains a set of Vagrant configurations to help easily get started with Portworx.

The k8s vagrant configuration launches a master and 3 mignions and installs etcd on the master and Portworx on the minions.

The dcos vagrant configuration installs 1 master, 3 private agents, 1 public agent and a boot node. It contains a start-etcd.sh script that should be run on the host machine and used when installing Portworx from the universe.

The docker vagrant configuration just starts 3 nodes with docker installed and etcd running on d1. It leaves the installation of Portworx to be done after the machines are launched and etcd is started.  
