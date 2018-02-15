This Vagrantfile creates 3 docker nodes (d1,d2,d3) and starts etcd on d1.

to start the vms:
```vagrant up```

to ssh into d1:
```vagrant ssh d1```

to install px (if you ins):
```
sudo su

latest_stable=$(curl -fsSL 'https://install.portworx.com?type=dock' | awk '/image: / {print $2}')

docker run --entrypoint /runc-entry-point.sh \
    --rm -i --privileged=true \
    -v /opt/pwx:/opt/pwx -v /etc/pwx:/etc/pwx \
    $latest_stable

/opt/pwx/bin/px-runc install -c DOCKER_CLUSTER \
    -k etcd://192.168.56.70:2379 \
    -a -d enp0s8 -m enp0s8

systemctl daemon-reload
systemctl enable portworx
systemctl start portworx
```
