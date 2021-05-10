resource "openstack_networking_floatingip_v2" "fip1" {
  pool             = "public_network"
}
resource "openstack_networking_floatingip_v2" "fip2" {
  pool             = "public_network"
}
resource "openstack_networking_floatingip_v2" "fip3" {
  pool             = "public_network"
}
resource "openstack_networking_floatingip_v2" "fip4" {
  pool             = "public_network"
}
