resource "openstack_compute_flavor_v2" "flavor" {
  name  = "m1.standard"
  ram   = "4096"
  vcpus = "4"
  disk  = "30"
}
