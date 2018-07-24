## This vagrant file will create a single nomad server and 3 clients as well as install consul and Portworx on all 4 nodes
```
vagrant@s1:~$ pxctl status
Status: PX is operational
License: Trial (expires in 31 days)
Node ID: 3ebdd6ad-5800-4a45-961e-1119d2d64f9e
	IP: 192.168.56.70
 	Local Storage Pool: 2 pools
	POOL	IO_PRIORITY	RAID_LEVEL	USABLE	USED	STATUS	ZONE	REGION
	0	HIGH		raid0		15 GiB	3.0 GiB	Online	default	default
	1	HIGH		raid0		20 GiB	3.0 GiB	Online	default	default
	Local Storage Devices: 2 devices
	Device	Path		Media Type		Size		Last-Scan
	0:1	/dev/sdc	STORAGE_MEDIUM_MAGNETIC	15 GiB		24 Jul 18 00:07 UTC
	1:1	/dev/sdd	STORAGE_MEDIUM_MAGNETIC	20 GiB		24 Jul 18 00:07 UTC
	total			-			35 GiB
Cluster Summary
	Cluster ID: NOMAD_PX_CLUSTeR
	Cluster UUID: 6926df51-bb42-4bf8-aaef-18e0e804088f
	Scheduler: none
	Nodes: 4 node(s) with storage (4 online)
	IP		ID					StorageNode	Used	Capacity	Status	StorageStatus	Version		Kernel			OS
	192.168.56.72	aa7283ec-aa79-4122-bf27-d04e02fc4385	Yes		3.0 GiB	35 GiB		Online	Up		1.4.2.0-907a316	4.4.0-119-generic	Ubuntu 16.04.4 LTS
	192.168.56.71	a767fdb5-f877-4c36-9946-cbde4b6b0665	Yes		3.0 GiB	35 GiB		Online	Up		1.4.2.0-907a316	4.4.0-119-generic	Ubuntu 16.04.4 LTS
	192.168.56.73	885885fe-7c4b-4250-ac7e-821a1df9c871	Yes		3.0 GiB	35 GiB		Online	Up		1.4.2.0-907a316	4.4.0-119-generic	Ubuntu 16.04.4 LTS
	192.168.56.70	3ebdd6ad-5800-4a45-961e-1119d2d64f9e	Yes		3.0 GiB	35 GiB		Online	Up (This node)	1.4.2.0-907a316	4.4.0-119-generic	Ubuntu 16.04.4 LTS
Global Storage Pool
	Total Used    	:  12 GiB
	Total Capacity	:  140 GiB
vagrant@s1:~$ nomad node status
ID        DC   Name       Class   Drain  Eligibility  Status
643407d2  dc1  client-a3  <none>  false  eligible     ready
39069381  dc1  client-a2  <none>  false  eligible     ready
00ef16a7  dc1  client-a1  <none>  false  eligible     ready
vagrant@s1:~$ consul members
Node      Address             Status  Type    Build  Protocol  DC   Segment
agent-s1  192.168.56.70:8301  alive   server  1.0.7  2         dc1  <all>
agent-a1  192.168.56.71:8301  alive   client  1.0.7  2         dc1  <default>
agent-a2  192.168.56.72:8301  alive   client  1.0.7  2         dc1  <default>
agent-a3  192.168.56.73:8301  alive   client  1.0.7  2         dc1  <default>
```

You can use the mysql.nomad file to deploy MySql using Portworx as the volume provisioner:
```
vagrant@s1:~$ nomad job run mysql.nomad
==> Monitoring evaluation "e1a924d2"
    Evaluation triggered by job "mysql-server"
    Allocation "5d92114f" created: node "5e1f3886", group "mysql-server"
    Evaluation status changed: "pending" -> "complete"
==> Evaluation "e1a924d2" finished with status "complete"
vagrant@s1:~$ pxctl v l
ID			NAME	SIZE	HA	SHARED	ENCRYPTED	IO_PRIORITY	STATUS					HA-STATE
712387845893602906	mysql	10 GiB	3	no	no		LOW		up - attached on 192.168.56.71		Up
```
You can also see the ui for nomad:
http://192.168.56.70:4646 
