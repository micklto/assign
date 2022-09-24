locals {
  ami_id = "ami-09e67e426f25ce0d7"
  vpc_id = "vpc-0827c764f71604395"
  ssh_user = "ubuntu"
  key_name = "Demokey"
  private_key_path = "/home/labsuser/assign/Demokey.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAT4GHWILYESSAYGW2"
  secret_key = "s9OqPy0tyw70whNTCTslGB+FLd8ahkQ6qmYQTMMH"
  token = "FwoGZXIvYXdzECoaDLEVFYfRw1CbFP98eyKzAW/huuRiGK/T1d+OmpdNj9cLTMV+pSc0KK5hN4ntd+7UDP2vNfR7L8Z6A25NM1ZsSDmo05xC7QCVRULzdst5eUiiUpsbRzLVZNQ6xZ1S6kh3c4mtvBlBZ3vsW+CUNboUGO8/CvJZFn/monbuvdx0gGdRufyahWks5/pMFOwGqpZgR6aR/XQGHD40KDiIC4L2sm2dxgqfQSC66cJZjD38aZWQtSF7yWpCKKh+AQW8/pCkReN2KKXnvJkGMi2ZJ3UxgcWHlZOKA5RIq/HPUdMQC2oF0QPSqeYyzqfkUuandC2E3fk/ho7ndwE="
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

