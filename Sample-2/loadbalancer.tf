resource "aws_lb_target_group" "targetGroup" {
  name     = "targetGroup-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-1.id
  health_check {
      path  = "/index.html"
  }
}

resource "aws_lb_target_group_attachment" "attachment" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.targetGroup.arn
  target_id        = aws_instance.instance.*.id[count.index]
  port             = 80
}

resource "aws_lb" "loadBalancer" {
  name               = "loadBalancer-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sgIngressHTTP.id,
                        aws_security_group.sgEgressInternet.id]
  subnets            = [for subnet in aws_subnet.subnets: subnet.id]
  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.loadBalancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetGroup.arn
  }
}
