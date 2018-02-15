ips=( `dcos node --json | jq ' .[]' | jq .id -r` )
for ip in "${ips[@]}"
do
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl stop portworx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo docker rm portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm /etc/systemd/system/portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm /etc/systemd/system/dcos.target.wants/portworx.service -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo systemctl daemon-reload'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rm -rf /etc/pwx'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo rmmod px -f'
        dcos node ssh --mesos-id=${ip} --master-proxy 'sudo wipefs -a /dev/sda123' # Replace with your disk names
done

