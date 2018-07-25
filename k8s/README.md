Vagrant file that starts a master (k1m) and three minion nodes (k1n1, k1n2, k1n3). It runs an etcd server on k1m and installs portworx on k1n1, k1n2, and k1n3 - each of which has 20GB capacity.

Install the disk-size plugin with `vagrant plugin install vagrant-disksize`

```vagrant up``` and enjoy!
