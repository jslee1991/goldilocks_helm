resource "openstack_compute_instance_v2" "i01" {
  name            = "1st"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "5"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i02" {
  name            = "2nd"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i03" {
  name            = "3th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i04" {
  name            = "4th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i05" {
  name            = "5nd"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i06" {
  name            = "6th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i07" {
  name            = "7th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i08" {
  name            = "8th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i09" {
  name            = "9th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}

resource "openstack_compute_instance_v2" "i10" {
  name            = "10th"
  image_id        = "fcad4321-757b-4471-a6d8-1e0323f5511f"
  flavor_id       = "4"
  key_pair        = "tech_team2"
  security_groups = ["default"]
  
  network {
    name = "private_network"
  }
}



resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = "${openstack_networking_floatingip_v2.fip.address}"
  instance_id = "${openstack_compute_instance_v2.i01.id}"
}
