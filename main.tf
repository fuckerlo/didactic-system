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
provider "ansible" {
}
provider "alicloud" {
	access_key = "LTAI5tCWCZozc13cm4YsXZuU"
        secret_key = "v7CBTYeowvR9ztFZUvktWUp1yK9ZK1"
        region = "cn-beijing"
}

resource "ansible_host" "salt-proxy" {
  count = 1

  // 配置机器的 hostname，一般配置为计算资源的 public_ip (或 private_ip)
  inventory_hostname  = "39.103.71.91"

  // 配置机器所属分组
  groups = ["salt-proxy"]

  // 传给 ansible 的 vars，可在 playbook 文件中引用
  vars = {
    wait_connection_timeout   = 60
    proxy_private_ip          = "172.27.159.213"
    proxy_docker_tag          = var.proxy_docker_tag
  }
}
