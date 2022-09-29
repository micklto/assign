locals {
  ami_id = "ami-09e67e426f25ce0d7"
  vpc_id = "vpc-0d81455fc940062c9"
  ssh_user = "ubuntu"
  key_name = "Demokey"
  private_key_path = "/home/labsuser/assign/Demokey.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAT4GHWILYO45N4IVS"
  secret_key = "FqKgHbYG53uPd2Nd9oG7ddC97YNYR72CBAB2ixVj"
  token = "FwoGZXIvYXdzEKD//////////wEaDPoEbRJ9jA8tNp0oxSKzAY7dQrFVOWYcXnXct5d61kUBwR7t64ZIb+t9nVys5ilg/nRpRXZu7hiBCdp26tLtGThd0W5XR6vlnGRm+wbRc5OpZ2FQlet1tMvXdg5cAi5T3hV8jEpIPonlg8ehW3ZqVDBpq9hlp15/Epd24VGUmqFMf+nvS3HYlZZ7w8jjlINPkLjoC2pV723pcn0PDHdBB5i9W3tKxgsnVO/AuDG/bJdj2K9vQQIlg6WwL/lzeyel2LBZKNjb1pkGMi3YK554hB+Ewgi+1u6t19AfE4KT0to7+SgWqzkubDLp9QldLlmtT8BBgayP6A4="
}

resource "aws_security_group" "demoaccess" {
	name   = "demoaccess"
	vpc_id = local.vpc_id

  ingress {
		from_port   = 22
		to_port     = 22
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

resource "aws_instance" "web" {
  ami = local.ami_id
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids =[aws_security_group.demoaccess.id]
  key_name = local.key_name

  tags = {
    Name = "Demo ec2"
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = local.ssh_user
    private_key = file(local.private_key_path)
    timeout = "4m"
  }

  provisioner "remote-exec" {
    inline = [
      "hostname"
    ]
  }
  
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > myhosts" 
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i myhosts --user ${local.ssh_user} --private-key ${local.private_key_path} wordpress.yml" 
  }

}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

