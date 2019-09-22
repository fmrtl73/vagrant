# Set the AWS region
AWS_DEFAULT_REGION=us-east-1

# Valid distros are 'ubuntu' and 'centos'
distro=ubuntu

# Do not change below this line
vpc=$(aws --output json ec2 create-vpc --cidr-block 192.168.99.0/24 | json Vpc.VpcId)
subnet=$(aws --output json ec2 create-subnet --vpc-id $vpc --cidr-block 192.168.99.0/24 | json Subnet.SubnetId)
gw=$(aws --output json ec2 create-internet-gateway | json InternetGateway.InternetGatewayId)
aws ec2 attach-internet-gateway --vpc-id $vpc --internet-gateway-id $gw
routetable=$(aws --output json ec2 create-route-table --vpc-id $vpc | json RouteTable.RouteTableId)
aws ec2 create-route --route-table-id $routetable --destination-cidr-block 0.0.0.0/0 --gateway-id $gw
aws ec2 associate-route-table  --subnet-id $subnet --route-table-id $routetable
sg=$(aws --output json ec2 create-security-group --group-name SSHAccess --description "Security group for SSH access" --vpc-id $vpc | json GroupId)
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 32678 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 30900 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol tcp --port 30950 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $sg --protocol all --cidr 192.168.99.0/24

case $distro in
  ubuntu)
    ami=$(aws --output json ec2 describe-images --owners 099720109477 --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-* --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text)
  ;;
  centos)
    ami=$(aws --output json ec2 describe-images --owners 679593333241 --filters Name=name,Values='CentOS Linux 7 x86_64 HVM EBS*' Name=architecture,Values=x86_64 Name=root-device-type,Values=ebs --query 'sort_by(Images, &Name)[-1].ImageId' --output text)
  ;;
  *)
    echo Please set DISTRO to a valid value
  ;;
esac

export subnet sg ami distro AWS_DEFAULT_REGION
