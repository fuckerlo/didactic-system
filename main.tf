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
	 docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.13.0"
   }
	}
}
provider "ansible" {
	
}
provider "alicloud" {
	
}
provider "docker" {}
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}
resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "tutorial"
  ports {
 internal = 80
    external = 8000
 }
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
