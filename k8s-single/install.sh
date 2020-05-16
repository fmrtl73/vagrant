#!/usr/bin/env bash
usage()
{
cat <<EOEG

Usage: $0 

    --license-password <License server admin user password. Note: Please use at least one special symbol and numeric value> Supported special symbols are: [!@#$%]

Required only with OIDC:
    --oidc <Enable OIDC for PX-Central components>
    --oidc-clientid <OIDC client-id>
    --oidc-secret <OIDC secret>
    --oidc-endpoint <OIDC endpoint>

Required only for cloud deployments:
    --cloud <Mandatory for cloud deployment. Note: Currently supported K8s managed services: EKS, GKE and AKS, Custom k8s clusters on AWS, GCP and Azure>
    --cloudstorage <Provide if you want portworx to provision required disks>
    --aws-access-key <AWS access key required to provision disks>
    --aws-secret-key <AWS secret key required to provision disks>
    --disk-type <Optional: Data disk type>
    --disk-size <Optional: Data disk size>
    --azure-client-secret <Azure client secret>
    --azure-client-id <Azure client ID>
    --azure-tenant-id <Azure tenant id>
    --managed <Managed k8s service cluster type>

Optional:
    --cluster-name <PX-Central Cluster Name>
    --admin-user <Admin user for PX-Central and Grafana>
    --admin-password <Admin user password>
    --admin-email <Admin user email address>
    --kubeconfig <Kubeconfig file>
    --custom-registry <Custom image registry path>
    --image-repo-name <Image repo name>
    --air-gapped <Specify for airgapped environment>
    --image-pull-secret <Image pull secret for custom registry>
    --pxcentral-endpoint <Any one of the master or worker node IP of current k8s cluster>
    --openshift <Provide if deploying PX-Central on openshift platform>
    --mini <PX-Central deployment on mini clusters Minikube|K3s|Microk8s>
    --all <Install all the components of PX-Central stack>
    --px-store <Install Portworx>
    --px-backup <Install PX-Backup>
    --px-metrics-store <Install PX-Metrics store and dashboard view>
    --px-license-server <Install PX-Floating License Server>
    --px-backup-organization <Organization ID for PX-Backup>
    --oidc-user-access-token <Provide OIDC user access token required while adding cluster into backup>
    --pxcentral-namespace <Namespace to deploy PX-Central-Onprem cluster>
    --pks <PX-Central-Onprem deployment on PKS>
    --vsphere-vcenter-endpoint <Vsphere vcenter endpoint>
    --vsphere-vcenter-port <Vsphere vcenter port>
    --vsphere-vcenter-datastore-prefix <Vsphere vcenter datastore prefix>
    --vsphere-vcenter-install-mode <Vsphere vcenter install mode>
    --vsphere-user <Vsphere vcenter user>
    --vsphere-password <Vsphere vcenter password>
    --vsphere-insecure <Vsphere vcenter endpoint insecure>
    --domain <Domain to deploy and expose PX-Central services>
    --ingress-controller <Provision ingress controller>

Examples:
    # Deploy PX-Central without OIDC:
    ./install.sh --license-password 'Adm1n!Ur'

    # Deploy PX-Central with OIDC:
    ./install.sh --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --license-password 'Adm1n!Ur'

    # Deploy PX-Central without OIDC with user input kubeconfig:
    ./install.sh --license-password 'Adm1n!Ur' --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with OIDC, custom registry with user input kubeconfig:
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b  --oidc-endpoint X.X.X.X:Y --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with custom registry:
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central with custom registry with user input kubeconfig:
    ./install.sh  --license-password 'Adm1n!Ur' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central on openshift on onprem
    ./install.sh  --license-password 'Adm1n!Ur' --openshift 

    # Deploy PX-Central on openshift on cloud
    ./install.sh  --license-password 'Adm1n!Ur' --openshift --cloud <aws|gcp|azure> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on cloud with external public IP
    ./install.sh --license-password 'Adm1n!Ur' --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on air-gapped environment
    ./install.sh  --license-password 'Adm1n!Ur' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central on air-gapped environment with oidc
    ./install.sh  --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 87348ca3d-1a73-907db-b2a6-87356538  --oidc-endpoint X.X.X.X:Y --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central on aws without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on aws with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central on aws with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central on gcp without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on gcp with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage

    # Deploy PX-Central on gcp with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --pxcentral-endpoint X.X.X.X --cloudstorage --disk-type pd-standard --disk-size 200

    # Deploy PX-Central on azure without auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on azure with auto disk provision
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>

    # Deploy PX-Central on azure with auto disk provision with different disk type and disk size
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID> --disk-type Standard_LRS --disk-size 200

    # Deploy PX-Central-Onprem with existing disks on EKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on EKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud aws --managed --disk-type gp2 --disk-size 200 --pxcentral-endpoint X.X.X.X --cloudstorage --aws-access-key <AWS_ACCESS_KEY_ID> --aws-secret-key <AWS_SECRET_ACCESS_KEY>

    # Deploy PX-Central-Onprem with existing disks on GKE
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on GKE
    ./install.sh  --license-password 'Adm1n!Ur' --cloud gcp --managed --pxcentral-endpoint X.X.X.X --cloudstorage

    # Deploy PX-Central-Onprem with existing disks on AKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed  --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central-Onprem with auto disk provision on AKS
    ./install.sh  --license-password 'Adm1n!Ur' --cloud azure --managed --pxcentral-endpoint X.X.X.X --cloudstorage --azure-client-secret <AZURE_CLIENT_SECRET> --azure-client-id <AZURE_CLIENT_ID> --azure-tenant-id <AZURE_TENANT_ID>

    # Deploy PX-Central on mini k8s cluster
    ./install.sh --mini

    # Deploy PX-Central on mini k8s cluster with external OIDC
    ./install.sh --mini --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y

    # Deploy PX-Central on mini k8s cluster with PX-Central OIDC
    ./install.sh --mini --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com

    # Deploy PX-Central with selected components
    ./install.sh --px-store --px-metrics-store --px-backup --px-license-server --license-password 'Adm1n!Ur'

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with existing disks for Portworx
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with central OIDC
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with existing disks for Portworx with external OIDC
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with central OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on PKS on vsphere cloud with external OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --cloud vsphere --pks --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --pxcentral-endpoint X.X.X.X

    # Deploy PX-Central on openshift on vsphere cloud with central OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc --admin-user pxadmin --admin-password Password2 --admin-email  pxadmin@portworx.com 

    # Deploy PX-Central on openshift on vsphere cloud with external OIDC with auto disk provision option
    ./install.sh --license-password 'Adm1n!Ur' --cloud vsphere --openshift --cloudstorage --vsphere-vcenter-endpoint <VCENTER_ENDPOINT> --vsphere-vcenter-port <VCENTER_PORT> --vsphere-vcenter-datastore-prefix "Phy-" --vsphere-vcenter-install-mode <INSTALL_MODE> --vsphere-insecure --vsphere-user <VCENTER_USER> --vsphere-password <VCENTER_PASSWORD> --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y  --pxcentral-endpoint X.X.X.X

EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --cluster-name)   shift
                      PXCPXNAME=$1
                      ;;
    --admin-user)     shift
                      ADMINUSER=$1
                      ;;
    --admin-password) shift
                      ADMINPASSWORD=$1
                      ;;
    --admin-email)    shift
                      ADMINEMAIL=$1
                      ;;
    --oidc-clientid)  shift
                      OIDCCLIENTID=$1
                      ;;
    --oidc-secret)    shift
                      OIDCSECRET=$1
                      ;;
    --oidc-endpoint)  shift
                      OIDCENDPOINT=$1
                      ;;
    --license-password) shift
                        LICENSEADMINPASSWORD=$1
                        ;;
    --kubeconfig)     shift
                      KC=$1
                      ;;
    --custom-registry)    shift
                          CUSTOMREGISTRY=$1
                          ;;
    --image-pull-secret)  shift
                          IMAGEPULLSECRET=$1
                          ;;
    --image-repo-name)    shift
                          IMAGEREPONAME=$1
                          ;;
    --pxcentral-endpoint) shift
                          PXCINPUTENDPOINT=$1
                          ;;
    --oidc)
                          PXCOIDCREQUIRED="true"
                          ;;
    --air-gapped)
                          AIRGAPPED="true"
                          ;;
    --openshift)
                          OPENSHIFTCLUSTER="true"
                          ;;
    --cloudstorage)
                          CLOUDSTRORAGE="true"
                          ;;
    --cloud)              shift
                          CLOUDPLATFORM=$1
                          ;;
    --aws-access-key)     shift
                          AWS_ACCESS_KEY_ID=$1
                          ;;
    --aws-secret-key)     shift
                          AWS_SECRET_ACCESS_KEY=$1
                          ;;
    --disk-type)          shift
                          CLOUD_DATA_DISK_TYPE=$1
                          ;;
    --disk-size)          shift
                          CLOUD_DATA_DISK_SIZE=$1
                          ;;
    --azure-client-secret)    shift
                              AZURE_CLIENT_SECRET=$1
                              ;;
    --azure-client-id)        shift
                              AZURE_CLIENT_ID=$1
                              ;;
    --azure-tenant-id)        shift
                              AZURE_TENANT_ID=$1
                              ;;
    --managed)
                              MANAGED_K8S_SERVICE="true"
                              ;;
    --all)
                              PXCENTRAL_INSTALL_ALL_COMPONENTS="true"
                              ;;
    --px-store)
                              PX_STORE="true"
                              ;;
    --px-backup)
                              PX_BACKUP="true"
                              ;;
    --px-metrics-store)
                              PX_METRICS="true"
                              ;;
    --px-license-server)
                              PX_LICENSE_SERVER="true"
                              ;;
    --mini)
                              PXCENTRAL_MINIK8S="true"
                              ;;
    --px-backup-organization) shift
                              PX_BACKUP_ORGANIZATION=$1
                              ;;
    --oidc-user-access-token) shift
                              OIDC_USER_ACCESS_TOKEN=$1
                              ;;
    --pxcentral-namespace)    shift
                              PXCNAMESPACE=$1
                              ;;
    --pks)
                                        PKS_CLUSTER="true"
                                        ;;
    --vsphere-insecure)                 VSPHERE_INSECURE="true"
                                        ;;
    --vsphere-vcenter-endpoint)         shift
                                        VSPHERE_VCENTER=$1
                                        ;;
    --vsphere-vcenter-port)             shift
                                        VSPHERE_VCENTER_PORT=$1
                                        ;;
    --vsphere-vcenter-datastore-prefix) shift
                                        VSPHERE_DATASTORE_PREFIX=$1
                                        ;;
    --vsphere-vcenter-install-mode)     shift
                                        VSPHERE_INSTALL_MODE=$1
                                        ;;
    --vsphere-user)                     shift
                                        VSPHERE_USER=$1
                                        ;;
    --vsphere-password)                 shift
                                        VSPHERE_PASSWORD=$1
                                        ;;
    --domain)                           shift
                                        DOMAIN=$1
                                        ;;
    --ingress-controller)               INGRESS_CONTROLLER_PROVISION="true"
                                        ;;
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=2
LBSERVICETIMEOUT=300
PXCNAMESPACE_DEFAULT="portworx"
PXCDB="/tmp/db.sql"

UATLICENCETYPE="false"
AIRGAPPEDLICENSETYPE="false"
ISOPENSHIFTCLUSTER="false"
OPERATOR_UNSUPPORTED_CLUSTER="false"
ISCLOUDDEPLOYMENT="false"
PXCPROVISIONEDOIDC="false"
CLOUDSTORAGEENABLED="false"
AWS_CLOUD_PLATFORM="false"
AZURE_CLOUD_PLATFORM="false"
GOOGLE_CLOUD_PLATFORM="false"
IBM_CLOUD_PLATFORM="false"

EKS_CLUSTER_TYPE="false"
GKE_CLUSTER_TYPE="false"
AKS_CLUSTER_TYPE="false"

AWS_DISK_TYPE="gp2"
GCP_DISK_TYPE="pd-standard"
AZURE_DISK_TYPE="Premium_LRS"
DEFAULT_DISK_SIZE="150"

PXENDPOINT=""
maxRetry=5

ONPREMOPERATORIMAGE="portworx/pxcentral-onprem-operator:1.0.1"
PXCENTRALAPISERVER="portworx/pxcentral-onprem-api:1.0.1"
PXOPERATORIMAGE="portworx/px-operator:1.3.1"
PXCPRESETUPIMAGE="portworx/pxcentral-onprem-pre-setup:1.0.1"
PXDEVIMAGE="portworx/px-enterprise:2.5.0"
PXCLSLABELSETIMAGE="pwxbuild/pxc-macaddress-config:1.0.1"
PXBACKUPIMAGE="portworx/px-backup:1.0.0"

IMAGEPULLPOLICY="Always"
INGRESS_CHANGE_REQUIRED="false"
PX_BACKUP_ORGANIZATION_DEFAULT="portworx"
PXC_OIDC_CLIENT_ID="pxcentral"
KEYCLOAK_BACKEND_SECRET="pxc-keycloak-postgresql"
KEYCLOAK_BACKEND_PASSWORD="keycloak"
KEYCLOAK_FRONTEND_SECRET="pxc-keycloak-http"
KEYCLOAK_FRONTEND_PASSWORD="Password1"
KEYCLOAK_FRONTEND_USERNAME="pxadmin"
PXC_MODULES_CONFIG="pxc-modules"
PX_SECRET_NAMESPACE="portworx"
PX_BACKUP_SERVICE_ACCOUNT="px-backup-account"
PX_KEYCLOAK_SERVICE_ACCOUNT="px-keycloak-account"
PXC_PX_SERVICE_ACCOUNT="px-account"
PXC_PROMETHEUS_SERVICE_ACCOUNT="px-prometheus-operator"
PXC_OPERATOR_SERVICE_ACCOUNT="pxcentral-onprem-operator"
CLOUD_SECRET_NAME="px-disk-provision-secret"
PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT="pxc-nginx-ingress-serviceaccount"
PXC_LICENSE_SERVER_SERVICE_ACCOUNT="pxc-lsc-service-account"
PXC_PVC_CONTROLLER_SERVICE_ACCOUNT="portworx-pvc-controller-account"
DOMAIN_SETUP_REQUIRED="false"
PUBLIC_ENDPOINT_SETUP_REQUIRED="true"
INGRESS_SETUP_REQUIRED="false"
INGRESS_ENDPOINT=""
BACKUP_OIDC_SECRET_NAME="pxc-backup-secret"
PX_BACKUP_NAMESPACE="px-backup"
BACKUP_OIDC_ADMIN_SECRET_NAME="px-backup-admin-secret"

PX_STORE_DEPLOY="false"
PX_METRICS_DEPLOY="false"
PX_BACKUP_DEPLOY="false"
PX_ETCD_DEPLOY="false"
PX_LICENSE_SERVER_DEPLOY="false"
PX_LOGS_DEPLOY="false"
PX_LIGHTHOUSE_DEPLOY="true"
PX_SINGLE_ETCD_DEPLOY="false"

PXC_UI_EXTERNAL_PORT="31234"
PXC_LIGHTHOUSE_HTTP_PORT="31235"
PXC_LIGHTHOUSE_HTTPS_PORT="31236"
PXC_ETCD_EXTERNAL_CLIENT_PORT="31237"
PXC_METRICS_STORE_PORT="31240"
PXC_KEYCLOAK_HTTP_PORT="31241"
PXC_KEYCLOAK_HTTPS_PORT="31242"
PXCENTRAL_INSTALL_ALL_COMPONENTS="true"
OIDC_USER_AUTH_TOKEN_EXPIARY_DURATION="10d"

VSPHERE_CLUSTER="false"
VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="false"
VSPHERE_PROVIDER="vsphere"

PKS_CLUSTER_ENABLED="false"
PX_DISK_TYPE_DEFAULT="zeroedthick"
PX_DISK_SIZE_DEFAULT="150"
PKS_DISK_PROVISIONED_REQUIRED="false"
OCP_DISK_PROVISIONED_REQUIRED="false"

NODE_AFFINITY_KEY="pxc/enabled"
NODE_AFFINITY_VALUE="false"
STORK_SCHEDULER_REQUIRED="true"
STANDARD_NAMESPACE="kube-system"
CENTRAL_DEPLOYED_PX="false"
CLOUD_STORAGE_ENABLED="false"


start_time=`date +%s`
if [[ ${PXCENTRAL_MINIK8S} && "$PXCENTRAL_MINIK8S" == "true" ]]; then
  PX_BACKUP_DEPLOY="true"
  PX_SINGLE_ETCD_DEPLOY="true"
  PXCENTRAL_INSTALL_ALL_COMPONENTS="false"
  STORK_SCHEDULER_REQUIRED="false"
fi

if [[ "$PXCENTRAL_MINIK8S" == "true" && "$PXCENTRAL_INSTALL_ALL_COMPONENTS" == "true" ]]; then
  echo ""
  echo "ERROR: --mini and --all cannot be given together."
  echo ""
  usage
fi

if [[ ${PX_STORE} || ${PX_BACKUP} || ${PX_METRICS} || ${PX_LICENSE_SERVER} ]]; then
  PXCENTRAL_INSTALL_ALL_COMPONENTS="false"
  if [ -z ${PXCENTRAL_MINIK8S} ]; then
    PXCENTRAL_MINIK8S="false"
  fi
fi

if [ "$PXCENTRAL_INSTALL_ALL_COMPONENTS" == "true" ]; then
  PX_STORE_DEPLOY="true"
  PX_METRICS_DEPLOY="false"
  PX_BACKUP_DEPLOY="true"
  PX_ETCD_DEPLOY="true"
  PX_LICENSE_SERVER_DEPLOY="false"
  CENTRAL_DEPLOYED_PX="true"
fi

if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi

if [ ${PX_STORE} ]; then
  PX_STORE_DEPLOY="true"
  CENTRAL_DEPLOYED_PX="true"
fi
if [ ${PX_BACKUP} ]; then
  PX_BACKUP_DEPLOY="true"
  PX_ETCD_DEPLOY="true"
fi
if [ ${PX_METRICS} ]; then
  PX_METRICS_DEPLOY="true"
fi
if [ ${PX_LICENSE_SERVER} ]; then
  PX_LICENSE_SERVER_DEPLOY="true"
fi

if [[ "$PXCENTRAL_MINIK8S" == "true" && ( "$PX_STORE_DEPLOY" == "true" || "$PX_LICENSE_SERVER_DEPLOY" == "true" || "$PX_METRICS_DEPLOY" == "true" ) ]]; then
  echo ""
  echo "ERROR: On mini k8s cluster px-store and license server cannot be deployed."
  echo ""
  usage
fi

checkKubectlCLI=`which kubectl`
if [[ ${OPENSHIFTCLUSTER} && "$OPENSHIFTCLUSTER" == "true" ]]; then
  checkOC=`which oc`
  if [ -z ${checkOC} ]; then
    echo ""
    echo "ERROR: install script requires 'oc' client utility present on the local machine else run install script from openshift master node."
    echo ""
    exit 1
  fi
elif [ -z ${checkKubectlCLI} ]; then
  echo ""
  echo "ERROR: install script requires 'kubectl' client utility present on the instance where it runs."
  echo ""
  exit 1
fi

echo ""
export dotCount=0
export maxDots=15
function showMessage() {
	msg=$1
	dc=$dotCount
	if [ $dc = 0 ]; then
		i=0
		len=${#msg}
		len=$[$len+$maxDots]	
		b=""
		while [ $i -ne $len ]
		do
			b="$b "
			i=$[$i+1]
		done
		echo -e -n "\r$b"
		dc=1
	else 
		msg="$msg"
		i=0
		while [ $i -ne $dc ]
		do
			msg="$msg."
			i=$[$i+1]
		done
		dc=$[$dc+1]
		if [ $dc = $maxDots ]; then
			dc=0
		fi
	fi
	export dotCount=$dc
	echo -e -n "\r$msg"
}

if [ "${LICENSEADMINPASSWORD}" ]; then
  PX_LICENSE_SERVER_DEPLOY="true"
fi

if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  if [ -z ${LICENSEADMINPASSWORD} ]; then
    echo "ERROR : License server admin password is required"
    echo ""
    usage
    exit 1
  fi
  license_password=`echo -n $LICENSEADMINPASSWORD | grep -E '[0-9]' | grep -E '[a-z]' | grep -E '[A-Z]' | grep -E '[!@#$%]' | grep -v '[)(*&^<>?~|\/.,+_=-]'`
  if [ -z $license_password ]; then
    echo "ERROR: License server password does not meet secure password requirements, Your password must be have at least 1 special symbol, 1 capital letter and 1 numeric value."
    echo ""
    usage
  fi
fi

if [ ${CLOUDPLATFORM} ]; then
  ISCLOUDDEPLOYMENT="true"
fi

if [ ${DOMAIN} ]; then
  DOMAIN_SETUP_REQUIRED="true"
  PUBLIC_ENDPOINT_SETUP_REQUIRED="false"
  INGRESS_SETUP_REQUIRED="false"
  PXC_FRONTEND="px-central-frontend.$DOMAIN"
  PXC_BACKEND="px-central-backend.$DOMAIN"
  PXC_MIDDLEWARE="px-central-middleware.$DOMAIN"
  PXC_GRAFANA="px-central-grafana.$DOMAIN"
  PXC_KEYCLOAK="px-central-keycloak.$DOMAIN"
fi

if [[ "$DOMAIN_SETUP_REQUIRED" == "false" && "$ISCLOUDDEPLOYMENT" == "true" ]]; then
  PUBLIC_ENDPOINT_SETUP_REQUIRED="false"
  INGRESS_SETUP_REQUIRED="true"
fi

pxc_domain="/tmp/pxc_domain.yaml"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: pxc-onprem-central-ingress
  namespace: '$PXCNAMESPACE'
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/app-root: /pxcentral
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
    - host: '$PXC_FRONTEND'
      http:
        paths:
        - backend:
            serviceName: pxc-central-frontend
            servicePort: 80
          path: /
    - host: '$PXC_BACKEND'
      http:
        paths:
        - backend:
            serviceName: pxc-central-backend
            servicePort: 80
          path: /
    - host: '$PXC_MIDDLEWARE'
      http:
        paths:
        - backend:
            serviceName: pxc-central-lh-middleware
            servicePort: 8091
          path: /
    - host: '$PXC_GRAFANA'
      http:
        paths:
        - backend:
            serviceName: pxc-grafana
            servicePort: 3000
          path: /
    - host: '$PXC_KEYCLOAK'
      http:
        paths:
        - backend:
            serviceName: pxc-keycloak-http
            servicePort: 80
          path: /
' > $pxc_domain

pxc_ingress="/tmp/pxc_ingress.yaml"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/app-root: /pxcentral
    nginx.ingress.kubernetes.io/rewrite-target: /$2
  name: pxc-onprem-central-ingress
  namespace: '$PXCNAMESPACE'
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pxc-central-frontend
          servicePort: 80
        path: /pxcentral(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-central-backend
          servicePort: 80
        path: /backend(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-central-lh-middleware
          servicePort: 8091
        path: /lhBackend(/|$)(.*)
  - http:
      paths:
      - backend:
          serviceName: pxc-grafana
          servicePort: 3000
        path: /grafana(/|$)(.*)
' > $pxc_ingress

pxc_keycloak_ingress="/tmp/pxc_keycloak_ingress.yaml"
cat <<< '
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
  name: pxc-onprem-central-keycloak-ingress
  namespace: '$PXCNAMESPACE'
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: pxc-keycloak-http
          servicePort: 80
        path: /keycloak
' > $pxc_keycloak_ingress

if [[ ${PKS_CLUSTER} && "$PKS_CLUSTER" == "true" ]]; then
  PKS_CLUSTER_ENABLED="true"
fi

if [ -z ${VSPHERE_INSECURE} ]; then
  VSPHERE_INSECURE="false"
fi

if [[ "$PKS_CLUSTER" == "true" &&  "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" && "$CLOUDSTRORAGE" == "true" ]]; then
  VSPHERE_CLUSTER="true"
  VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="true"
fi 

if [[ "$OPENSHIFTCLUSTER" == "true" &&  "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" && "$CLOUDSTRORAGE" == "true" ]]; then
  VSPHERE_CLUSTER="true"
  VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED="true"
fi

if [[ "$VSPHERE_CLUSTER" == "true" && "$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED" == "true" ]]; then  
  CLOUD_STORAGE_ENABLED="true"
  if [[ -z ${VSPHERE_USER} || -z ${VSPHERE_PASSWORD} || -z ${VSPHERE_VCENTER} || -z ${VSPHERE_VCENTER_PORT} || -z ${VSPHERE_DATASTORE_PREFIX} || -z "$VSPHERE_INSTALL_MODE" ]]; then
    echo ""
    echo "ERROR: Provide px-central-onprem deployment required details: --vsphere-vcenter-endpoint, --vsphere-vcenter-port, --vsphere-vcenter-datastore-prefix, --vsphere-vcenter-install-mode, --vsphere-user and --vsphere-password"
    echo ""
    usage
  fi
  if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
    CLOUD_DATA_DISK_TYPE=$PX_DISK_TYPE_DEFAULT
  fi

  if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
    CLOUD_DATA_DISK_SIZE=$PX_DISK_SIZE_DEFAULT
  fi
fi

if [ ${PXCOIDCREQUIRED} ]; then
  PXCPROVISIONEDOIDC="true"
  OIDCENABLED="true"
elif [[ ( ! -n ${OIDCCLIENTID} ) &&  ( ! -n ${OIDCSECRET} ) && ( ! -n ${OIDCENDPOINT} ) ]]; then
  OIDCENABLED="false"
else
  OIDCENABLED="true"
  if [ -z $OIDCCLIENTID ]; then
    echo "ERROR: PX-Central OIDC Client ID is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z $OIDCSECRET ]; then
    echo "ERROR: PX-Central OIDC Client Secret is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z $OIDCENDPOINT ]; then
    echo "ERROR: PX-Central OIDC Endpoint is required"
    echo ""
    usage
    exit 1
  fi
  keycloak_endpoint=$OIDCENDPOINT
  auth_substring='/'
  if [[ "$keycloak_endpoint" == *"$auth_substring"* ]]; then
    OIDCENDPOINT=$OIDCENDPOINT
  else
    OIDCENDPOINT="$OIDCENDPOINT/auth"
  fi
fi

if [[ "$OIDCENABLED" == "true" && "$PXCPROVISIONEDOIDC" == "true" ]]; then
  if [ -z ${ADMINUSER} ]; then
    echo "ERROR: OIDC admin user name is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z ${ADMINPASSWORD} ]; then
    echo "ERROR: OIDC admin user password is required"
    echo ""
    usage
    exit 1
  fi

  if [ -z ${ADMINEMAIL} ]; then
    echo "ERROR: OIDC admin user email is required"
    echo ""
    usage
    exit 1
  fi
fi

if [[ "$OIDCENABLED" == "true" && "$PXCPROVISIONEDOIDC" == "false" && "$PX_BACKUP_DEPLOY" == "true" ]]; then
  OIDC_USER_ACCESS_TOKEN=`curl -s --data "grant_type=password&client_id=$OIDCCLIENTID&username=$ADMINUSER&password=$ADMINPASSWORD&token-duration=$OIDC_USER_AUTH_TOKEN_EXPIARY_DURATION" http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token | jq -r ".access_token"`
  if [[ -z ${OIDC_USER_ACCESS_TOKEN} && "$OIDC_USER_ACCESS_TOKEN" == "null" ]]; then
      echo "ERROR: Failed to fetch OIDC user [$ADMINUSER] access token which is required to create organization in PX-Backup"
      echo "Specify with flag : --oidc-user-access-token <OIDC_USER_ACCESS_TOKEN>"
      echo ""
      usage
      exit 1
  fi
fi

if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi

if [[ "$OIDCENABLED" == "false" && "$PXCPROVISIONEDOIDC" == "false" ]]; then
  if [ -z ${ADMINUSER} ]; then
    ADMINUSER="pxadmin"
  fi
  if [ -z ${ADMINPASSWORD} ]; then
    ADMINPASSWORD="Password1"
  fi
  if [ -z ${ADMINEMAIL} ]; then
    ADMINEMAIL="pxadmin@portworx.com"
  fi
fi

if [ -z ${PXCPXNAME} ]; then
    PXCPXNAME="pxcentral-onprem"
fi

if [ -z ${PX_BACKUP_ORGANIZATION} ]; then
  PX_BACKUP_ORGANIZATION=$PX_BACKUP_ORGANIZATION_DEFAULT
fi

# If not provided then reading from environment variables
if [ -z ${AWS_ACCESS_KEY_ID} ]; then
  AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
fi

if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then
  AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
fi

if [ -z ${AZURE_CLIENT_SECRET} ]; then
  AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET
fi

if [ -z ${AZURE_CLIENT_ID} ]; then
  AZURE_CLIENT_ID=$AZURE_CLIENT_ID
fi

if [ -z ${AZURE_TENANT_ID} ]; then
  AZURE_TENANT_ID=$AZURE_TENANT_ID
fi

CUSTOMREGISTRYENABLED=""
if [[ ( ! -n ${CUSTOMREGISTRY} ) &&  ( ! -n ${IMAGEPULLSECRET} ) && ( ! -n ${IMAGEREPONAME} ) ]]; then
  CUSTOMREGISTRYENABLED="false"
else
  CUSTOMREGISTRYENABLED="true"
fi

if [[ ( ${CUSTOMREGISTRYENABLED} = "true" ) && ( -z ${CUSTOMREGISTRY} ) ]]; then
    echo "ERROR: Custom registry url is required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [[ ( $CUSTOMREGISTRYENABLED = "true" ) && ( -z ${IMAGEPULLSECRET} ) ]]; then
    echo "ERROR: Custom registry url and Image pull secret are required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [[ ( $CUSTOMREGISTRYENABLED = "true" ) && ( -z ${IMAGEREPONAME} ) ]]; then
    echo "ERROR: Custom registry url and image repository is required for air-gapped installation."
    echo ""
    usage 
    exit 1
fi

if [ ${AIRGAPPED} ]; then
  if [ "$AIRGAPPED" == "true" ]; then
    AIRGAPPEDLICENSETYPE="true"
    if [[ ( "$CUSTOMREGISTRYENABLED" == "false" ) || ( -z ${CUSTOMREGISTRY} ) || ( -z ${IMAGEPULLSECRET} ) || ( -z ${IMAGEREPONAME} ) ]]; then
      echo "ERROR: Air gapped deployment requires --custom-registry,--image-repo-name and --image-pull-secret"
      echo ""
      usage
      exit 1
    fi
  fi
fi

if [ "$CUSTOMREGISTRYENABLED" == "true" ]; then
  ONPREMOPERATORIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-operator:1.0.1"
  PXCENTRALAPISERVER="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-api:1.0.1"
  PXOPERATORIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-operator:1.3.1 "
  PXCPRESETUPIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxcentral-onprem-pre-setup:1.0.1"
  PXDEVIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-dev:2.4.0"
  PXCLSLABELSETIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/pxc-macaddress-config:1.0.1"
  PXBACKUPIMAGE="$CUSTOMREGISTRY/$IMAGEREPONAME/px-backup:1.0.0-rc1"

  echo "PX-Central-Operator Image: $ONPREMOPERATORIMAGE"
  echo "PX-Central-API-Server Image: $PXCENTRALAPISERVER"
  echo "PX-Central-PX-Operator Image: $PXOPERATORIMAGE"
  echo "PX-Central-Pre-Sertup Image: $PXCPRESETUPIMAGE"
  echo "PX-Central-PX-Dev Image: $PXDEVIMAGE"
  echo "PX-Central-License-LabelSet Image: $PXCLSLABELSETIMAGE"
  echo "PX-Central-PX-Backup Image: $PXCLSLABELSETIMAGE"
  echo ""
fi

echo "Validate and Pre-Install check in progress:"
AWS_PROVIDER="aws"
GOOGLE_PROVIDER="gcp"
AZURE_PROVIDER="azure"
IBM_PROVIDER="ibm"
METRICS_ENDPOINT="pxc-cortex-nginx.$PXCNAMESPACE.svc.cluster.local:80"
AWS_DISK_PROVISIONED_REQUIRED="false"
GCP_DISK_PROVISIONED_REQUIRED="false"
AZURE_DISK_PROVISIONED_REQUIRED="false"
if [ ${CLOUDPLATFORM} ]; then
  ISCLOUDDEPLOYMENT="true"
  if [[ -z "$CLOUDPLATFORM" && "$CLOUDPLATFORM" != "$AWS_PROVIDER" && "$CLOUDPLATFORM" != "$GOOGLE_PROVIDER" && "$CLOUDPLATFORM" != "$AZURE_PROVIDER" && "$CLOUDPLATFORM" != "$VSPHERE_PROVIDER" && "$CLOUDPLATFORM" != "$IBM_PROVIDER" ]]; then
    echo ""
    echo "Warning: PX-Central cloud deployments supports following providers:"
    echo "         aws | gcp | azure | vsphere | ibm"
    exit 1
  fi
  if [[ "$CLOUDPLATFORM" == "$AWS_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
      echo ""
      echo "ERROR: PX-Central deployments on aws cloud with cloudstorage option requires --aws-access-key and --aws-secret-key"
      echo ""
      usage
    fi
    CLOUD_STORAGE_ENABLED="true"
    AWS_CLOUD_PLATFORM="true"
    AWS_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$AWS_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [[ "$CLOUDPLATFORM" == "$GOOGLE_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    CLOUD_STORAGE_ENABLED="true"
    GOOGLE_CLOUD_PLATFORM="true"
    GCP_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$GCP_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [[ "$CLOUDPLATFORM" == "$AZURE_PROVIDER" && ${CLOUDSTRORAGE} ]]; then
    if [[ -z "$AZURE_CLIENT_SECRET" || -z "$AZURE_CLIENT_ID" || -z "$AZURE_TENANT_ID" ]]; then
      echo ""
      echo "ERROR: PX-Central deployments on azure cloud with cloudstorage option requires --azure-client-secret, --azure-client-id and --azure-tenant-id"
      echo ""
      usage
    fi
    CLOUD_STORAGE_ENABLED="true"
    AZURE_CLOUD_PLATFORM="true"
    AZURE_DISK_PROVISIONED_REQUIRED="true"
    if [ -z ${CLOUD_DATA_DISK_TYPE} ]; then
      CLOUD_DATA_DISK_TYPE=$AZURE_DISK_TYPE
    fi
    if [ -z ${CLOUD_DATA_DISK_SIZE} ]; then
      CLOUD_DATA_DISK_SIZE=$DEFAULT_DISK_SIZE
    fi
  elif [ "$CLOUDPLATFORM" == "$IBM_PROVIDER" ]; then
    IBM_CLOUD_PLATFORM="true"
  fi
fi

if [ -f "$KC" ]; then
    echo "Using Kubeconfig: $KC"
else 
    echo "ERROR : Kubeconfig [ $KC ] does not exist"
    usage
fi

checkK8sVersion=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1`
if [ -z $checkK8sVersion ]; then
  echo ""
  echo "ERROR : Invalid kubeconfig, Unable to connect to the server"
  echo ""
  exit 1
fi

kubectl --kubeconfig=$KC create namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC create namespace $PX_BACKUP_NAMESPACE &>/dev/null

echo "Kubernetes cluster version: $checkK8sVersion"
k8sVersion=$checkK8sVersion
k8sVersion111Validate=`echo -n $checkK8sVersion | grep -E '1.11'`
k8sVersion112Validate=`echo -n $checkK8sVersion | grep -E '1.12'`
k8sVersion113Validate=`echo -n $checkK8sVersion | grep -E '1.13'`
k8sVersion114Validate=`echo -n $checkK8sVersion | grep -E '1.14'`
k8sVersion115Validate=`echo -n $checkK8sVersion | grep -E '1.15'`
k8sVersion116Validate=`echo -n $checkK8sVersion | grep -E '1.16'`
k8sVersion117Validate=`echo -n $checkK8sVersion | grep -E '1.17'`
k8sVersion118Validate=`echo -n $checkK8sVersion | grep -E '1.18'`
if [[ -z "$k8sVersion111Validate" && -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" && -z "$k8sVersion118Validate" ]]; then
  echo ""
  echo "Warning: PX-Central supports following versions:"
  echo "         K8s: 1.11.x, 1.12.x, 1.13.x, 1.14.x, 1.15.x, 1.16.x, 1.17.x and 1.18.x"
  echo "         Openshift: 3.11, 4.2 and 4.3"
  echo ""
  exit 1
fi 

if [ -z ${MANAGED_K8S_SERVICE} ]; then
  gke_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "gke" 2>&1 | wc -l 2>&1`
  eks_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "eks" 2>&1 | wc -l 2>&1`
  aks_cluster=`kubectl --kubeconfig=$KC version --short | grep -v "i/o timeout" | awk -Fv '/Server Version: / {print $3}' 2>&1 | grep -i "aks" 2>&1 | wc -l 2>&1`
  if [[ "$gke_cluster" -eq "1" || "$eks_cluster" -eq "1" || "$aks_cluster" -eq "1" ]]; then
    MANAGED_K8S_SERVICE="true"
  fi
fi

if [ ${MANAGED_K8S_SERVICE} ]; then
  if [[ "$CLOUDPLATFORM" == "gcp" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    GKE_CLUSTER_TYPE="true"
  elif [[ "$CLOUDPLATFORM" == "aws" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    EKS_CLUSTER_TYPE="true"
  elif [[ "$CLOUDPLATFORM" == "azure" && "$MANAGED_K8S_SERVICE" == "true" ]]; then
    AKS_CLUSTER_TYPE="true"
  fi
fi

if [[ -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" && -z "$k8sVersion118Validate" ]]; then
  OPERATOR_UNSUPPORTED_CLUSTER="true"
fi

if [[ "$k8sVersion111Validate" || "$k8sVersion112Validate" || "$k8sVersion113Validate" ]]; then
  INGRESS_CHANGE_REQUIRED="true"
fi

if [[ "$k8sVersion112Validate" || "$k8sVersion113Validate" || "$k8sVersion114Validate" || "$k8sVersion115Validate" || "$k8sVersion116Validate" || "$k8sVersion117Validate" || "$k8sVersion118Validate" ]]; then
  OPERATOR_UNSUPPORTED_CLUSTER="false"
fi

if [ "$DOMAIN_SETUP_REQUIRED" = "true" ]; then
  PXCINPUTENDPOINT=$PXC_FRONTEND
fi

if [[ ${PXCINPUTENDPOINT} || "$CLOUDPLATFORM" == "$VSPHERE_PROVIDER" ]]; then
  INGRESS_SETUP_REQUIRED="false"
fi

if [[ "$INGRESS_CONTROLLER_PROVISION" == "true" || "$INGRESS_SETUP_REQUIRED" == "true" ]]; then
  ingress_controller_config="/tmp/ingress_controller.yaml"
cat <<< '
apiVersion: v1
kind: Namespace
metadata:
  name: '$PXCNAMESPACE'
  labels:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
---
# Source: ingress-nginx/templates/controller-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
      - endpoints
      - nodes
      - pods
      - secrets
    verbs:
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - nodes
    verbs:
      - get
  - apiGroups:
      - '\'\''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - events
    verbs:
      - create
      - patch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
---
# Source: ingress-nginx/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/controller-role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - namespaces
    verbs:
      - get
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
      - pods
      - secrets
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - services
    verbs:
      - get
      - list
      - update
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingresses/status
    verbs:
      - update
  - apiGroups:
      - networking.k8s.io   # k8s 1.14+
    resources:
      - ingressclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
    resourceNames:
      - ingress-controller-leader-nginx
    verbs:
      - get
      - update
  - apiGroups:
      - '\'\''
    resources:
      - configmaps
    verbs:
      - create
  - apiGroups:
      - '\'\''
    resources:
      - endpoints
    verbs:
      - create
      - get
      - update
  - apiGroups:
      - '\'\''
    resources:
      - events
    verbs:
      - create
      - patch
---
# Source: ingress-nginx/templates/controller-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx
subjects:
  - kind: ServiceAccount
    name: ingress-nginx
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/controller-service-webhook.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller-admission
  namespace: '$PXCNAMESPACE'
spec:
  type: ClusterIP
  ports:
    - name: https-webhook
      port: 443
      targetPort: webhook
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: '$PXCNAMESPACE'
spec:
  type: LoadBalancer
  externalTrafficPolicy: Local
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: https
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/component: controller
---
# Source: ingress-nginx/templates/controller-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: controller
  name: ingress-nginx-controller
  namespace: '$PXCNAMESPACE'
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
      app.kubernetes.io/instance: ingress-nginx
      app.kubernetes.io/component: controller
  revisionHistoryLimit: 10
  minReadySeconds: 0
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/component: controller
    spec:
      dnsPolicy: ClusterFirst
      containers:
        - name: controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.31.1
          imagePullPolicy: IfNotPresent
          lifecycle:
            preStop:
              exec:
                command:
                  - /wait-shutdown
          args:
            - /nginx-ingress-controller
            - --publish-service='$PXCNAMESPACE'/ingress-nginx-controller
            - --election-id=ingress-controller-leader
            - --ingress-class=nginx
            - --configmap='$PXCNAMESPACE'/ingress-nginx-controller
            - --validating-webhook=:8443
            - --validating-webhook-certificate=/usr/local/certificates/cert
            - --validating-webhook-key=/usr/local/certificates/key
          securityContext:
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE
            runAsUser: 101
            allowPrivilegeEscalation: true
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          livenessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: 10254
              scheme: HTTP
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 1
            successThreshold: 1
            failureThreshold: 3
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - name: https
              containerPort: 443
              protocol: TCP
            - name: webhook
              containerPort: 8443
              protocol: TCP
          volumeMounts:
            - name: webhook-cert
              mountPath: /usr/local/certificates/
              readOnly: true
          resources:
            requests:
              cpu: 100m
              memory: 90Mi
      serviceAccountName: ingress-nginx
      terminationGracePeriodSeconds: 300
      volumes:
        - name: webhook-cert
          secret:
            secretName: ingress-nginx-admission
---
# Source: ingress-nginx/templates/admission-webhooks/validating-webhook.yaml
apiVersion: admissionregistration.k8s.io/v1beta1
kind: ValidatingWebhookConfiguration
metadata:
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  name: ingress-nginx-admission
  namespace: '$PXCNAMESPACE'
webhooks:
  - name: validate.nginx.ingress.kubernetes.io
    rules:
      - apiGroups:
          - extensions
          - networking.k8s.io
        apiVersions:
          - v1beta1
        operations:
          - CREATE
          - UPDATE
        resources:
          - ingresses
    failurePolicy: Fail
    clientConfig:
      service:
        namespace: '$PXCNAMESPACE'
        name: ingress-nginx-controller-admission
        path: /extensions/v1beta1/ingresses
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - admissionregistration.k8s.io
    resources:
      - validatingwebhookconfigurations
    verbs:
      - get
      - update
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-createSecret.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-create
  annotations:
    helm.sh/hook: pre-install,pre-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
spec:
  template:
    metadata:
      name: ingress-nginx-admission-create
      labels:
        helm.sh/chart: ingress-nginx-2.0.2
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.31.1
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: create
          image: jettech/kube-webhook-certgen:v1.2.0
          imagePullPolicy: IfNotPresent
          args:
            - create
            - --host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.'$PXCNAMESPACE'.svc
            - --namespace='$PXCNAMESPACE'
            - --secret-name=ingress-nginx-admission
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ingress-nginx-admission-patch
  annotations:
    helm.sh/hook: post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
spec:
  template:
    metadata:
      name: ingress-nginx-admission-patch
      labels:
        helm.sh/chart: ingress-nginx-2.0.2
        app.kubernetes.io/name: ingress-nginx
        app.kubernetes.io/instance: ingress-nginx
        app.kubernetes.io/version: 0.31.1
        app.kubernetes.io/managed-by: Helm
        app.kubernetes.io/component: admission-webhook
    spec:
      containers:
        - name: patch
          image: jettech/kube-webhook-certgen:v1.2.0
          args:
            - patch
            - --webhook-name=ingress-nginx-admission
            - --namespace='$PXCNAMESPACE'
            - --patch-mutating=false
            - --secret-name=ingress-nginx-admission
            - --patch-failure-policy=Fail
      restartPolicy: OnFailure
      serviceAccountName: ingress-nginx-admission
      securityContext:
        runAsNonRoot: true
        runAsUser: 2000
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups:
      - '\'\''
    resources:
      - secrets
    verbs:
      - get
      - create
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ingress-nginx-admission
subjects:
  - kind: ServiceAccount
    name: ingress-nginx-admission
    namespace: '$PXCNAMESPACE'
---
# Source: ingress-nginx/templates/admission-webhooks/job-patch/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ingress-nginx-admission
  annotations:
    helm.sh/hook: pre-install,pre-upgrade,post-install,post-upgrade
    helm.sh/hook-delete-policy: before-hook-creation,hook-succeeded
  labels:
    helm.sh/chart: ingress-nginx-2.0.2
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/version: 0.31.1
    app.kubernetes.io/managed-by: Helm
    app.kubernetes.io/component: admission-webhook
  namespace: '$PXCNAMESPACE'
---
' > $ingress_controller_config
  kubectl --kubeconfig=$KC apply -f $ingress_controller_config --namespace $PXCNAMESPACE &>/dev/null
  sleep $SLEEPINTERVAL
  ingressControllerCheck="0"
  timecheck=0
  while [ $ingressControllerCheck -ne "1" ]
    do
      ingress_pod=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "ingress-nginx-controller" | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
      if [ "$ingress_pod" -eq "1" ]; then
        ingressControllerCheck="1"
        break
      fi
      showMessage "Waiting for Ingress Nginx Controller to be ready"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: Failed to deploy Ingress Nginx Controller, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
fi

if [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
  kubectl --kubeconfig=$KC apply -f $pxc_ingress --namespace $PXCNAMESPACE &>/dev/null
  kubectl --kubeconfig=$KC apply -f $pxc_keycloak_ingress --namespace $PXCNAMESPACE &>/dev/null
  sleep 10
  ingresscheck="0"
  timecheck=0
  while [ $ingresscheck -ne "1" ]
    do
      ingressHostEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].hostname} 2>&1 | grep -v "error" | grep -v "No resources found" | grep -v "NotFound"`
      ingressIPEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].ip} 2>&1 | grep -v "error" | grep -v "No resources found" | grep -v "NotFound"`
      keycloakIngressHostEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-keycloak-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].hostname} 2>&1 | grep -v "error" | grep -v "No resources found" | grep -v "NotFound"`
      keycloakIngressIPEndpoint=`kubectl --kubeconfig=$KC get ingress pxc-onprem-central-keycloak-ingress --namespace $PXCNAMESPACE -o jsonpath={.status.loadBalancer.ingress[0].ip} 2>&1 | grep -v "error" | grep -v "No resources found" | grep -v "NotFound"`
      if [[ ${ingressHostEndpoint} && ${keycloakIngressHostEndpoint} ]]; then
        ingresscheck="1"
        break
      elif [[ ${ingressIPEndpoint} && ${keycloakIngressIPEndpoint} ]]; then
        ingresscheck="1"
        break
      fi
      showMessage "Waiting for PX-Central-Onprem endpoint"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment failed, failed to get hostname. Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
  if [[ ${ingressHostEndpoint} && ${keycloakIngressHostEndpoint} ]]; then
    PXCINPUTENDPOINT=$ingressHostEndpoint
    OIDCENDPOINT="$keycloakIngressHostEndpoint/keycloak"
  elif [[ ${ingressIPEndpoint} && ${keycloakIngressIPEndpoint} ]]; then
    PXCINPUTENDPOINT=$ingressIPEndpoint
    OIDCENDPOINT="$keycloakIngressIPEndpoint/keycloak"
  fi
  INGRESS_ENDPOINT=$PXCINPUTENDPOINT
  KEYCLOAK_INGRESS_ENDPOINT=$OIDCENDPOINT
  echo "PX-Central-Onprem Endpont: $INGRESS_ENDPOINT"
  echo "PX-Central-Onprem Keycloak Endpont: $KEYCLOAK_INGRESS_ENDPOINT"
fi

if [ -z ${PXCINPUTENDPOINT} ]; then
  PXENDPOINT=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -i "master" | awk '{print $6}' | head -n 1 2>&1`
  if [ -z ${PXENDPOINT} ]; then
    PXENDPOINT=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -v "master" | grep -v "INTERNAL-IP" | awk '{print $6}' | head -n 1 2>&1`
  fi

  if [ -z ${PXENDPOINT} ]; then
    echo "PX-Central endpoint empty."
    echo ""
    usage
    exit 1
  fi
else
  PXENDPOINT=$PXCINPUTENDPOINT
fi
echo "Using PX-Central Endpoint as: $PXENDPOINT"
echo ""

resource_check="false"
USE_EXISTING_PX="false"
PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="false"
nodeCount=`kubectl --kubeconfig=$KC get node  | grep -i ready | awk '{print$1}' | xargs kubectl --kubeconfig=$KC get node  -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints}{"\n"}{end}' | grep -iv noschedule | wc -l 2>&1`
echo "Number of nodes in k8s cluster: $nodeCount"
if [ "$nodeCount" -lt 3 ]; then 
  if [ "$PXCENTRAL_MINIK8S" == "true" ]; then
    PX_SINGLE_ETCD_DEPLOY="true"
    PX_ETCD_DEPLOY="false"
    resource_check="false"
    CENTRAL_DEPLOYED_PX="false"
  else
    echo "PX-Central deployments needs minimum 3 worker nodes. found: $nodeCount"
    exit 1
  fi
else
  affinityNodeCount=`kubectl --kubeconfig=$KC get nodes -l $NODE_AFFINITY_KEY=true 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
  if [ "$affinityNodeCount" -ge 3 ]; then
    PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="true"
  fi
  pxNodeCount=`kubectl --kubeconfig=$KC get pods -lname=portworx --all-namespaces 2>&1 |  grep -v NAME | grep -v "error" | grep -v "No resources found" | wc -l 2>&1`
  if [[ "$pxNodeCount" -ge 3 && "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "false" ]]; then
    if [ "$PX_STORE_DEPLOY" == "true" ]; then
      resource_check="false"
      USE_EXISTING_PX="true"
      CENTRAL_DEPLOYED_PX="false"
    fi
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      PX_ETCD_DEPLOY="true"
      PX_SINGLE_ETCD_DEPLOY="false"
    fi
  fi
fi

if [ "$PXCENTRAL_MINIK8S" == "true" ]; then
  echo "MINI Setup: $PXCENTRAL_MINIK8S, BACKUP: $PX_BACKUP_DEPLOY, PXSTORE: $PX_STORE_DEPLOY, LICENSE: $PX_LICENSE_SERVER_DEPLOY, METRICS: $PX_METRICS_DEPLOY, ETCD CLUSTER: $PX_ETCD_DEPLOY, STANDALONE ETCD: $PX_SINGLE_ETCD_DEPLOY, KEYCLOAK: $PXCPROVISIONEDOIDC"
  echo ""
fi

if [ "$resource_check" == "true" ]; then
  echo "PX-Central cluster resource check:"
  resource_check="/tmp/resource_check.py"
cat > $resource_check <<- "EOF"
import os
import sys
import subprocess

kubeconfig=sys.argv[1]

cpu_check_list=[]
memory_check_list=[]
try:
  cmd = "kubectl --kubeconfig=%s get nodes | grep -v NAME | awk '{print $1}'" % kubeconfig
  output= subprocess.check_output(cmd, shell=True)
  nodes_output = output.decode("utf-8")
  nodes_list = nodes_output.split("\n")
  nodes_count = len(nodes_list)
  for node in nodes_list:
    try:
      cmd = "kubectl --kubeconfig=%s get node %s -o=jsonpath='{.status.capacity.cpu}'" % (kubeconfig, node)
      cpu_output = subprocess.check_output(cmd, shell=True)
      cpu_output = cpu_output.decode("utf-8")
      if cpu_output:
        cpu = int(cpu_output)
        if cpu > 3:
          cpu_check_list.append(True)
        else:
          cpu_check_list.append(False)

      cmd = "kubectl --kubeconfig=%s get node %s -o=jsonpath='{.status.capacity.memory}'" % (kubeconfig, node)
      memory_output = subprocess.check_output(cmd, shell=True)
      memory_output = memory_output.decode("utf-8")
      if memory_output:
        memory = memory_output.split("K")[0]
        memory = int(memory)
        if memory > 7000000:
          memory_check_list.append(True)
        else:
          memory_check_list.append(False)
    except Exception as ex:
      pass
except Exception as ex:
  pass
finally:
  if cpu_check_list == memory_check_list:
    print(True)
  else:
    print(False)
EOF

  if [ -f ${resource_check} ]; then
    status=`python $resource_check $KC`
    if [ ${status} = "True" ]; then
      echo "Resource check passed.."
      echo ""
    else
      echo ""
      echo "Nodes in k8s cluster does not have minimum required  resources..."
      echo "CPU: 4, Memory: 8GB, Drives: 2  needed on each k8s worker node"
      exit 1
    fi
  fi
fi 

openshift_count=`kubectl --kubeconfig=$KC get nodes -o wide 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $8}' | grep -i "OpenShift" | wc -l 2>&1`
if [ "$openshift_count" -gt 0 ]; then
  OPENSHIFTCLUSTER="true"
fi

pxc_store_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.portworx} 2>&1`
pxc_backup_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.backup} 2>&1`
pxc_metrics_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.metrics} 2>&1`
pxc_sso_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.sso} 2>&1`
pxc_minik8s_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.minik8s} 2>&1`

if [[ "$PX_STORE_DEPLOY" == "true" && "$pxc_store_enabled" == "false" ]]; then
  if [[ "$pxc_backup_enabled" == "true" || "$pxc_metrics_enabled" == "true" || "$pxc_sso_enabled" == "true" || "$pxc_minik8s_enabled" == "true" ]]; then
    echo ""
    echo "ERROR: Current PX-Central-Onprem cluster already has components running without px-store, px-store cannot be deployed."
    echo ""
    exit 1
  fi
fi

kubectl --kubeconfig=$KC create namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC create namespace $PX_BACKUP_NAMESPACE &>/dev/null
if [ "$PXCNAMESPACE" != "$PX_SECRET_NAMESPACE" ]; then
  kubectl --kubeconfig=$KC create namespace $PX_SECRET_NAMESPACE &>/dev/null
fi

if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
  kubectl --kubeconfig=$KC apply -f $pxc_domain --namespace $PXCNAMESPACE &>/dev/null
fi

if [ "$CLOUD_STORAGE_ENABLED" == "true" ]; then
  if [[ "$AWS_CLOUD_PLATFORM" == "true" || "$AZURE_CLOUD_PLATFORM" == "true" ]]; then
    echo "Cloud platform: $CLOUDPLATFORM, Managed k8s service: $MANAGED_K8S_SERVICE, Disk type: $CLOUD_DATA_DISK_TYPE, Disk size: $CLOUD_DATA_DISK_SIZE"
    echo ""
  fi
  if [ "$AWS_CLOUD_PLATFORM" == "true" ]; then
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --from-literal=AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY --namespace $PXCNAMESPACE &>/dev/null
  elif [ "$AZURE_CLOUD_PLATFORM" == "true" ]; then
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET --from-literal=AZURE_CLIENT_ID=$AZURE_CLIENT_ID --from-literal=AZURE_TENANT_ID=$AZURE_TENANT_ID --namespace $PXCNAMESPACE &>/dev/null
  elif [[ "$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED" == "true" ]]; then
    kubectl --kubeconfig=$KC create secret generic $CLOUD_SECRET_NAME --from-literal=VSPHERE_USER=$VSPHERE_USER --from-literal=VSPHERE_PASSWORD=$VSPHERE_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
  fi
  secretcheck="0"
  timecheck=0
  while [ $secretcheck -ne "1" ]
    do
      cloudSecret=`kubectl --kubeconfig=$KC get secret $CLOUD_SECRET_NAME --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      if [ $cloudSecret -eq "1" ]; then
        secretcheck="1"
        break
      fi
      showMessage "Preparing cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to prepare cloud secret: $CLOUD_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done
fi

if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
  KEYCLOAK_FRONTEND_PASSWORD=$ADMINPASSWORD
  KEYCLOAK_FRONTEND_USERNAME=$ADMINUSER
  kubectl --kubeconfig=$KC create secret generic $KEYCLOAK_BACKEND_SECRET --from-literal=postgresql-password=$KEYCLOAK_BACKEND_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
  kubectl --kubeconfig=$KC create secret generic $KEYCLOAK_FRONTEND_SECRET --from-literal=password=$KEYCLOAK_FRONTEND_PASSWORD --namespace $PXCNAMESPACE &>/dev/null
  secretcheck="0"
  timecheck=0
  while [ $secretcheck -ne "1" ]
    do
      keyCloakFrontendSecret=`kubectl --kubeconfig=$KC get secret $KEYCLOAK_BACKEND_SECRET --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      keyCloakBackendSecret=`kubectl --kubeconfig=$KC get secret $KEYCLOAK_FRONTEND_SECRET --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      if [[ $keyCloakFrontendSecret -eq "1" && "$keyCloakBackendSecret" -eq "1" ]]; then
        secretcheck="1"
        break
      fi
      showMessage "Preparing oidc secret: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to prepare keycloak secrets: $KEYCLOAK_BACKEND_SECRET and $KEYCLOAK_FRONTEND_SECRET into namespace: $PXCNAMESPACE for OIDC, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done

  OIDCCLIENTID=$PXC_OIDC_CLIENT_ID
  OIDCSECRET="dummy"
  pxcGrafanaEndpoint="http://pxc-grafana.$PXCNAMESPACE.svc.cluster.local:3000/grafana"
  if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
    OIDCENDPOINT="$PXC_KEYCLOAK/auth"
    EXTERNAL_ENDPOINT_URL=$PXC_FRONTEND
    pxcGrafanaEndpoint=$PXC_GRAFANA
  elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
    EXTERNAL_ENDPOINT_URL="$PXENDPOINT"
    pxcGrafanaEndpoint=$PXENDPOINT
  else
    OIDCENDPOINT="$PXENDPOINT:$PXC_KEYCLOAK_HTTP_PORT/auth"
    EXTERNAL_ENDPOINT_URL="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
    pxcGrafanaEndpoint="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  fi
fi

if [ "$OIDCENABLED" == "false" ]; then
  EXTERNAL_ENDPOINT_URL="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  pxcGrafanaEndpoint="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  echo "External Endpoint: $EXTERNAL_ENDPOINT_URL"
elif [[ "$OIDCENABLED" == "true" && "$PXCPROVISIONEDOIDC" == "false" ]]; then
  EXTERNAL_ENDPOINT_URL="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  pxcGrafanaEndpoint="$PXENDPOINT:$PXC_UI_EXTERNAL_PORT"
  echo "External Endpoint: $EXTERNAL_ENDPOINT_URL"
fi

if [[ "$OIDCENABLED" == "true" &&  "$PX_BACKUP_DEPLOY" == "true" ]]; then
  echo "External Access OIDC Endpoint: $OIDCENDPOINT"
  oidc_endpoint="http://$OIDCENDPOINT/realms/master"
  kubectl --kubeconfig=$KC create secret generic $BACKUP_OIDC_SECRET_NAME --from-literal=OIDC_CLIENT_ID=$OIDCCLIENTID --from-literal=OIDC_ENDPOINT=$oidc_endpoint --namespace $PXCNAMESPACE &>/dev/null
  backupsecretcheck="0"
  timecheck=0
  while [ $backupsecretcheck -ne "1" ]
    do
      cloudSecret=`kubectl --kubeconfig=$KC get secret $BACKUP_OIDC_SECRET_NAME --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "No resources found" | wc -l 2>&1`
      if [ $cloudSecret -eq "1" ]; then
        backupsecretcheck="1"
        break
      fi
      showMessage "Preparing oidc secret: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE"
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
          echo ""
          echo "Failed to create OIDC secret for PX-Backup: $BACKUP_OIDC_SECRET_NAME into namespace: $PXCNAMESPACE for auto disk provision, TIMEOUT: $LBSERVICETIMEOUT"
          echo "Contact: support@portworx.com"
          echo ""
          exit 1
      fi
      sleep $SLEEPINTERVAL
    done
fi

if [ $CUSTOMREGISTRYENABLED = "true" ]; then
  sleep $SLEEPINTERVAL
  validatesecret=`kubectl --kubeconfig=$KC get secret $IMAGEPULLSECRET  --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' | wc -l 2>&1`
  if [ $validatesecret -ne "1" ]; then
    echo "ERROR: --image-pull-secret provided is not present in $PXCNAMESPACE namespace, please create it in $PXCNAMESPACE namespace and re-run the script"
    exit 1
  fi
fi

if [ -z $IMAGEPULLSECRET ]; then
  IMAGEPULLSECRET="docregistry-secret"
fi

if [ ${OPENSHIFTCLUSTER} ]; then
  if [ "$OPENSHIFTCLUSTER" == "true" ]; then
    ISOPENSHIFTCLUSTER="true"
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PX_BACKUP_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PX_BACKUP_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PX_BACKUP_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
      echo "Detected OpenShift system. Adding $PX_KEYCLOAK_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PX_KEYCLOAK_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PX_KEYCLOAK_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PX_STORE_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_PX_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PX_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PX_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
      echo "Detected OpenShift system. Adding $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PVC_CONTROLLER_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PVC_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi      
    fi
    if [ "$PX_METRICS_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_PROMETHEUS_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_PROMETHEUS_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_PROMETHEUS_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
      echo "Detected OpenShift system. Adding $PXC_LICENSE_SERVER_SERVICE_ACCOUNT user to privileged scc"
      oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_LICENSE_SERVER_SERVICE_ACCOUNT &>/dev/null
      if [ $? -ne 0 ]; then
        echo "failed to add $PXC_LICENSE_SERVER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
      fi
    fi
    echo "Detected OpenShift system. Adding $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT user to privileged scc"
    oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT &>/dev/null
    if [ $? -ne 0 ]; then
      echo "failed to add $PXC_INGRESS_CONTROLLER_SERVICE_ACCOUNT to privileged scc. exit code: $?"
    fi
    echo "Detected OpenShift system. Adding $PXC_OPERATOR_SERVICE_ACCOUNT user to privileged scc"
    oc --kubeconfig=$KC adm policy add-scc-to-user privileged system:serviceaccount:$PXCNAMESPACE:$PXC_OPERATOR_SERVICE_ACCOUNT &>/dev/null
    if [ $? -ne 0 ]; then
      echo "failed to add $PXC_OPERATOR_SERVICE_ACCOUNT to privileged scc. exit code: $?"
    fi
  fi
fi

PXOPERATORDEPLOYMENT="true"
PXDAEMONSETDEPLOYMENT="false"
PVC_CONTROLLER_REQUIRED="false"
if [[ "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "true" && "$PX_STORE_DEPLOY" == "true" ]]; then
  PXDAEMONSETDEPLOYMENT="true"
  PXOPERATORDEPLOYMENT="false"
  OPERATOR_UNSUPPORTED_CLUSTER="false"
  STORK_SCHEDULER_REQUIRED="false"
elif [[ "$OPERATOR_UNSUPPORTED_CLUSTER" == "true" && "$PX_STORE_DEPLOY" == "true" ]]; then
  PXDAEMONSETDEPLOYMENT="true"
  PXOPERATORDEPLOYMENT="false"
fi

if [[ "$PXDAEMONSETDEPLOYMENT" == "true" && "$PXCNAMESPACE" != "$STANDARD_NAMESPACE" ]]; then
  PVC_CONTROLLER_REQUIRED="true"
fi

modules_config="/tmp/pxc-modules.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: '$PXC_MODULES_CONFIG'
  namespace: '$PXCNAMESPACE'
data:
  backup: '\"$PX_BACKUP_DEPLOY\"'
  licenseserver: '\"$PX_LICENSE_SERVER_DEPLOY\"'
  metrics: '\"$PX_METRICS_DEPLOY\"'
  minik8s: '\"$PXCENTRAL_MINIK8S\"'
  portworx: '\"$PX_STORE_DEPLOY\"'
  sso: '\"$OIDCENABLED\"'
  centralpx: '\"$CENTRAL_DEPLOYED_PX\"'
  existingpx: '\"$USE_EXISTING_PX\"'
  daemonsetpx: '\"$PXDAEMONSETDEPLOYMENT\"'
  operatorpx: '\"$PXOPERATORDEPLOYMENT\"'
' > $modules_config

central_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.centralpx} 2>&1`
existing_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.existingpx} 2>&1`
daemonset_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.daemonsetpx} 2>&1`
operator_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.operatorpx} 2>&1`
metrics_store_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.metrics} 2>&1`
license_server_enabled=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.licenseserver} 2>&1`
if [ "$central_px" == "true" ]; then
  existingpx="false"
fi
if [ "$existingpx" == "true" ]; then
  central_px="false"
fi
config_check=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE 2>&1 | grep -v "error" | grep -v "NotFound" | grep -v "No resources found" | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [[ "$metrics_store_enabled" == "false" && "$PX_METRICS_DEPLOY" == "true" ]]; then
  config_check=0
fi
if [[ "$license_server_enabled" == "false" && "$PX_LICENSE_SERVER_DEPLOY" == "true" ]]; then
  config_check=0
fi
if [ $config_check -eq 0 ]; then
  kubectl --kubeconfig=$KC apply -f $modules_config --namespace $PXCNAMESPACE &>/dev/null
  if [[ "$license_server_enabled" == "false" && "$PX_LICENSE_SERVER_DEPLOY" == "true" ]]; then
    kubectl --kubeconfig=$KC delete job pxc-pre-setup --namespace $PXCNAMESPACE &>/dev/null
    sleep $SLEEPINTERVAL
    kubectl --kubeconfig=$KC delete job pxc-ls-ha-setup --namespace $PXCNAMESPACE &>/dev/null
  fi
else
  if [[ "$central_px" == "true" && "$daemonset_px" == "true" ]]; then
    PXDAEMONSETDEPLOYMENT="true"
    PXOPERATORDEPLOYMENT="false"
  elif [[ "$central_px" == "true" && "$operator_px" == "true" ]]; then
    PXOPERATORDEPLOYMENT="true"
    PXDAEMONSETDEPLOYMENT="false"
  elif [[ "$existing_px" == "true" || "$PX_STORE_DEPLOY" == "false" ]]; then
    PXOPERATORDEPLOYMENT="false"
    PXDAEMONSETDEPLOYMENT="false"
    OPERATOR_UNSUPPORTED_CLUSTER="false"
    PXCENTRAL_PX_APP_SAME_K8S_CLUSTER="false"
  fi
fi

if [ "$PX_STORE_DEPLOY" == "false" ]; then
  PXOPERATORDEPLOYMENT="false"
  PXDAEMONSETDEPLOYMENT="false"
fi

if [ "$PXDAEMONSETDEPLOYMENT" == "true" ]; then
  echo "PX daemonset deployment: $PXDAEMONSETDEPLOYMENT"
elif [ "$PXOPERATORDEPLOYMENT" == "true" ]; then
  echo "PX operator deployment: $PXOPERATORDEPLOYMENT"
fi

if [ "$PXCENTRAL_MINIK8S"  == "false" ]; then
  PX_STORE_DEPLOY="true"
fi

if [ "$ISOPENSHIFTCLUSTER" == "true" ]; then
prometheus_cluster_role="/tmp/px-prometheus-clusterrole.yaml"
cat <<< '
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: px-prometheus
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: [""]
    resources:
      - nodes
      - services
      - endpoints
      - pods
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources:
      - configmaps
    verbs: ["get"]
  - nonResourceURLs: ["/metrics", "/federate"]
    verbs: ["get"]
' > $prometheus_cluster_role
kubectl --kubeconfig=$KC apply -f $prometheus_cluster_role  &>/dev/null
fi

cat > $PXCDB <<- "EOF"
-- phpMyAdmin SQL Dump
-- version 4.7.6
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 22, 2019 at 04:40 AM
-- Server version: 5.7.20
-- PHP Version: 7.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `emtpypxcentralinit`
--

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` int(10) UNSIGNED NOT NULL,
  `type` enum('AUTH','SPEC','COMPANY') NOT NULL,
  `sub_type` enum('LOGIN','LOGOUT','CREATE','UPDATE','DELETE') NOT NULL,
  `data` varchar(2048) NOT NULL,
  `ip` varchar(39) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `aws_clusters`
--

CREATE TABLE `aws_clusters` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL,
  `aws_credential_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `instances` int(11) NOT NULL,
  `region` varchar(50) DEFAULT NULL,
  `security_group` varchar(255) DEFAULT NULL,
  `security_group_id` varchar(1024) DEFAULT NULL,
  `total_used` int(11) DEFAULT NULL,
  `total_size` int(11) DEFAULT NULL,
  `cpu` int(11) DEFAULT NULL,
  `instance_obj` blob,
  `status` enum('RUNNING','TERMINATED','STOPPED','REBOOT','ERROR','NEW') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `aws_credentials`
--

CREATE TABLE `aws_credentials` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL,
  `aws_key` varchar(255) NOT NULL,
  `aws_secret` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `keypair_name` varchar(255) DEFAULT NULL,
  `group_name` varchar(255) DEFAULT NULL,
  `ssh_key` varchar(4096) DEFAULT NULL,
  `region` varchar(20) DEFAULT NULL,
  `version` varchar(20) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `company`
--

CREATE TABLE `company` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `sales_contact` varchar(70) DEFAULT NULL,
  `contact_person_gender` enum('MALE','FEMALE','OTHER') NOT NULL,
  `contact_person` varchar(70) NOT NULL,
  `contact_email` varchar(254) NOT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `billing_address1` varchar(255) DEFAULT NULL,
  `billing_address2` varchar(255) DEFAULT NULL,
  `billing_city` varchar(255) DEFAULT NULL,
  `billing_state` varchar(255) DEFAULT NULL,
  `billing_country` varchar(255) DEFAULT NULL,
  `billing_zip` varchar(30) DEFAULT NULL,
  `gdpr` tinyint(1) NOT NULL DEFAULT '0',
  `notes` varchar(1024) DEFAULT NULL,
  `created_by` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `company`
--

INSERT INTO `company` (`id`, `name`, `url`, `sales_contact`, `contact_person_gender`, `contact_person`, `contact_email`, `contact_phone`, `billing_address1`, `billing_address2`, `billing_city`, `billing_state`, `billing_country`, `billing_zip`, `gdpr`, `notes`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'UnAssigned', 'https://www.portworx.com', 'None', 'MALE', 'None', 'support@portworx.com', '111-1111', 'None', 'None', 'None', 'None', 'United States', '00000', 0, 'None', 1, '2001-01-01 00:00:00', '2001-01-01 00:00:00');


-- --------------------------------------------------------

--
-- Table structure for table `lh_cluster`
--
CREATE TABLE `lh_cluster` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `clusteruuid` varchar(80) NOT NULL,
  `clusterid` varchar(255) NOT NULL,
  `endpoint_active` varchar(255) NOT NULL,
  `endpoint_schema` enum('http','https') NOT NULL,
  `endpoint` varchar(255) NOT NULL,
  `endpoint_sdk` varchar(255) NOT NULL,
  `endpoint_port` smallint(11) UNSIGNED DEFAULT NULL,
  `sdk_port` smallint(11) UNSIGNED DEFAULT NULL,
  `cloud_type` enum('AWS','GOOGLE','AZURE','OTHERS') NOT NULL,
  `cloud_credential` varchar(255) DEFAULT NULL,
  `version` varchar(255) NOT NULL,
  `scheduler` enum('NONE','OTHER','MESOS','KUBERNETES','DCOS','DOCKER') NOT NULL,
  `grafana` varchar(1024) DEFAULT NULL,
  `prometheus` varchar(1024) DEFAULT NULL,
  `kibana` varchar(1024) DEFAULT NULL,
  `kube_config` blob,
  `security_type` enum('NONE','TOKEN','OIDC') NOT NULL,
  `token` varchar(5000) DEFAULT NULL,
  `data` varchar(2000) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2016_06_01_000001_create_oauth_auth_codes_table', 1),
(4, '2016_06_01_000002_create_oauth_access_tokens_table', 1),
(5, '2016_06_01_000003_create_oauth_refresh_tokens_table', 1),
(6, '2016_06_01_000004_create_oauth_clients_table', 1),
(7, '2016_06_01_000005_create_oauth_personal_access_clients_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `oauth_access_tokens`
--

CREATE TABLE `oauth_access_tokens` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `client_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scopes` text COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_auth_codes`
--

CREATE TABLE `oauth_auth_codes` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `client_id` int(10) UNSIGNED NOT NULL,
  `scopes` text COLLATE utf8mb4_unicode_ci,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `oauth_clients`
--

CREATE TABLE `oauth_clients` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `secret` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `redirect` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `personal_access_client` tinyint(1) NOT NULL,
  `password_client` tinyint(1) NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `oauth_clients`
--

INSERT INTO `oauth_clients` (`id`, `user_id`, `name`, `secret`, `redirect`, `personal_access_client`, `password_client`, `revoked`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Laravel Personal Access Client', 'vAGnE85CLxdtouR1Q5nnT4que1MBpoz32nyGxviS', 'http://localhost', 1, 0, 0, '2019-03-22 10:05:23', '2019-03-22 10:05:23'),
(2, NULL, 'Laravel Password Grant Client', 'i4I7FIfD4AeqJUhu3R7q4Qedjn7V50u4f4Gz1Q1k', 'http://localhost', 0, 1, 0, '2019-03-22 10:05:23', '2019-03-22 10:05:23');

-- --------------------------------------------------------

--
-- Table structure for table `oauth_personal_access_clients`
--

CREATE TABLE `oauth_personal_access_clients` (
  `id` int(10) UNSIGNED NOT NULL,
  `client_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `oauth_personal_access_clients`
--

INSERT INTO `oauth_personal_access_clients` (`id`, `client_id`, `created_at`, `updated_at`) VALUES
(1, 1, '2019-03-22 10:05:23', '2019-03-22 10:05:23');

-- --------------------------------------------------------

--
-- Table structure for table `oauth_refresh_tokens`
--

CREATE TABLE `oauth_refresh_tokens` (
  `id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `access_token_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `revoked` tinyint(1) NOT NULL,
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(129) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `specgen`
--

CREATE TABLE `specgen` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(1024) NOT NULL,
  `labels` varchar(1028) NOT NULL,
  `data` varchar(3072) NOT NULL,
  `command` varchar(1024) NOT NULL,
  `url` varchar(1024) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL DEFAULT '1',
  `company_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(275) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('PXADMIN','DEMO','ADMIN','MANAGER','ENGINEER','SALES','USER') COLLATE utf8mb4_unicode_ci DEFAULT 'MANAGER',
  `provider_type` enum('NORMAL','GITHUB','GOOGLE','OIDC') COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_id` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `provider_token` varchar(5000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(35) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `image` varchar(1028) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_status` enum('NEW','COMPLETED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NEW',
  `receive_updates` tinyint(1) NOT NULL DEFAULT '0',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `email_verification_code` varchar(129) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`,`deleted_at`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;


-- --------------------------------------------------------

--
-- Table structure for table `user_invite`
--

CREATE TABLE `user_invite` (
  `id` int(10) UNSIGNED NOT NULL,
  `company_id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `status` enum('NEW','ACCEPTED','REJECTED') NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `aws_clusters`
--
ALTER TABLE `aws_clusters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `aws_credentials`
--
ALTER TABLE `aws_credentials`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `company`
--
ALTER TABLE `company`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `lh_cluster`
--
ALTER TABLE `lh_cluster`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `oauth_access_tokens`
--
ALTER TABLE `oauth_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_access_tokens_user_id_index` (`user_id`);

--
-- Indexes for table `oauth_auth_codes`
--
ALTER TABLE `oauth_auth_codes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `oauth_clients`
--
ALTER TABLE `oauth_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_clients_user_id_index` (`user_id`);

--
-- Indexes for table `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_personal_access_clients_client_id_index` (`client_id`);

--
-- Indexes for table `oauth_refresh_tokens`
--
ALTER TABLE `oauth_refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `oauth_refresh_tokens_access_token_id_index` (`access_token_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `specgen`
--
ALTER TABLE `specgen`
  ADD PRIMARY KEY (`id`);


--
-- Indexes for table `user_invite`
--
ALTER TABLE `user_invite`
  ADD PRIMARY KEY (`id`,`company_id`,`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aws_clusters`
--
ALTER TABLE `aws_clusters`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `aws_credentials`
--
ALTER TABLE `aws_credentials`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `company`
--
ALTER TABLE `company`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1005;

--
-- AUTO_INCREMENT for table `lh_cluster`
--
ALTER TABLE `lh_cluster`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `oauth_clients`
--
ALTER TABLE `oauth_clients`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `oauth_personal_access_clients`
--
ALTER TABLE `oauth_personal_access_clients`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `specgen`
--
ALTER TABLE `specgen`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;



--
-- AUTO_INCREMENT for table `user_invite`
--
ALTER TABLE `user_invite`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
EOF

cat <<< '
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: pxcentral-onprem-operator
   namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
subjects:
- kind: ServiceAccount
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
roleRef:
  kind: ClusterRole
  name: pxcentral-onprem-operator
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: px-cluster-admin-binding
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:serviceaccount:$PXCNAMESPACE:default
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: pxc-onprem-operator-cluster-admin-binding
  namespace: '$PXCNAMESPACE'
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:serviceaccount:$PXCNAMESPACE:pxcentral-onprem-operator
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: '$PXCNAMESPACE'
  name: pxcentral-onprem-operator
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - services
  - services/finalizers
  - endpoints
  - persistentvolumeclaims
  - events
  - configmaps
  - secrets
  verbs:
  - "*"
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - replicasets
  - statefulsets
  verbs:
  - "*"
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - configmaps
  - secrets
  verbs:
  - "*"
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  verbs:
  - get
  - create
- apiGroups:
  - apps
  resourceNames:
  - pxcentral-onprem-operator
  resources:
  - deployments/finalizers
  verbs:
  - update
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
- apiGroups:
  - apps
  resources:
  - replicasets
  - deployments
  verbs:
  - get
- apiGroups:
  - pxcentral.com
  resources:
  - "*"
  verbs:
  - "*"
---
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: pxcentralonprems.pxcentral.com
  namespace: '$PXCNAMESPACE'
spec:
  group: pxcentral.com
  names:
    kind: PxCentralOnprem
    listKind: PxCentralOnpremList
    plural: pxcentralonprems
    singular: pxcentralonprem
  scope: Namespaced
  subresources:
    status: {}
  versions:
  - name: v1alpha1
    served: true
    storage: true
---
apiVersion: v1
kind: Service
metadata:
  name: px-central
  namespace: '$PXCNAMESPACE'
  labels:
    app: px-central
spec:
  selector:
    app: px-central
  ports:
    - name: px-central-grpc
      protocol: TCP
      port: 10005
      targetPort: 10005
    - name: px-central-rest
      protocol: TCP
      port: 10006
      targetPort: 10006
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pxcentral-onprem-operator
  namespace: '$PXCNAMESPACE'
spec:
  replicas: 1
  selector:
    matchLabels:
      name: pxcentral-onprem-operator
      app: px-central
  template:
    metadata:
      labels:
        name: pxcentral-onprem-operator
        app: px-central
    spec:
        affinity:
          nodeAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              nodeSelectorTerms:
              - matchExpressions:
                - key: '$NODE_AFFINITY_KEY'
                  operator: NotIn
                  values:
                  - '\"$NODE_AFFINITY_VALUE\"'
        initContainers:
        - command:
          - python
          - /specs/pxc-pre-setup.py
          image: '$PXCPRESETUPIMAGE'
          imagePullPolicy: '$IMAGEPULLPOLICY'
          env:
            - name: PXC_NAMESPACE
              value: '$PXCNAMESPACE'
          name: pxc-pre-setup
          resources: {}
          securityContext:
            privileged: true
        serviceAccount: pxcentral-onprem-operator
        serviceAccountName: pxcentral-onprem-operator
        containers:
          - name: pxcentral-onprem-operator
            image: '$ONPREMOPERATORIMAGE'
            imagePullPolicy: '$IMAGEPULLPOLICY'
            env:
              - name: OPERATOR_NAME
                value: pxcentral-onprem-operator
              - name: POD_NAME
                valueFrom:
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.name
              - name: WATCH_NAMESPACE
                valueFrom:
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
          - name: px-central
            image: '$PXCENTRALAPISERVER'
            env:
              - name: PXC_NAMESPACE
                value: '$PXCNAMESPACE'
            imagePullPolicy: '$IMAGEPULLPOLICY'
            readinessProbe:
              httpGet:
                path: /v1/health
                port: 10006
              initialDelaySeconds: 10
              timeoutSeconds: 120
              periodSeconds: 20
            resources:
              limits:
                cpu: 512m
                memory: "512Mi"
              requests:
                memory: "512Mi"
                cpu: 256m
            securityContext:
              privileged: true
            command:
            - /pxcentral-onprem
            - start
        imagePullSecrets:
        - name: '$IMAGEPULLSECRET'
' > /tmp/pxcentralonprem_crd.yaml

cat <<< '
apiVersion: pxcentral.com/v1alpha1
kind: PxCentralOnprem
metadata:
  name: pxcentralonprem
  namespace: '$PXCNAMESPACE'
spec:
  namespace: '$PXCNAMESPACE'                    # Provide namespace to install px and pxcentral stack
  k8sVersion: '$k8sVersion'
  nodeAffinityKey: '$NODE_AFFINITY_KEY'
  nodeAffinityValue: '$NODE_AFFINITY_VALUE'
  storkRequired: '$STORK_SCHEDULER_REQUIRED'
  portworx:
    pxstore: '$PX_STORE_DEPLOY'
    enabled: '$PXOPERATORDEPLOYMENT'
    daemonsetDeployment: '$PXDAEMONSETDEPLOYMENT' 
    clusterName: '$PXCPXNAME'   # Note: Use a unique name for your cluster: The characters allowed in names are: digits (0-9), lower case letters (a-z) and (-)
    pxOperatorImage: '$PXOPERATORIMAGE'
    pxDevImage: '$PXDEVIMAGE'
    pvcControllerRequired: '$PVC_CONTROLLER_REQUIRED'
    security:
      enabled: false
      oidc:
        enabled: false
      selfSigned:
        enabled: false
  centralLighthouse:
    enabled: '$PX_LIGHTHOUSE_DEPLOY'
    externalHttpPort: '$PXC_LIGHTHOUSE_HTTP_PORT'
    externalHttpsPort: '$PXC_LIGHTHOUSE_HTTPS_PORT'
  externalEndpoint: '$EXTERNAL_ENDPOINT_URL'       # For ingress endpint only
  loadBalancerEndpoint: '$PXENDPOINT'
  username: '$ADMINUSER'                       
  password: '$ADMINPASSWORD'
  email: '$ADMINEMAIL'
  imagePullSecrets: '$IMAGEPULLSECRET'
  customRegistryURL: '$CUSTOMREGISTRY'
  customeRegistryEnabled: '$CUSTOMREGISTRYENABLED'
  imagesRepoName: '$IMAGEREPONAME'
  imagePullPolicy: '$IMAGEPULLPOLICY'
  isOpenshiftCluster: '$ISOPENSHIFTCLUSTER'
  ingressAPIVersionChangeRequired: '$INGRESS_CHANGE_REQUIRED'
  cloud:
    aws: '$AWS_CLOUD_PLATFORM'
    cloudSecretName: '$CLOUD_SECRET_NAME'
    gcp: '$GOOGLE_CLOUD_PLATFORM'
    azure: '$AZURE_CLOUD_PLATFORM'
    ibm: '$IBM_CLOUD_PLATFORM'
    isCloud: '$ISCLOUDDEPLOYMENT'
    cloudStorage: '$CLOUD_STORAGE_ENABLED'
    cloudDataDiskType: '$CLOUD_DATA_DISK_TYPE'
    cloudDataDiskSize: '$CLOUD_DATA_DISK_SIZE'
    eksCluster: '$EKS_CLUSTER_TYPE'
    gkeCluster: '$GKE_CLUSTER_TYPE'
    aksCluster: '$AKS_CLUSTER_TYPE'
    awsDiskProvisionRequired: '$AWS_DISK_PROVISIONED_REQUIRED'
    gcpDiskProvisionRequired: '$GCP_DISK_PROVISIONED_REQUIRED'
    azureDiskProvisionRequired: '$AZURE_DISK_PROVISIONED_REQUIRED'
  pks:
    enabled: '$PKS_CLUSTER_ENABLED'
  vshpere:
    enabled: '$VSPHERE_CLUSTER'
    vshpereDiskProvisionRequired: '$VSPHERE_CLUSTER_DISK_PROVISION_REQUIRED'
    secretName: '$CLOUD_SECRET_NAME'
    vsphereVcenter: '$VSPHERE_VCENTER'
    vsphereVcenterPort: '$VSPHERE_VCENTER_PORT'
    vsphereInsecure: '$VSPHERE_INSECURE'
    vsphereInstallationMode: '$VSPHERE_INSTALL_MODE'
    vsphereDatastorePrefix: '$VSPHERE_DATASTORE_PREFIX'
  ocp:
    enabled: '$OPERATOR_UNSUPPORTED_CLUSTER'
  monitoring:
    prometheus:
      enabled: '$PX_METRICS_DEPLOY'
      externalPort: '$PXC_METRICS_STORE_PORT'
      externalEndpoint: '$METRICS_ENDPOINT'
    grafana:
      enabled: '$PX_METRICS_DEPLOY'
      endpoint: '$pxcGrafanaEndpoint'
  frontendEndpoint: '$PXC_FRONTEND'
  backendEndpoint: '$PXC_BACKEND'
  middlewareEndpoint: '$PXC_MIDDLEWARE'
  grafanaEndpoint: '$PXC_GRAFANA'
  keycloakEndpoint: '$PXC_KEYCLOAK'
  ingressEndpoint: '$INGRESS_ENDPOINT'
  pxcentral:
    enabled: true
    pxcApiServer: '$PXCENTRALAPISERVER'
    domainSetupRequired: '$DOMAIN_SETUP_REQUIRED'
    publicEndpointSetupRequired: '$PUBLIC_ENDPOINT_SETUP_REQUIRED'
    ingressSetupRequired: '$INGRESS_SETUP_REQUIRED'
    pxcui:                    # Deploy PX-Central UI, required on pxcentral cluster only 
      enabled: true
      externalAccessPort: '$PXC_UI_EXTERNAL_PORT'
      security:
        pxcProvisionedOIDC: '$PXCPROVISIONEDOIDC'
        keyCloakAdminUser: '$KEYCLOAK_FRONTEND_USERNAME'
        keyCloakExternalPortHttp: '$PXC_KEYCLOAK_HTTP_PORT'
        keyCloakExternalPortHttps: '$PXC_KEYCLOAK_HTTPS_PORT'
        enabled: '$OIDCENABLED'
        clientId: '$OIDCCLIENTID'
        clientSecret: '$OIDCSECRET'
        oidcEndpoint: '$OIDCENDPOINT'
      metallb:
        enabled: false
    licenseserver:            # License Server
      enabled: '$PX_LICENSE_SERVER_DEPLOY'
      type:
        UAT: '$UATLICENCETYPE'
        airgapped: '$AIRGAPPEDLICENSETYPE'
      adminPassword: '$LICENSEADMINPASSWORD'
    etcd:
      enabled: '$PX_ETCD_DEPLOY'
      singleETCD: '$PX_SINGLE_ETCD_DEPLOY'
      externalEtcdClientPort: '$PXC_ETCD_EXTERNAL_CLIENT_PORT'
    pxbackup:
      enabled: '$PX_BACKUP_DEPLOY'
      image: '$PXBACKUPIMAGE'
      orgName: '$PX_BACKUP_ORGANIZATION'
' > /tmp/pxcentralonprem_cr.yaml

mac_daemonset="/tmp/pxc-mac-check.yaml"
cat <<< '
apiVersion: v1
kind: ServiceAccount
metadata:
  name: pxc-license-ha
  namespace: '$PXCNAMESPACE'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxc-license-ha-role
  namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: pxc-license-ha-role-binding
  namespace: '$PXCNAMESPACE'
subjects:
- kind: ServiceAccount
  name: pxc-license-ha
  namespace: '$PXCNAMESPACE'
roleRef:
  kind: ClusterRole
  name: pxc-license-ha-role
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    run: pxc-mac-setup
  name: pxc-mac-setup
  namespace: '$PXCNAMESPACE'
spec:
  selector:
    matchLabels:
      run: pxc-mac-setup
  minReadySeconds: 0
  updateStrategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  template:
    metadata:
      labels:
        run: pxc-mac-setup
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: '$NODE_AFFINITY_KEY'
                operator: NotIn
                values:
                - '\"$NODE_AFFINITY_VALUE\"'
      hostNetwork: true
      hostPID: false
      restartPolicy: Always
      serviceAccountName: pxc-license-ha
      containers:
      - args:
        - bash
        - -c
        - python3 /code/setup_mac_address.py
        image: '$PXCLSLABELSETIMAGE'
        env:
          - name: PXC_NAMESPACE
            value: '$PXCNAMESPACE'
        imagePullPolicy: '$IMAGEPULLPOLICY'
        name: pxc-mac-setup
      imagePullSecrets:
        - name: '$IMAGEPULLSECRET'
' > $mac_daemonset

echo "PX-Central cluster deployment started:"
echo "This process may take several minutes. Please wait for it to complete..."

if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  pxclicensecm="0"
  main_node_count=`kubectl --kubeconfig=$KC get nodes -lprimary/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  backup_node_count=`kubectl --kubeconfig=$KC get nodes -lbackup/ls=true 2>&1 | grep Ready | wc -l 2>&1`
  if [[ $main_node_count -eq 1 && $backup_node_count -eq 1 ]]; then
    pxclicensecm="1"
  fi
  pxclicensecmcreated="0"
  timecheck=0
  count=0

  if [ "$pxclicensecm" -eq "0" ]; then
    kubectl --kubeconfig=$KC apply -f $mac_daemonset &>/dev/null
  fi

  while [ $pxclicensecm -ne "1" ]
    do
      pxcentral_license_cm=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-lsc-hasetup" | wc -l 2>&1`
      if [ "$pxcentral_license_cm" -eq "$nodeCount" ]; then
        pxclicensecm="1"
        pxclicensecmcreated="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --License-Server-Labels-- to be ready (0/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        exit 1
      fi
    done
  if [ "$pxclicensecmcreated" -eq "1" ]; then
    kubectl --kubeconfig=$KC delete -f $mac_daemonset &>/dev/null
  fi
fi

kubectl --kubeconfig=$KC apply -f /tmp/pxcentralonprem_crd.yaml &>/dev/null
pxcentralcrdregistered="0"
timecheck=0
count=0
while [ $pxcentralcrdregistered -ne "1" ]
  do
    pxcentral_crd=`kubectl --kubeconfig=$KC get crds 2>&1 | grep -i "pxcentralonprems.pxcentral.com" | wc -l 2>&1`
    if [ "$pxcentral_crd" -eq "1" ]; then
      pxcentralcrdregistered="1"
      break
    fi
    showMessage "Waiting for PX-Central required components --Central-CRD's-- to be ready (0/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      exit 1
    fi
  done

kubectl --kubeconfig=$KC apply -f /tmp/pxcentralonprem_cr.yaml &>/dev/null
showMessage "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE &>/dev/null
operatordeploymentready="0"
timecheck=0
count=0
while [ $operatordeploymentready -ne "1" ]
  do
    operatoronpremdeployment=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "1/2" | wc -l 2>&1`
    if [ "$operatoronpremdeployment" -eq "1" ]; then
        operatordeploymentready="1"
        break
    fi
    operatoronpremdeploymentready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "2/2" | wc -l 2>&1`
    if [ "$operatoronpremdeploymentready" -eq "1" ]; then
        operatordeploymentready="1"
        break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Operator-- to be ready (0/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "PX-Central onprem deployment not ready... Timeout: $TIMEOUT seconds"
      operatorPodName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $1}' | grep -v NAME 2>&1`
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

if [[ "$PX_LICENSE_SERVER_DEPLOY" == "true" || "$PX_STORE_DEPLOY" == "true" ]]; then
  showMessage "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
  pxready="0"
  sleep $SLEEPINTERVAL
  timecheck=0
  count=0
  license_server_cm_available="0"
  while [ $pxready -ne "1" ]
    do
      if [ "$PX_STORE_DEPLOY" == "true" ]; then
        pxready=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE -lname=portworx 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
        if [ $pxready -ge 3 ]; then
            pxready="1"
            break
        fi
        showMessage "Waiting for PX-Central required components --PX-Central-Operator-PX-- to be ready (1/7)"
      fi
      if [ "$ISOPENSHIFTCLUSTER" == "true" ]; then
        if [ "$license_server_cm_available" -eq "0" ]; then
            main_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.primary} 2>&1`
            backup_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.secondary} 2>&1`
            if [[ ( ! -z "$main_node_ip" ) && ( ! -z "$backup_node_ip" ) ]]; then
              main_node_hostname=`kubectl --kubeconfig=$KC get nodes -o wide | grep "$main_node_ip" | awk '{print $1}' 2>&1`
              backup_node_hostname=`kubectl --kubeconfig=$KC get nodes -o wide | grep "$backup_node_ip" | awk '{print $1}' 2>&1`
              kubectl --kubeconfig=$KC label node $main_node_hostname px/ls=true &>/dev/null
              kubectl --kubeconfig=$KC label node $backup_node_hostname px/ls=true &>/dev/null
              kubectl --kubeconfig=$KC label node $main_node_hostname primary/ls=true &>/dev/null
              kubectl --kubeconfig=$KC label node $backup_node_hostname backup/ls=true &>/dev/null
              main_node_count=`kubectl --kubeconfig=$KC get node -lprimary/ls=true | grep Ready | wc -l 2>&1`
              backup_node_count=`kubectl --kubeconfig=$KC get node -lbackup/ls=true | grep Ready | wc -l 2>&1`
              if [[ $main_node_count -eq 1 && $backup_node_count -eq 1 ]]; then
                license_server_cm_available="1"
              fi
            fi
        fi
      fi
      if [[ "$PX_LICENSE_SERVER_DEPLOY" == "true" && "$PX_STORE_DEPLOY" == "false" ]]; then
        pxready="1"
        break
      fi
      if [[ "$PXCENTRAL_MINIK8S" == "true" && "$PX_STORE_DEPLOY" == "false" ]]; then
        pxready="1"
        break
      fi
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    if [[ "$PXCENTRAL_PX_APP_SAME_K8S_CLUSTER" == "true" && "$PXCNAMESPACE" != "$STANDARD_NAMESPACE" ]]; then
      kubectl --kubeconfig=$KC scale deployment --namespace $PXCNAMESPACE portworx-pvc-controller --replicas=0 &>/dev/null
      sleep 5
      kubectl --kubeconfig=$KC scale deployment --namespace $PXCNAMESPACE portworx-pvc-controller --replicas=3 &>/dev/null
    fi
fi

if [ "$PX_METRICS_DEPLOY" == "true" ]; then
  cassandrapxready="0"
  timecheck=0
  count=0
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
  while [ $cassandrapxready -ne "1" ]
    do
      pxcassandraready=`kubectl --kubeconfig=$KC get sts --namespace $PXCNAMESPACE pxc-cortex-cassandra 2>&1 | grep -v READY | awk '{print $2}' | grep "3/3" | wc -l 2>&1`
      pxcassandrareadyocp=`kubectl --kubeconfig=$KC get sts --namespace $PXCNAMESPACE pxc-cortex-cassandra 2>&1 | grep -v CURRENT | awk '{print $3}' | grep "3" | wc -l 2>&1`
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$pxcassandrareadyocp" -eq "1" ]; then
            cassandrapxready="1"
            break
        fi
      elif [ "$pxcassandraready" -eq "1" ]; then
        cassandrapxready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Metrics-Store-- to be ready (2/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
fi

if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
  lscready="0"
  timecheck=0
  count=0
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
  while [ $lscready -ne "1" ]
    do
      licenseserverready=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-license-server 2>&1 | grep -v READY | awk '{print $2}' | grep "2/2" | wc -l 2>&1`
      licenseserverreadyocp=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-license-server 2>&1 | grep -v CURRENT | awk '{print $3}' | grep "2" | wc -l 2>&1`
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$licenseserverreadyocp" -eq "1" ]; then
          lscready="1"
          break
        fi
      elif [ "$licenseserverready" -eq "1" ]; then
        lscready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (3/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-License-Server-- to be ready (4/7)"
fi

if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
  timecheck=0
  keycloakready="0"
  while [ $keycloakready -ne "1" ]
    do
      oidcready=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "NotFound" | grep "pxc-keycloak" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
      if [ $oidcready -eq 2 ]; then
        keycloakready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
    if [ ${CLOUDPLATFORM} ]; then
      echo ""
      echo "Cloud platform : $CLOUDPLATFORM, ingress setup required: $INGRESS_SETUP_REQUIRED"
      if [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
        echo "Ingress setup required"
        if [[ "$CLOUDPLATFORM" == "$GOOGLE_PROVIDER" || "$CLOUDPLATFORM" == "$AZURE_PROVIDER" ]]; then
          keycloakPodName=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lapp.kubernetes.io/name=keycloak 2>&1 | grep -v NAME | awk '{print $1}'`
          echo "Keycloak pod: $keycloakPodName"
          if [ ${keycloakPodName} ]; then
            kubectl --kubeconfig=$KC exec -it $keycloakPodName --namespace $PXCNAMESPACE -- bash -c "cd /opt/jboss/keycloak/bin/ && ./kcadm.sh config credentials --server http://localhost:8080/keycloak --realm master --user $KEYCLOAK_FRONTEND_USERNAME --password $KEYCLOAK_FRONTEND_PASSWORD && ./kcadm.sh update realms/master -s sslRequired=NONE"
            echo "Disabled ssl-required"
            echo ""
          fi
        fi
      fi
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
    KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
    client_details="/tmp/clients.json"
    curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/" -H 'Content-Type: application/json' -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $client_details
    cid_check="/tmp/clientid.py"
cat > $cid_check <<- "EOF"
import json
import sys
input_file=sys.argv[1]
clientID=sys.argv[2]
client_required_id=""
try:
    with open(input_file, "r") as fout:
        data = json.load(fout)
    for raw in data:
        client_id=raw.get('clientId')
        client_required_id=raw.get('id')
        if client_id == clientID:
            break
except Exception as ex:
    pass
print(client_required_id)
EOF

    admincli_id=`python $cid_check $client_details admin-cli`
    KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
    curl -s -X PUT "http://$OIDCENDPOINT/admin/realms/master/clients/$admincli_id" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
    --data '{
	    "attributes": {
          "access.token.lifespan": "31536000"
	  }
   }'
    
    KEYCLOAK_TOKEN=`curl -s -d "client_id=admin-cli" -d "username=$KEYCLOAK_FRONTEND_USERNAME" -d "password=$KEYCLOAK_FRONTEND_PASSWORD" -d "grant_type=password" "http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token" | jq ".access_token" | sed 's/\"//g'`
    curl -s -X POST "http://$OIDCENDPOINT/admin/realms/master/clients/" \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
    --data '{
    "clientId": '\"$PXC_OIDC_CLIENT_ID\"',
    "name": "${client_account}",
    "rootUrl": '\"http://$OIDCENDPOINT\"',
    "adminUrl": '\"http://$OIDCENDPOINT\"',
    "baseUrl": "/keycloak/realms/master/account",
    "surrogateAuthRequired": false,
    "enabled": true,
    "clientAuthenticatorType": "client-secret",
    "redirectUris": [
        '\"http://$EXTERNAL_ENDPOINT_URL/*\"',
        '\"http://$PXC_FRONTEND/*\"',
        '\"http://$PXC_GRAFANA/*\"'
    ],
    "webOrigins": [
        '\"http://$PXC_FRONTEND\"',
        '\"http://$OIDCENDPOINT\"',
        '\"http://$PXC_GRAFANA\"',
        '\"http://$PXC_KEYCLOAK\"'  
    ],
    "notBefore": 0,
    "bearerOnly": false,
    "consentRequired": false,
    "standardFlowEnabled": true,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": true,
    "serviceAccountsEnabled": false,
    "publicClient": true,
    "frontchannelLogout": false,
    "protocol": "openid-connect",
    "attributes": {
        "saml.assertion.signature": "false",
        "access.token.lifespan": "31536000",
        "saml.multivalued.roles": "false",
        "saml.force.post.binding": "false",
        "saml.encrypt": "false",
        "saml.server.signature": "false",
        "saml.server.signature.keyinfo.ext": "false",
        "exclude.session.state.from.auth.response": "false",
        "saml_force_name_id_format": "false",
        "saml.client.signature": "false",
        "tls.client.certificate.bound.access.tokens": "false",
        "saml.authnstatement": "false",
        "display.on.consent.screen": "false",
        "saml.onetimeuse.condition": "false"
    },
    "authenticationFlowBindingOverrides": {},
    "fullScopeAllowed": true,
    "nodeReRegistrationTimeout": -1,
    "protocolMappers": [
        {
            "name": "Client ID",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientId",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientId",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client Host",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientHost",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientHost",
                "jsonType.label": "String"
            }
        },
        {
            "name": "roles",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usermodel-realm-role-mapper",
            "consentRequired": false,
            "config": {
                "multivalued": "true",
                "userinfo.token.claim": "true",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "roles",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client IP Address",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientAddress",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientAddress",
                "jsonType.label": "String"
            }
        }
    ],
    "defaultClientScopes": [
        "web-origins",
        "role_list",
        "profile",
        "roles",
        "email"
    ],
    "optionalClientScopes": [
        "address",
        "phone",
        "offline_access"
    ],
    "access": {
        "view": true,
        "configure": true,
        "manage": true,
        "admin": true
    }
}' &>/dev/null
  echo ""
  echo "OIDC Client: $PXC_OIDC_CLIENT_ID configured."
  client_details="/tmp/clients.json"
  curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/" -H 'Content-Type: application/json' -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $client_details
  cid_check="/tmp/clientid.py"
cat > $cid_check <<- "EOF"
import json
import sys
input_file=sys.argv[1]
clientID=sys.argv[2]
client_required_id=""
try:
    with open(input_file, "r") as fout:
        data = json.load(fout)
    for raw in data:
        client_id=raw.get('clientId')
        client_required_id=raw.get('id')
        if client_id == clientID:
            break
except Exception as ex:
    pass
print(client_required_id)
EOF

  pxcentral_id=`python $cid_check $client_details $PXC_OIDC_CLIENT_ID`
  PXC_OIDC_CLIENT_SECRET=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/clients/$pxcentral_id/client-secret/" -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".value"`
  echo "OIDC client [$PXC_OIDC_CLIENT_ID] id: $pxcentral_id"
  echo "OIDC Client ID: $PXC_OIDC_CLIENT_ID"
  echo "OIDC Client Secret: $PXC_OIDC_CLIENT_SECRET"
  if [[ -z ${PXC_OIDC_CLIENT_ID} || -z ${PXC_OIDC_CLIENT_SECRET} ]]; then
    echo ""
    echo "ERROR: Falied to setup PX-Central-Onprem OIDC."
    echo "Contact: support@portworx.com"
    echo ""
    exit 1
  fi
  pxadmin_user_id=`curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/users/" \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq ".[].id" | sed 's/\"//g'`
  echo "OIDC Admin user [$KEYCLOAK_FRONTEND_USERNAME] id: $pxadmin_user_id"

  user_update_status=`curl -s -X PUT "http://$OIDCENDPOINT/admin/realms/master/users/$pxadmin_user_id" \
      -H 'Content-Type: application/json' \
      -H "Authorization: Bearer $KEYCLOAK_TOKEN" \
      --data '{
          "emailVerified": true,
          "firstName": '\"$KEYCLOAK_FRONTEND_USERNAME\"',
          "lastName": "Admin",
          "email": '\"$ADMINEMAIL\"'
      }'`
  updated_user_details="/tmp/admin_user.json"
  curl -s -X GET "http://$OIDCENDPOINT/admin/realms/master/users/" \
          -H 'Content-Type: application/json' \
          -H "Authorization: Bearer $KEYCLOAK_TOKEN" | jq "." > $updated_user_details

  if [ "$PX_LICENSE_SERVER_DEPLOY" == "true" ]; then
    main_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.primary} 2>&1`
    backup_node_ip=`kubectl --kubeconfig=$KC get cm --namespace $PXCNAMESPACE pxc-lsc-replicas -o jsonpath={.data.secondary} 2>&1`
    license_servers="$main_node_ip:7070,$backup_node_ip:7070"
  else
    license_servers="pxc-license.$PXCNAMESPACE.svc.cluster.local:7070"
  fi

  if [[ "$PX_LICENSE_SERVER_DEPLOY" == "false" &&  -z "${LICENSEADMINPASSWORD}" ]]; then
    LICENSEADMINPASSWORD="Adm1n!Ur"
  fi

  backup_service_endpoint="px-backup.$PXCNAMESPACE.svc.cluster.local:10002"
  pxc_status_endpoint="http://pxc-apiserver.$PXCNAMESPACE.svc.cluster.local:10006"
  backend_config="/tmp/pxc-backend.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral    # The base url of frontend service
  BASE_ROOT_PATH: /pxcentral/
  FRONTEND_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/               # The base url of Ingress
  API_URL: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/backend             # px-central-backend url
  LH_MIDDLEWARE_URL: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/lhBackend        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: errorlog
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/backend
  FRONTEND_HOSTNAME: '$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral
  FRONTEND_GRAFANA_URL: "http://'$pxcGrafanaEndpoint'/grafana"           # grafana url
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stack
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$PXENDPOINT':'$PXC_UI_EXTERNAL_PORT'/pxcentral/landing/oauth/oidc
' > $backend_config

  with_dns_backend_config="/tmp/pxc-ui-configmap.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$PXC_FRONTEND'/    # The base url of frontend service
  BASE_ROOT_PATH: /
  FRONTEND_URL: http://'$PXC_FRONTEND'               # The base url of Ingress
  API_URL: http://'$PXC_BACKEND'             # px-central-backend url
  LH_MIDDLEWARE_URL: '$PXC_MIDDLEWARE'        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$PXC_FRONTEND'
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: errorlog
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$PXC_BACKEND'
  FRONTEND_HOSTNAME: '$PXC_FRONTEND'
  FRONTEND_GRAFANA_URL: http://'$pxcGrafanaEndpoint'           # grafana url
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stack
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$PXC_FRONTEND'/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$PXC_FRONTEND'/landing/oauth/oidc
' > $with_dns_backend_config

with_ingress_backend_config="/tmp/pxc-ui-inngress-configmap.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: pxc-central-ui-configmap
  namespace: '$PXCNAMESPACE'
data:
  FRONTEND_UI_URL: http://'$INGRESS_ENDPOINT'/pxcentral    # The base url of frontend service
  BASE_ROOT_PATH: /pxcentral/
  FRONTEND_URL: http://'$INGRESS_ENDPOINT'/               # The base url of Ingress
  API_URL: http://'$INGRESS_ENDPOINT'/backend             # px-central-backend url
  LH_MIDDLEWARE_URL: '$INGRESS_ENDPOINT'/lhBackend        # lh middleware url
  FRONTEND_ENABLED_MODULES: COMPANY,LH,SSO,USERS,PXBACKUP,PXLICENSE,PXMETRICS
  LIGHT_HOUSE_TYPE: PRODUCTION                      # PRODUCTION always
  PX_BACKUP_ENDPOINT: '$backup_service_endpoint'
  PX_BACKUP_ORGID: '$PX_BACKUP_ORGANIZATION'                           # PX-Backup org - always 0
  APACHE_RUN_GROUP: www-data
  APACHE_RUN_USER: www-data
  APP_DEBUG: "true"
  APP_DOMAIN: '$INGRESS_ENDPOINT'/pxcentral
  APP_ENV: local
  APP_KEY: base64:J1RH3W4+CILq3/eac9zqYbAMzeptqCJgR9KcWRdhtHw=
  APP_LOG: errorlog
  APP_NAME: Portworx
  BACKEND_HOSTNAME: '$INGRESS_ENDPOINT'/backend
  FRONTEND_HOSTNAME: '$INGRESS_ENDPOINT'/pxcentral
  FRONTEND_GRAFANA_URL: http://'$pxcGrafanaEndpoint'/grafana
  BROADCAST_DRIVER: log
  CACHE_DRIVER: file
  DB_CONNECTION: mysql
  DB_DATABASE: pxcentral
  DB_HOST: pxc-mysql
  DB_PASSWORD: singapore
  DB_PORT: "3306"
  DB_USERNAME: root
  LOG_CHANNEL: stack
  PX_LICENSE_SERVER: '$license_servers'
  PX_LICENSE_PASSWORD: '$LICENSEADMINPASSWORD'
  PX_LICENSE_USER: admin
  PX_STATUS_ENDPOINT: '$pxc_status_endpoint'
  QUEUE_CONNECTION: sync
  SESSION_DRIVER: file
  SESSION_LIFETIME: "120"
  OIDC_AUTHSERVERURL: http://'$OIDCENDPOINT'/realms/master
  OIDC_CLIENT_ID: '$PXC_OIDC_CLIENT_ID'
  OIDC_CLIENT_SECRET: '$PXC_OIDC_CLIENT_SECRET'
  OIDC_CLIENT_CALLBACK: http://'$INGRESS_ENDPOINT'/pxcentral/landing/oauth/oidc
  OIDC_REDIRECTURI: http://'$INGRESS_ENDPOINT'/pxcentral/landing/oauth/oidc
' > $with_ingress_backend_config

  if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
    kubectl --kubeconfig=$KC apply -f $with_dns_backend_config --namespace $PXCNAMESPACE &>/dev/null
  elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
    kubectl --kubeconfig=$KC apply -f $with_ingress_backend_config --namespace $PXCNAMESPACE &>/dev/null
  else
    kubectl --kubeconfig=$KC apply -f $backend_config --namespace $PXCNAMESPACE &>/dev/null    
  fi

  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  sleep 10
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-backend" 2>&1| grep -v NAME | awk '{print $1}') &>/dev/null
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-frontend" 2>&1| grep -v NAME | awk '{print $1}') &>/dev/null
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-central-lh-middleware" 2>&1| grep -v NAME | awk '{print $1}') &>/dev/null
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"

  if [ "$PX_METRICS_DEPLOY" == "true" ]; then
    grafana_config="/tmp/grafana-ini.yaml"
cat <<< '
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-ini-config
  namespace: '$PXCNAMESPACE'
  labels:
    grafana: portworx
data:
  grafana.ini: |
    [users]
    auto_assign_org_role = Admin
    [server]
    domain = '$pxcGrafanaEndpoint'
    root_url = "%(protocol)s://%(domain)s/"
    enforce_domain = false

    [auth.basic]
    disable_login_form= true
    oauth_auto_login= true

    [auth.generic_oauth]
    enabled= true
    client_id= '$PXC_OIDC_CLIENT_ID'
    name= "OIDC"
    client_secret= '$PXC_OIDC_CLIENT_SECRET'
    auth_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/auth 
    token_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/token 
    api_url= http://'$OIDCENDPOINT'/realms/master/protocol/openid-connect/userinfo 
    redirect_uri= http://'$pxcGrafanaEndpoint'/login/generic_oauth
    allowed_domains= 
    allow_sign_up= true
' > $grafana_config

  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  kubectl --kubeconfig=$KC apply -f $grafana_config --namespace $PXCNAMESPACE &>/dev/null
  kubectl --kubeconfig=$KC delete pod --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pod --namespace $PXCNAMESPACE 2>&1 | grep "pxc-grafana" 2>&1 | grep -v NAME | awk '{print $1}') &>/dev/null
  showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Keycloak-- to be ready (4/7)"
  fi

  OIDC_USER_ACCESS_TOKEN=`curl -s --data "grant_type=password&client_id=$PXC_OIDC_CLIENT_ID&username=$KEYCLOAK_FRONTEND_USERNAME&password=$KEYCLOAK_FRONTEND_PASSWORD&token-duration=$OIDC_USER_AUTH_TOKEN_EXPIARY_DURATION" http://$OIDCENDPOINT/realms/master/protocol/openid-connect/token | jq -r ".access_token"`
  if [ "$OIDC_USER_ACCESS_TOKEN" == "null" ]; then
    echo ""
    echo "ERROR: Falied to fetch PX-Central-Onprem OIDC admin user access token."
    echo "Contact: support@portworx.com"
    echo ""
    exit 1
  fi
fi

deploymentready="0"
timecheck=0
count=0
while [ $deploymentready -ne "1" ]
  do
    onpremdeployment=`kubectl --kubeconfig=$KC get deployment pxcentral-onprem-operator --namespace $PXCNAMESPACE 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    onpremdeploymentocp=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $2}' | grep -v READY | grep "2/2" | wc -l 2>&1`
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [ "$onpremdeploymentocp" -eq "1" ]; then
        deploymentready="1"
        break
      fi
    elif [ "$onpremdeployment" -eq "1" ]; then
      deploymentready="1"
      break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (4/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      operatorPodName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxcentral-onprem-operator" | awk '{print $1}' | grep -v NAME 2>&1`
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Operator-- to be ready (5/7)"
if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
  kubectl --kubeconfig=$KC create secret generic $BACKUP_OIDC_ADMIN_SECRET_NAME --from-literal=PX_BACKUP_ORG_TOKEN=$OIDC_USER_ACCESS_TOKEN --namespace $PX_BACKUP_NAMESPACE &>/dev/null
  backupready="0"
  timecheck=0
  count=0
  while [ $backupready -ne "1" ]
    do
      pxcbackupdeploymentready=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE px-backup 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
      pxcbackupdeploymentreadyocp=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE px-backup 2>&1 | awk '{print $3}' | grep -v CURRENT | grep "1" | wc -l 2>&1`
      if [ "$OPENSHIFTCLUSTER" == "true" ]; then
        if [ "$pxcbackupdeploymentreadyocp" -eq "1" ]; then
          backupready="1"
          break
        fi 
      elif [ "$pxcbackupdeploymentready" -eq "1" ]; then
        backupready="1"
        break
      fi
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-PX-Backup-- to be ready (5/7)"
      sleep $SLEEPINTERVAL
      timecheck=$[$timecheck+$SLEEPINTERVAL]
      if [ $timecheck -gt $TIMEOUT ]; then
        echo ""
        echo "ERROR: PX-Central PX-Backup is not ready, Contact: support@portworx.com"
        echo ""
        exit 1
      fi
    done
  backup_pod=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep px-backup | awk '{print $1}' 2>&1`
  if [ "$OIDCENABLED" == "false" ]; then
    kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl create organization --name $PX_BACKUP_ORGANIZATION" &>/dev/null
  else
    kubectl --kubeconfig=$KC exec -it $backup_pod --namespace $PXCNAMESPACE -- bash -c "./pxbackupctl/linux/pxbackupctl create organization --name $PX_BACKUP_ORGANIZATION --authtoken $OIDC_USER_ACCESS_TOKEN" &>/dev/null
  fi
fi

pxcdbready="0"
POD=$(kubectl --kubeconfig=$KC get pod -l app=pxc-mysql --namespace $PXCNAMESPACE -o jsonpath='{.items[0].metadata.name}' 2>&1);
mysqlRootPassword="singapore"
timecheck=0
count=0
while [ $pxcdbready -ne "1" ]
  do
    pxcdbdeploymentready=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-mysql 2>&1 | awk '{print $2}' | grep -v READY | grep "1/1" | wc -l 2>&1`
    pxcdbdeploymentreadyocp=`kubectl --kubeconfig=$KC get deployment --namespace $PXCNAMESPACE pxc-mysql 2>&1 | awk '{print $3}' | grep -v CURRENT | grep "1" | wc -l 2>&1`
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [ "$pxcdbdeploymentreadyocp" -eq "1" ]; then
        dbrunning=`kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- /etc/init.d/mysql status 2>&1 | grep "running" | wc -l 2>&1`
        if [ "$dbrunning" -eq "1" ]; then
          kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- mysql --host=127.0.0.1 --protocol=TCP -u root -psingapore pxcentral < $PXCDB &>/dev/null
          pxcdbready="1"
          break
        fi
      fi 
    elif [ "$pxcdbdeploymentready" -eq "1" ]; then
      dbrunning=`kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- /etc/init.d/mysql status 2>&1 | grep "running" | wc -l 2>&1`
      if [ "$dbrunning" -eq "1" ]; then
        kubectl --kubeconfig=$KC exec -it $POD --namespace $PXCNAMESPACE -- mysql --host=127.0.0.1 --protocol=TCP -u root -psingapore pxcentral < $PXCDB &>/dev/null
        pxcdbready="1"
        break
      fi
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Cluster-Store-- to be ready (5/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      podName=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep "pxc-mysql" | awk '{print $1}' | grep -v NAME 2>&1`
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

showMessage "Waiting for PX-Central required components --PX-Central-Cluster-Store-- to be ready (6/7)"
postsetupjob="0"
timecheck=0
count=0
while [ $postsetupjob -ne "1" ]
  do
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    count=$[$count+1]
    if [ "$count" -eq "1" ]; then
      kubectl --kubeconfig=$KC delete job pxc-post-setup --namespace $PXCNAMESPACE &>/dev/null
      sleep 5
    fi
    pxcpostsetupjob=`kubectl --kubeconfig=$KC get jobs --namespace $PXCNAMESPACE pxc-post-setup 2>&1 | awk '{print $2}' | grep -v COMPLETIONS | grep "1/1" | wc -l 2>&1`
    pxcpostsetupjobocp=`kubectl --kubeconfig=$KC get jobs --namespace $PXCNAMESPACE pxc-post-setup 2>&1 | awk '{print $2}' | grep -v SUCCESSFUL | grep "1" | wc -l 2>&1`
    backend=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-central-backend" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
    frontend=`kubectl --kubeconfig=$KC get pods --namespace $PXCNAMESPACE 2>&1 | grep -i "pxc-central-frontend" | awk '{print $2}' | grep "1/1" | wc -l 2>&1`
    CHECKOIDCENABLE=`kubectl --kubeconfig=$KC get cm --namespace $PXCENTRALNAMESPACE pxc-admin-user -o jsonpath={.data.oidc} 2>&1`
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [[ "$CHECKOIDCENABLE" == "true" && "$pxcpostsetupjobocp" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
        break
      fi
    elif [[ "$CHECKOIDCENABLE" == "true" && "$pxcpostsetupjob" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
      break
    fi
    if [ "$OPENSHIFTCLUSTER" == "true" ]; then
      if [[ "$pxcpostsetupjobocp" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
        postsetupjob="1"
        showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
        break
      fi
    elif [[ "$pxcpostsetupjob" -eq "1" && "$backend" -eq "1" && "$frontend" -eq "1" ]]; then
      postsetupjob="1"
      showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (7/7)"
      break
    fi
    showMessage "Waiting for PX-Central required components --PX-Central-Onprem-Post-Install-Checks-- to be ready (6/7)"
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $TIMEOUT ]; then
      echo ""
      echo "ERROR: PX-Central deployment is not ready, Contact: support@portworx.com"
      echo ""
      exit 1
    fi
  done

echo ""
echo -e -n "PX-Central cluster deployment complete."

echo ""
echo ""
echo "+================================================+"
echo "SAVE THE FOLLOWING DETAILS FOR FUTURE REFERENCES"
echo "+================================================+"
if [ "$DOMAIN_SETUP_REQUIRED" == "true" ]; then
  url="http://$PXC_FRONTEND"
elif [ "$INGRESS_SETUP_REQUIRED" == "true" ]; then
  url="http://$INGRESS_ENDPOINT/pxcentral"
else
  url="http://$PXENDPOINT:$PXC_UI_EXTERNAL_PORT/pxcentral"
fi
echo "PX-Central User Interface Access URL : $url"
timecheck=0
while true
  do
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)
    if [[ "$status_code" -eq 200 ]] ; then
      echo -e -n ""
      break
    fi
    showMessage "Validating PX-Central endpoint access."
    sleep $SLEEPINTERVAL
    timecheck=$[$timecheck+$SLEEPINTERVAL]
    if [ $timecheck -gt $LBSERVICETIMEOUT ]; then
      echo ""
      echo "ERROR: Failed to check PX-Central endpoint accessible, Contact: support@portworx.com"
      echo ""
      break
    fi
  done
echo ""
echo -e -n ""

if [ "$OIDCENABLED" == "false" ]; then
  if [[ ( ${ADMINEMAIL} = "pxadmin@portworx.com" ) && ( ${ADMINUSER} = "pxadmin" ) ]]; then
    echo "PX-Central admin user name: $ADMINEMAIL"
    echo "PX-Central admin user password: $ADMINPASSWORD"
    echo ""
    if [ "$PX_METRICS_DEPLOY" == "true" ]; then
      echo "PX-Central grafana admin user name: $ADMINEMAIL"
      echo "PX-Central grafana admin user password: $ADMINPASSWORD"
    fi
    if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
      echo ""
      echo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
    fi
  else if [ $ADMINUSER == "admin" ]; then
      echo "PX-Central admin user name: $ADMINEMAIL"
      echo "PX-Central admin user password: $ADMINPASSWORD"
      echo ""
      if [ "$PX_METRICS_DEPLOY" == "true" ]; then
        echo "PX-Central grafana admin user name: $ADMINUSER"
        echo "PX-Central grafana admin user password: admin"
        echo "Note: Change Grafana Admin User Password to '$ADMINPASSWORD' from Grafana"
      fi
      if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
        echo ""
        echo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
      fi
    fi
  fi
else
  echo ""
  echo "OIDC enabled, Use OIDC user credentials to access PX-Central UI."
  if [ "$PX_BACKUP_DEPLOY" == "true" ]; then
    echo "PX-Central PX-Backup Organization ID: $PX_BACKUP_ORGANIZATION"
  fi
  if [ "$PXCPROVISIONEDOIDC" == "true" ]; then
    echo "Keycloak Endpoint: http://$OIDCENDPOINT"
    echo "Keycloak admin user: $KEYCLOAK_FRONTEND_USERNAME"
    echo "Keycloak admin password: $KEYCLOAK_FRONTEND_PASSWORD"
    echo "OIDC CLIENT ID: $PXC_OIDC_CLIENT_ID, OIDC CLIENT SECRET: $PXC_OIDC_CLIENT_SECRET, OIDC ENDPOINT: $OIDCENDPOINT"
  fi
fi
echo "+================================================+"
echo ""

central_deployment_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster deployment time taken: $central_deployment_time minutes."
echo ""
