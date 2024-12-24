resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = [var.public1, var.public2]
}

resource "aws_lb_target_group" "test-tg" {
  name        = "test-tg"
  port        = 80                          # The port ALB will route traffic to
  protocol    = "HTTP"
  vpc_id      = var.vpc_id                   
  target_type = "instance"             
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80                     # The port on which the ALB listens for traffic
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.test-tg.arn
  }
}
