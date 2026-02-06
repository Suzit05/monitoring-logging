provider "aws" {
  region = var.region
}

resource "aws_key_pair" "deployer" {
  key_name = "elk_key"
  public_key = file("/mnt/c/Users/sujee/.ssh/id_rsa.pub")
}

resource "aws_security_group" "elk_sg" {
  name_prefix = "elk_sg"
  ingress {
    from_port = 22 #ssh/admin
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5601 #kibana
    to_port = 5601
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "elk_instance" {
  ami = "ami-073130f74f5ffb161"
  instance_type = "t3.micro"
  key_name = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.elk_sg.id]
  user_data = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  tags = {
    Name = "elk_instance"
  }

}

#copy this all to different folders or add via desktop after done