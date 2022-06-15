terraform {
	required_providers {
	 ansible ={
	 	source ="nbering/ansible"
	 	version ="1.0.4"
	 }
	 alicloud = {
	 	source ="aliyun/alicloud"
	 	version ="1.99.0"
	 }
	}
}
provider "alicloud" {
	
}
provider "ansible" {
	
}
resource "ansible_host" "salt-proxy" {
  count = 1

  // 配置机器的 hostname，一般配置为计算资源的 public_ip (或 private_ip)
  inventory_hostname  = alicloud_instance.ecsone[count.index].public_ip

  // 配置机器所属分组
  groups = ["salt-proxy"]

  // 传给 ansible 的 vars，可在 playbook 文件中引用
  vars = {
    wait_connection_timeout   = 60
    proxy_private_ip          = alicloud_instance.ecsone[count.index].private_ip
    proxy_docker_tag          = var.proxy_docker_tag
  }
}