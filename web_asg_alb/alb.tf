

## traffic --> ALB --> Listners --> Target groups 

# Creating ALB LoadBalancer and adding it to 
# Security Groups and Subnets 
resource "aws_lb" "frontendALB" {
  name = "frontend-alb"
  subnets = data.aws_subnet_ids.selectedvpc_subnets.ids
  security_groups = [ aws_security_group.alb_sg.id]
}

# Configuring ALB listner for http traffic 
resource "aws_lb_listener" "http_listner" {
    load_balancer_arn = aws_lb.frontendALB.arn 
    port = 80
    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
      }
    }    
}


# defining ALB target Group and defining the healthchecks for the ALB target group
# you need to add this resource to ASG group as well, so there would be 
# integration between ALB Target group and ASG 
resource "aws_lb_target_group" "webASG" {
  name = "webasg"
  port = var.webport
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selectedvpc.id

  health_check {
    path = "/"
    port = "8080"
    protocol = "HTTP"
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 15
    matcher = "200"
  }
}


# finally to tie everything we define the ALB listner rules 
# code below adds a listner rule that send requests that match any path to the 
# target group that contains the ASG 
resource "aws_lb_listener_rule" "toasg" {
  listener_arn = aws_lb_listener.http_listner.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webASG.arn
  }
}



# finally output your ALB Public DNS name 

output "ALB_Public_URL" {
  value = aws_lb.frontendALB.dns_name
}

output "ALB_Public_id" {
  value = aws_lb.frontendALB.id
}