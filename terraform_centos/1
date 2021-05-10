resource "openstack_networking_network_v2" "network" {
  name = "private_network2"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name = "private_subnet2"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr = "20.0.0.0/24"
  dns_nameservers = ["168.126.63.1"]
}

resource "openstack_networking_router_interface_v2" "interface" {
  router_id = "${var.router-external}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}
