terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
  profile = "eran"
}


data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
resource "aws_security_group" "leumi-apache-sg" {
  name        = "leumi-apache-sg"
  
  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["91.231.246.50/32"]
  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "leumi_apache_eip" {
  instance = aws_instance.leumi-apache.id
}

resource "aws_instance" "leumi-apache" {
  ami = "ami-075449515af5df0d1"
  instance_type = "t3.micro"
  user_data = "${file("./apache.sh")}"
  key_name = "eranssh"
  tags = {
    "Name" = "EC2 Apache"
  }
  vpc_security_group_ids = [ aws_security_group.leumi-apache-sg.id ]
}


resource "aws_lb" "leumi" {
  name               = "nlb-leumi"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.leumi-apache-sg.id]
  subnets            = data.aws_subnets.default_vpc_subnets.ids
}

resource "aws_lb_target_group" "leumi-tg" {
  name        = "leumi-tg"
  port        = 80                          
  protocol    = "TCP"                  
  target_type = "instance"
  vpc_id      = data.aws_vpc.default.id             
}

resource "aws_lb_target_group_attachment" "leumi-attachment" {
  target_group_arn = aws_lb_target_group.leumi-tg.arn
  target_id        = aws_instance.leumi-apache.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.leumi.arn
  port              = 80                     
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.leumi-tg.arn
  }
}