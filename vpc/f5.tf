
resource "random_password" "password" {
  length  = 10
  special = false
}
resource "aws_eip" "mgmt" {
  vpc                       = true
  network_interface         = "${aws_network_interface.nic0.id}"
  associate_with_private_ip = "${aws_network_interface.nic0.private_ip}"
}
resource "aws_eip" "ext" {
  vpc                       = true
  network_interface         = "${aws_network_interface.nic1.id}"
  associate_with_private_ip = "${aws_network_interface.nic1.private_ip}"
}
resource "aws_network_interface" "nic0" {
  subnet_id   = "${aws_subnet.mgmt[0].id}"
  security_groups = ["${aws_security_group.f5.id}"]
  tags = {
    Name = "nic0"
  }
}
resource "aws_network_interface" "nic1" {
  subnet_id   = "${aws_subnet.public[0].id}"
  security_groups = ["${aws_security_group.f5.id}"]
  tags = {
    Name = "nic1"
  }
}
resource "aws_network_interface" "nic2" {
  subnet_id   = "${aws_subnet.private[0].id}"
  tags = {
    Name = "nic2"
  }
}
resource "aws_instance" "f5" {

  #F5 BIGIP-14.1.0.3-0.0.6 PAYG-Good 25Mbps-190326002717
  #ami = "ami-00a9fd893d5d15cf6" #east-us-1 
  ami = "ami-04aeb21365c18ca08" #west-us-2
  network_interface {
    network_interface_id = "${aws_network_interface.nic0.id}"
    device_index         = 0
  }
  network_interface {
    network_interface_id = "${aws_network_interface.nic1.id}"
    device_index         = 1
  }  
  network_interface {
    network_interface_id = "${aws_network_interface.nic2.id}"
    device_index         = 2
  }
  instance_type               = "m5.xlarge"
  #associate_public_ip_address = true
  #subnet_id                   = "${aws_subnet.demo[0].id}"
  #vpc_security_group_ids      = ["${aws_security_group.f5.id}"]
  user_data                   = "${data.template_file.f5_init.rendered}"
  key_name                    = "mikeo-keypair"
  root_block_device { delete_on_termination = true }

  tags = {
    Name = "${var.cluster-name}-f5"
    Env  = "demo"
  }

}
resource "aws_security_group" "f5" {
  name   = "${var.cluster-name}-f5-sg"
  vpc_id = "${aws_vpc.demo.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["${local.workstation-external-cidr}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  #ingress {
  #  from_port   = 8443
  #  to_port     = 8443
  #  protocol    = "tcp"
  #  #cidr_blocks = ["${local.workstation-external-cidr}"]
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "f5_init" {
  template = "${file("../vpc/f5.tpl")}"
  vars = {
    password = "${random_password.password.result}"
  }
}

data "template_file" "tfvars" {
  template = "${file("../as3/terraform.tfvars.example")}"
  vars = {
    password = "${random_password.password.result}"
    address = "${aws_instance.f5.public_ip}"
  }
}
resource "local_file" "tfvars" {
  content  = "${data.template_file.tfvars.rendered}"
  filename = "../as3/terraform.tfvars"
}



