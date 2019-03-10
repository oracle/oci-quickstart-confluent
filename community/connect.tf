resource "oci_core_instance" "connect" {
  display_name        = "connect-${count.index}"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  shape               = "${var.broker["shape"]}"
  subnet_id           = "${oci_core_subnet.public_subnet.id}"

  source_details {
    source_id   = "${var.images[var.region]}"
    source_type = "image"
  }

  create_vnic_details {
    subnet_id      = "${oci_core_subnet.public_subnet.id}"
    hostname_label = "connect-${count.index}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"

    user_data = "${base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      file("../scripts/connect.sh")
    )))}"
  }

  count = "${var.connect["node_count"]}"
}

output "Kafka Connect Public IPs" {
  value = "${join(",", oci_core_instance.connect.*.public_ip)}"
}