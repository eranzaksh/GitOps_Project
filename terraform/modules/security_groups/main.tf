locals {
  inbound_ports = [443]
}

resource "aws_security_group" "lb_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = local.inbound_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  tags = {
    Name = "lb_sg"
  }
}

# Security Group for Frontend Pods
resource "aws_security_group" "frontend_pod_sg" {
  name_prefix = "frontend-pod-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = [aws_security_group.lb_sg.id]
  }

  tags = {
    Name = "frontend-pod-sg"
  }
}

# Security Group for Backend Pods
resource "aws_security_group" "backend_pod_sg" {
  name_prefix = "backend-pod-sg"
  vpc_id      = var.vpc_id

  # Allow inbound traffic only from frontend pods
  ingress {
    from_port                = 5005
    to_port                  = 5005
    protocol                 = "tcp"
    cidr_blocks = [aws_security_group.frontend_pod_sg.id]
  }

  # Allow outbound DNS traffic
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "backend-pod-sg"
  }
}
