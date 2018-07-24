# PWX Rancher Environment

This Vagrant file comes from here: https://github.com/chrisurwin/localranchervagrant

The Vagrant file has been modified to add an extra 30GB block device at `/dev/sdb` to each machine. Make sure you reference this when installing PWX from the rancher catalogue.

Make sure you use `eth1` as the data interface.

The orchestrator has been set to Kubernetes.

---

Vagrant files to stand up a Local Rancher install with 3 nodes

This runs RancherOS as the base OS for the nodes which doesn't have the guest tools for Virtualbox installed

Start the cluster and the Rancher UI will become accessible on http://172.22.101.100

To see the contents of the registry cache proxy, navigate to http://172.22.101.100:5000/v2/_catalog

The default file will bring up a cattle environment. You can change this by editing `orchestrator` in [the config file](config.yaml).

## Usage

clone the directory and then run **vagrant up**

## Config

The config.yml contains any variables that you should need to change, below is a description of the variables and their values:

**orchestrator** - Possible values are `cattle`, `kubernetes`, `mesos` and `swarm` 

This sets the orchestrator that will be used for the environment, as part of the process the Default environment is deleted and we create a new one with the name of the orchestrator. 

**network_mode** - Possible values are `isolated`, `airgap` and `normal`

`isolated` set the Rancher Server and Rancher nodes to have no external internet access other than via a proxy server that runs on the master node. This is used to emulate environments where a proxy server is required to access the internet

`airgap` sets the Rancher Server and nodes to have no external access at all. All images required to stand up Rancher are downloaded to a private repo on master and pulled from there

**sslenabled** - Possible values are `true` and `false`

This uses a pre-generated certificate to terminate the connection to the Rancher server with SSL. This certificate is located in the /certs folder. If this is changed then the public key will need to be replaced in the configure_rancher_node.sh script otherwise the agent will error.

**ssldns** - Default value is `server.rancher.vagrant`

The setting for this needs to match the string that is stored in the SSL certificate that is used for termination.

**version** - Possible values `latest`, `stable`, `v1.x.x` where x.x is any release of Rancher Server

This is the version of Rancher Server that you want to be deployed into your environment

**rancher\_env\_vars** - Pass through additional environment variables to the Rancher server

**agent_version** - The version of the Rancher agent for the nodes to pull

**ROS_version** - The version of RancherOS for the nodes to run, possible values are `1.0.3` and `1.0.4`

**master** - Settings for the master node that runs the proxy, registry mirror etc., this value should not be changed

- **cpus** - Default `1` This is the number of vCPU's that the master node should have

- **memory** - Default `1024` This is the amount of RAM to be allocated to the master node, if running on a machine with only 8GB this should be dropped to `512`

**server** - Settings for the server node(s) that runs the Rancher Server, this value should not be changed

- **count** - Default `1` This is the number of Rancher Servers to run, if you want to test HA then this should be set to `2` or above

- **cpus** - Default `1` This is the number of vCPU's that each server node should have

- **memory** - Default `2048` This is the amount of RAM to be allocated to each server node, if running on a machine with only 8GB this should be dropped to `1024`

**node** - Settings for the rancher node(s) that run in the Rancher environment, this value should not be changed

- **count** - Default `3` This is the number of nodes to run

- **cpus** - Default `1` This is the number of vCPU's that each Rancher node should have

- **memory** - Default `2048` This is the amount of RAM to be allocated to each Rancher node, if running on a machine with only 8GB this should be dropped to `1024`

**ip**  - This section defines the IP address ranges for the virtual machines

- **master** - Default `172.22.101.100`

- **server** - Default `172.22.101.101`

- **node** - Default `172.22.101.111`

**linked_clones** - Default value `true` Leave as this as it reduces disk footprint

**net** - Network Settings section, this should not be changed

- **private\_nic\_type** - Default `82545EM` this sometime needs to be changed to `82540EM` This is the network card that is emulated in the virtual machine

- **network\_type** - Default **private\_network**

If you want to expose the Virtual Machines directly to the network this can be set to **public_network**

**keys** - Subsection for defining keys to be used when enabling *external_ssh*. The public key will be placed onto all servers, the private key will be placed onto just the master node. You can then use the master node as a jump host to each of the remaining VM's, or access them directly with the ssh key

- **public_key** - This should be set to the path of the public key that needs to be uploaded

- **private_key** - This should be set to the path of the private key that needs to be uploaded

**external_access** - To expose the setup to an external network

- **enabled** - Default value `false`, Change to true if you want to expose the master node to an external network`

- **ssh_port** - Default value `2277`, this is the port that the master node will be exposed on if you enabled *external\_ssh*

- **http_port** - set this value to the local port on the host to forward to port 80 on the master

- **https_port** - set this value to the local port on the host to forward to port 443 on the master

## Troubleshooting

**VM's starting but not running any scripts** - Try changing the *private\_nic\_type*
