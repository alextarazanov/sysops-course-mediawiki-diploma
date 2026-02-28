resource "yandex_vpc_gateway" "gateway" {
  name        = "wikimedia-gateway"
  description = "NAT gateway for wikimedia-network"

  labels = {
    project = "wikimedia"
  }

  shared_egress_gateway {}
}

resource "yandex_vpc_network" "network" {
  name        = "wikimedia-network"
  description = "Network for Wikimedia project infrastructure"

  labels = {
    project = "wikimedia"
  }
}

resource "yandex_vpc_route_table" "route_table" {
  name        = "wikimedia-route-table"
  description = "Route table for wikimedia-network. Add default way via NAT gateway"
  network_id  = yandex_vpc_network.network.id

  labels = {
    project = "wikimedia"
  }

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "wikimedia-subnet"
  description    = "Subnet for Wikimedia project infrastructure"
  network_id     = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.route_table.id
  v4_cidr_blocks = ["192.168.0.0/28"]

  labels = {
    project = "wikimedia"
  }
}

resource "yandex_vpc_security_group" "security_group" {
  name        = "wikimedia-security-group"
  description = "Security group for Wikimedia project infrustructure"
  network_id  = yandex_vpc_network.network.id

  labels = {
    project = "wikimedia"
  }

  ingress {
    description    = "Allow income SSH connection"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow income HTTP connection"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description    = "Allow income zabbix connection"
    protocol       = "TCP"
    from_port      = 10050
    to_port        = 10051
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description       = "Allow all income traffic from security group itself"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    description    = "Allow all outcome traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_disk" "boot_disk" {
  for_each    = var.instances
  name        = "boot-disk-${each.key}"
  description = "Boot disk for vm-${each.key}"
  image_id    = var.disk_image
  size        = 20
  type        = "network-hdd"

  labels = {
    project = "wikimedia"
  }
}


resource "yandex_compute_instance" "vm" {
  for_each                  = var.instances
  name                      = "vm-${each.key}"
  description               = "VM for Wikimedia infrastructure"
  hostname                  = "vm-${each.key}"
  platform_id               = "standard-v3"
  allow_stopping_for_update = var.is_test

  labels = {
    project = "wikimedia"
  }

  metadata = {
    user-data = fileexists("${path.module}/metadata.yml.tmp") ? file("${path.module}/metadata.yml.tmp") : ""
  }

  scheduling_policy {
    preemptible = var.is_test
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot_disk[each.key].id
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = each.value
    security_group_ids = toset([yandex_vpc_security_group.security_group.id])
  }

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }
}
