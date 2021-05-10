
resource "openstack_compute_instance_v2" "i01" {
  name            = "OKD_MASTER"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i02" {
  depends_on = ["openstack_compute_instance_v2.i01"]
  name            = "OKD_WORKER1"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i03" {
  depends_on = ["openstack_compute_instance_v2.i02"]
  name            = "OKD_WORKER2"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i04" {
  depends_on = ["openstack_compute_instance_v2.i03"]
  name            = "OKD_WORKER3"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]

  network {
    name = "private_network"
  }
}

#resource "openstack_compute_instance_v2" "i05" {
##  depends_on = ["openstack_compute_instance_v2.i04"]
#  name            = "G3N1"
#  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
#  flavor_id       = "3"
#  key_pair        = "tech_team2"
#  security_groups = ["default"]
#  user_data   = file("/home/sunje/install.sh")
#  provisioner "local-exec" {
#    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
#  }
#
#  network {
#    name = "private_network"
#  }
#}
#
#resource "openstack_compute_instance_v2" "i06" {
##  depends_on = ["openstack_compute_instance_v2.i05"]
#  name            = "G3N2"
#  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
#  flavor_id       = "3"
#  key_pair        = "tech_team2"
#  security_groups = ["default"]
#  user_data   = file("/home/sunje/install.sh")
#  provisioner "local-exec" {
#    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
#  }
#
#  network {
#    name = "private_network"
#  }
#}
#
#resource "openstack_compute_instance_v2" "i07" {
##  depends_on = ["openstack_compute_instance_v2.i04"]
#  name            = "G4N1"
#  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
#  flavor_id       = "4"
#  key_pair        = "tech_team2"
#  security_groups = ["default"]
#  user_data   = file("/home/sunje/install.sh")
#  provisioner "local-exec" {
#    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
#  }
#
#  network {
#    name = "private_network"
#  }
#}
#
#resource "openstack_compute_instance_v2" "i08" {
#  depends_on = ["openstack_compute_instance_v2.i07"]
#  name            = "G4N2"
#  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
#  flavor_id       = "4"
#  key_pair        = "tech_team2"
#  security_groups = ["default"]
#  user_data   = file("/home/sunje/install.sh")
#  provisioner "local-exec" {
#    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
#  }
#
#  network {
#    name = "private_network"
#  }
#}



resource "openstack_compute_floatingip_associate_v2" "fip1" {
  floating_ip = "${openstack_networking_floatingip_v2.fip1.address}"
  instance_id = "${openstack_compute_instance_v2.i01.id}"
}
resource "openstack_compute_floatingip_associate_v2" "fip2" {
  floating_ip = "${openstack_networking_floatingip_v2.fip2.address}"
  instance_id = "${openstack_compute_instance_v2.i02.id}"
}
resource "openstack_compute_floatingip_associate_v2" "fip3" {
  floating_ip = "${openstack_networking_floatingip_v2.fip3.address}"
  instance_id = "${openstack_compute_instance_v2.i03.id}"
}
resource "openstack_compute_floatingip_associate_v2" "fip4" {
  floating_ip = "${openstack_networking_floatingip_v2.fip4.address}"
  instance_id = "${openstack_compute_instance_v2.i04.id}"
}


