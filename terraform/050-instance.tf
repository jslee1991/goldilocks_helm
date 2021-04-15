
resource "openstack_compute_instance_v2" "i01" {
  name            = "G1N1"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 60 seconds' && sleep 60"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i02" {
  depends_on = ["openstack_compute_instance_v2.i01"]
  name            = "G1N2"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i03" {
  depends_on = ["openstack_compute_instance_v2.i02"]
  name            = "G2N1"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i04" {
  depends_on = ["openstack_compute_instance_v2.i03"]
  name            = "G2N2"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i05" {
#  depends_on = ["openstack_compute_instance_v2.i04"]
  name            = "G3N1"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i06" {
#  depends_on = ["openstack_compute_instance_v2.i05"]
  name            = "G3N2"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "3"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i07" {
#  depends_on = ["openstack_compute_instance_v2.i04"]
  name            = "G4N1"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i08" {
  depends_on = ["openstack_compute_instance_v2.i07"]
  name            = "G4N2"
  image_id        = "d2e405fa-41d1-4869-8420-f596d42af5d3"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  user_data   = file("/home/sunje/install.sh")
  provisioner "local-exec" {
    command = "echo 'tf-2.bar sleeping for 40 seconds' && sleep 40"
  }

  network {
    name = "private_network"
  }
}



resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = "${openstack_networking_floatingip_v2.fip.address}"
  instance_id = "${openstack_compute_instance_v2.i01.id}"
}

