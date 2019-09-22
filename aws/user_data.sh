#!/bin/bash
useradd -m -s /bin/bash vagrant
mkdir /home/vagrant/.ssh
curl http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key >/home/vagrant/.ssh/authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
echo "%vagrant ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/vagrant
