Vagrant file that starts a master (k1m) and three minion nodes (k1n1, k1n2, k1n3). It runs an etcd server on k1m and installs portworx on k1n1, k1n2, and k1n3 - each of which has 40GB capacity (2 x 20GB drives).

First, you will need to install the disksize vagrant plugin:
```vagrant plugin install vagrant-disksize```

Then you can ```vagrant up``` and enjoy!
