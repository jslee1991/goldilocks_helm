resource "openstack_networking_secgroup_rule_v2" "secgroup_tcp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${var.secgroup-default}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_udp" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "udp"
  port_range_min = 1
  port_range_max = 65535
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${var.secgroup-default}"
}
