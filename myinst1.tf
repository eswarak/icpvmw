# Configure the VMware vSphere Provider
provider "vsphere" {
    vsphere_server = "${var.vsphere_vcenter}"
    user = "${var.vsphere_user}"
    password = "${var.vsphere_password}"
    allow_unverified_ssl = true
}

# Build Proxy and Worker Nodes
resource "vsphere_virtual_machine" "myICp" {
    count  = "${var.instance_count - 1}"
    name   = "${var.projectname}${count.index + 1}"
    vcpu   = "${var.vcpu}"
    memory = "${var.memory}"
    domain = "${var.domain}"
    datacenter = "${var.vsphere_datacenter}"
    cluster = "${var.vsphere_cluster}"
    resource_pool = "${var.vsphere_cluster}/Resources/${var.vsphere_resourcepool}"

    # Define the Networking settings for the VM
    network_interface {
        label = "${var.vmnetlabel}"
        ipv4_gateway = "${var.vmaddr_gateway}"
        ipv4_address = "${var.vmaddrbase}${var.vmaddr_start + count.index}"
        ipv4_prefix_length = "${var.vmaddr_netmask}"
    }

    dns_servers = ["${var.vmdns1}", "${var.vmdns2}"]

    # Define the Disks and resources. The first disk should include the template.
    disk {
        datastore = "${var.datastore}"
        template = "${var.template}"
        type ="thin"
    }
	
    disk {
         name = "disk-${var.projectname}${count.index + 1}"
         size = "${var.disk}"
         datastore = "${var.datastore}"
         type ="thin"
    }

    # Define Time Zone
    time_zone = "America/Chicago"
	
}

# Build Boot and Master Node
resource "vsphere_virtual_machine" "myICp-master" {
    depends_on = ["vsphere_virtual_machine.myICp"]
    name   = "${var.projectname}${var.instance_count}"
    vcpu   = "${var.vcpu}"
    memory = "${var.memory}"
    domain = "${var.domain}"
    datacenter = "${var.vsphere_datacenter}"
    cluster = "${var.vsphere_cluster}"
    resource_pool = "${var.vsphere_cluster}/Resources/${var.vsphere_resourcepool}"

    # Define the Networking settings for the VM
    network_interface {
        label = "${var.vmnetlabel}"
        ipv4_gateway = "${var.vmaddr_gateway}"
        ipv4_address = "${var.vmaddrbase}${var.vmaddr_start + var.instance_count - 1}"
        ipv4_prefix_length = "${var.vmaddr_netmask}"
    }

    dns_servers = ["${var.vmdns1}", "${var.vmdns2}"]

    # Define the Disks and resources. The first disk should include the template.
    disk {
        datastore = "${var.datastore}"
        template = "${var.template}"
        type ="thin"
    }
	
    disk {
         name = "disk-${var.projectname}${var.instance_count}"
         size = "${var.disk}"
         datastore = "${var.datastore}"
         type ="thin"
    }

    # Define Time Zone
    time_zone = "America/Chicago"


#copies the file from terraform machine and copies to EndPoint /tmp directory
  provisioner "file" {
	source = "${var.mysshkey}"
        destination = "/tmp/icpsshkey"
        connection {
                type = "ssh"
                user = "root"
                private_key = "${file(var.mysshkey)}"
         }
    }
	
  provisioner "file" {
	source = "./icpinst.zip"
        destination = "/tmp/icpinst.zip"
        connection {
                type = "ssh"
                user = "root"
                private_key = "${file(var.mysshkey)}"
         }
    }


  provisioner "file" {
	source = "./ibm-cloud-private-x86_64-1.2.0.tar.gz"
        destination = "/tmp/ibm-cloud-private-x86_64-1.2.0.tar.gz"
        connection {
                type = "ssh"
                user = "root"
                private_key = "${file(var.mysshkey)}"
         }
    }

  provisioner "file" {
	source = "./ibm-cloud-private-installer-1.2.0.tar.gz"
        destination = "/tmp/ibm-cloud-private-installer-1.2.0.tar.gz"
        connection {
                type = "ssh"
                user = "root"
                private_key = "${file(var.mysshkey)}"
         }
    }

#Executes the script on EndPoint
    provisioner "remote-exec" {
        inline = [
		  "echo '${join(",", vsphere_virtual_machine.myICp.*.network_interface.0.ipv4_address)}' > /tmp/test.txt",
		  "echo '${join(",", vsphere_virtual_machine.myICp.*.name)}' > /tmp/test1.txt",
		  "echo ${var.domain} > /tmp/domain.txt",
		  "echo ${vsphere_virtual_machine.myICp-master.network_interface.0.ipv4_address} > /tmp/masterip.txt",
		  "cd /tmp; mkdir icpinstall; cd icpinstall; unzip -q ../icpinst.zip; chmod 755 *; ./masterinstall.sh; cd"
        ]
        connection {
                type = "ssh"
                user = "root"
                private_key = "${file(var.mysshkey)}"
         }
    }
}

output "instance_ips" {
  value = ["${vsphere_virtual_machine.myICp.*.network_interface.0.ipv4_address}"]
}

