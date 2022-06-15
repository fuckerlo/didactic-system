terraform {
  required_providers {
    apsarastack = {
      source = "local-registry/apsara-stack/apsarastack"
      version = "1.126.0"
    }
  }
}
provider "alicloud" {
    access_key      = var.access_key
    secret_key      = var.secret_key
    region          = var.region
    insecure        = true
    skip_region_validation = true
    endpoints   { """ + str_eps_provider + """
    }
}
variable "prefix" {
    type = string
    default = "perftest" #创建实例名前缀
}
variable "access_key" {
    type = string
    default = "LTAI5tCWCZozc13cm4YsXZuU" #混合云环境admin账户下的ak；
}
variable "secret_key" { 
    type = string
    default = "v7CBTYeowvR9ztFZUvktWUp1yK9ZK1" #混合云环境admin账户下的sk；
}
variable "region" {
    type = string
    default = "ch-beijing" #混合云可用区的region，tianji 注册变量获取
}
variable "zone" {
    type = string
    default = "******" #混合云可用区的zone, tianji 注册变量获取
    default = "rds.*.cloud.*.com" #tianji rds-yaochi.rds.openapi.endpoint获取
    }
}

resource "alicloud_db_instance" "rds" {
    count               = var.rds.count
    instance_name       = "${var.prefix}-rds-${count.index}"
    engine              = var.rds.engine[count.index]
    engine_version      = var.rds.engine_version[count.index]
    instance_type       = var.rds.instance_type[count.index]
    instance_storage    = var.rds.storage[count.index]
    vswitch_id          = alicloud_vswitch.vsw[var.rds.vsw[count.index]].id
    zone_id             = var.zone
    monitoring_period   = "60"

    security_ips        = ["0.0.0.0/0"]
    # security_ips        = var.rds.security_ips[count.index]

    depends_on = [
        alicloud_vswitch.vsw
    ]
}

resource "alicloud_db_account" "account" {
    count               = var.account.count
    db_instance_id      = alicloud_db_instance.rds[var.account.rds[count.index]].id
    account_name        = var.account.name[count.index]
    account_password    = var.account.password[count.index]
    depends_on = [
      alicloud_db_instance.rds
    ]
}

resource "alicloud_db_database" "db" {
    count               = var.db.count
    instance_id         = alicloud_db_instance.rds[var.db.rds[count.index]].id
    name                = var.db.name[count.index]
}

resource "alicloud_db_account_privilege" "privilege" {
    count                = var.account.count
    instance_id          = alicloud_db_instance.rds[var.account.rds[count.index]].id
    account_name         = alicloud_db_account.account[count.index].name
    privilege            = "ReadWrite"
    db_names             = [for item in alicloud_db_database.db:item.name if item.instance_id==alicloud_db_account.account[count.index].db_instance_id]
}

variable "rds" {
    type = object({
        count = number
        vsw = list(number)
        storage = list(string)
        instance_type = list(string)
        engine = list(string)
        engine_version = list(string)
    })
    default = {
      count = 0
      vsw = [ 0 ]
      storage = ["50"]
      instance_type = ["rds.mysql.n2.small"]
      engine = ["MySQL"]
      engine_version = ["5.6"]
    }
}

variable "account" {
    type = object({
        count = number
        rds = list(number)
        name = list(string)
        password = list(string)
    })
    default = {
      count = 0
      name = [ "stress" ]
      rds = [ 0 ]
      password = ["Admin123"]
    }
}

variable "db" {
    type = object({
        count = number
        name = list(string)
        rds = list(number)
    })
    default = {
      count = 0
      name = [ "DB1" ]
      rds = [0]
    }
}