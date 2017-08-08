# icpvmw
This installs IBM Cloud private to a VMware environment. 

**Assumptions**
- Access to VMware vcenter
- Templates of Ubuntu 16.04 LTS or RHEL 7.1/7.2/7.3 ( Even though not supported, tested on CentOS7)
- The templates have a public sshkey included and the corresponsding private sshkey is available
- IBM Cloud private images are available.
- Terraform is download and available ( It can be downloaded from https://www.terraform.io/downloads.html )
- The templates can access OS repository when cloned
- Docker Images repository is accessible

**Procedure**
To kick off installing the ICp cluster, edit variables.tf and replace 'xxx..' with appropriate values. The various required values are tabulated below

| Variable Name | Example Value | Description |
| ------------- | ------------- | ----------- |
| vsphere\_vcenter | 192.168.20.1 | VMware vCenter IPAddress or Hostname |
| vsphere\_user | root | User to access vCenter with sufficient roles |
| vsphere\_password | mypassw0rd | User password to authenticate to vCenter |
| vsphere\_datacenter | mydc | VMware Data Center Name |
| vsphere\_cluster | mycluster | VMware Cluster Name |
| vsphere\_resourcepool | myresourcepool | VMware resource pool name |
| instance\_count | 5 | Number VMs that are going to be created |
| datastore | datastore1 | VMware Datastore Name |
| template | ubuntu16\_template | VMware Template Name |
| vcpu | 2 | Number of virtual CPUS per VM |
| memory | 8192 | Memory of each vm in MB |
| disk | 100 | Additional disk size that will be added |
| vmdns1 | 8.8.8.8 | DNS Server IPAddress |
| vmdns2 | 192.168.254.254 | DNS Server IPAddress |
| vmnetlabel | VM Network | VMware Port Group Name |
| vmaddrbase | 192.168.21. | First three octets of the static address range to be used |
| vmaddr\_netmask | 255.255.255.0 | Netmask |
| vmaddr\_gateway | 192.168.21.1 | Gateway address |
| vmaddr\_start | 20 | Last octet of the static ipaddress |
| domain | mydomain.net | Domain Name for the machines |
| projectname | myvm | VM names prefix as they appear in vCenter |
| mysshkey | \~/.ssh/xxxx.rsa | private sshkey that will eb used to connect to the VMs |

- As part of deployment, the script checks if the ipaddress is DNS resolvable and sets the hostname accordingly. If the ipaddress is not resolvable, the hostnames will be projectnamex.domain ( Example: if projectname is myvm and domain is mydomain.net, the hostnames will be appear as myvm1.mydomain.net, myvm2.mydomain.net..)
- Need continous ip addresses to be set. ( Example: addrbase is 192.168.21. and vmaddr\_start is 21, instance\_count is 5, the ipaddress of the vms will be set as 192.168.21.21, 192.168.21.22,..)
- Download the files from the git repository to a local filesystem
- Copy IBM Cloud private images to the same directory 

```
Example:
ibm-cloud-private-installer-1.2.0.tar.gz  ibm-cloud-private-x86_64-1.2.0.tar.gz  icpinst.zip  myinst1.tf  variables.tf
```

- Test the temaples
  terraform plan
- Deploy the Product
  terraform apply
- Delete
  terraform destroy -force ( from same directory where apply was run )
  
 ** End **

