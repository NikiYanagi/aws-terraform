#List of Variables for Terraform to use
variable "instanceSize" {
  default = "t2.micro"
}

variable "ingressCIDRblock" {
  type = "list"
  default = [ "0.0.0.0/0" ]
}

variable "egressCIDRblock" {
  type = "list"
  default = [ "0.0.0.0/0" ]
}

variable "protocol" {
  default = "tcp"
}

#Specify the provider
provider "aws" {
  region = "eu-west-1"
  shared_credentials_file = "/home/schosone/.aws/credentials"
}

#AWS_AMI Data Query Type
data "aws_ami" "rhel7" {
  most_recent = true

  filter {
    name = "name"
    values = ["RHEL-7.5_HVM_GA-*"]
  }

  owners = ["309956199498"] #RedHat
}

#data "aws_security_group" "selected" {
#  tags {
#    application = "rabbit"
#    envivronment = "dev"
#  }
#  name = "serana_sg1"
#}

resource "aws_security_group" "allow_all" {
  name = "serana_sg1"

  tags {
    Application = "rebbit"
    Environment = "aws"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "${var.protocol}"
    cidr_blocks = "${var.ingressCIDRblock}"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "${var.protocol}"
    cidr_blocks = "${var.egressCIDRblock}"
  }
}

resource "aws_instance" "sera_rhel7" {
  count = 3
  ami = "${data.aws_ami.rhel7.id}"
  instance_type = "${var.instanceSize}"

  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]

  tags = {
    Name = "Sera-${count.index + 1}"
    role = "test-machine-${count.index + 1}"
    purpose = "be sad"
    }
}

