# get the default vpc 
data "aws_vpc" "selectedvpc" {
  default  = true
}

data "aws_subnet_ids" "selectedvpc_subnets" {
  vpc_id = data.aws_vpc.selectedvpc.id
  
}
output "selectedvpc_subnets" {
  value = data.aws_subnet_ids.selectedvpc_subnets
}


resource "aws_launch_configuration" "as_webconf_v1" {
  name          = "web_config"
  image_id      = data.aws_ami.amazon_ami.image_id
  instance_type = var.instance_type
  security_groups = [ aws_security_group.web_sg.id  ]
  key_name = "tf_deployer"
  user_data = <<-EOF
            #!/bin/bash
            curl -s -O https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64
            mv busybox-x86_64 busybox
            chmod +x busybox
            mv busybox /usr/local/bin
            echo "hello world" > index.html
            nohup busybox httpd -f -p ${var.webport} & 
            EOF
  # this is needed because terraform deletes the resource and then creates new
  # but in this case,if we try to modify the launch configuration, deletion wont happenn
  # becasue it is tied to ASG
  # in this case it creates and then destroys 
  lifecycle {
    create_before_destroy = true
  }
  spot_price    = data.aws_ec2_spot_price.example.spot_price
}

output "name" {
  value = aws_launch_configuration.as_webconf_v1
}

resource "aws_autoscaling_group" "webservers" {
  #tags = var.tags 
  max_size = 3
  min_size = 2
  vpc_zone_identifier = data.aws_subnet_ids.selectedvpc_subnets.ids
  launch_configuration = aws_launch_configuration.as_webconf_v1.id
  
  target_group_arns = [ aws_lb_target_group.webASG.arn ]
  health_check_type = "ELB" # default is EC2 
  tags = [ var.tags ]
}


