locals {
  ami_id = "ami-09e67e426f25ce0d7"
  vpc_id = "vpc-0a393a781fb001f71"
  ssh_user = "ubuntu"
  key_name = "Demokey"
  private_key_path = "/home/labsuser/assign/Demokey.pem"
}

provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAT4GHWILYJ6LQDSQE"
  secret_key = "sGYNYtA+70pOffK/Qtet3fSuYqIqNx1zl8AokO0+"
  token = "FwoGZXIvYXdzEGEaDOwfDJzemYnPFOMSYyKzAWBn7XSRgfOxY4hf2ReAcmom4r3jgN3Lyc6r63dzFrOXvm11ebX49v6xcJY8GAifEzPKuLER2XYBnWbQQ5uOFR5qfWo3bNoQ9dxCZC6sXCL1ZbKx+s1KxMG+zTr1peucuqph4IoTN9+oxq5Rq3mtAUQRfLn+cFJweptOIIdzU6FbDJf0QLacpnKdsq5FhqvWSW5dp80wfWJlwc6AbjAXPZ6spL4Ux+CgeC/mMeWyPWNRpf9rKO30yJkGMi3EdecFmnVIhywpFN35JRdvFfe5hpj0gzgBHU4eP6J5PmuPWnQEW6VPGvO6zAg="
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

