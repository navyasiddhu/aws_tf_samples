data "aws_ami" "amazon_ami" {
  most_recent = true
  #name_regex = "^myami-\\d{3}""
  #name_regex = "^ubuntu"
  name_regex = "^amzn2"
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
    filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  
  owners = ["137112412989"] # amazon owner id
  #owners = ["099720109477"] # Ubuntu owner id
}


output "AWS_AMIs" {
  value = data.aws_ami.amazon_ami.image_id
}


resource "aws_instance" "ec2_test" {
  associate_public_ip_address = true
  ami = data.aws_ami.amazon_ami.image_id
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]
  user_data = <<-EOF
            #!/bin/bash
            curl -s -O https://busybox.net/downloads/binaries/1.28.1-defconfig-multiarch/busybox-x86_64
            mv busybox-x86_64 busybox
            chmod +x busybox
            mv busybox /usr/local/bin
            echo "hello world" > index.html
            nohup busybox httpd -f -p ${var.webport} & 
            EOF
  tags = var.tags
  key_name = "tf_deployer"
}

resource "aws_security_group" "web_sg" {
  name = "allow ${var.webport}"
  tags = var.tags
  ingress {
    cidr_blocks = [ var.public_cidr]
    description = "allow ${var.webport}"
    from_port = var.webport
    to_port = var.webport
    protocol = "tcp"        
    #from_port = 0
    #to_port = 0
    #protocol = -1
  } 

  ingress {
    cidr_blocks = [ var.public_cidr]
    description = "allow ${var.sshport}"
    from_port = var.sshport
    to_port = var.sshport
    protocol = "tcp"        
  } 
  egress  {
    cidr_blocks =  [ "0.0.0.0/0" ]
    description = "allow all out going"
    from_port = 0
    protocol = -1    
    to_port = 0
  } 
}


resource "aws_key_pair" "tf_deployer" {
  key_name   = "tf_deployer"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC50w/+DS0+gYybJzp4+qBySf3J9sv7R72sfVj6auc+5xXUi/E0q+O1w9yRTj9LJLOYhl2NDFrQsceEK1SYF04zrrzgJs+zdLMtWzYikP50pUO3CBr9UTYvkryYaFEdaVpby98hLkJynhcwYdgcFssPu1sRuimtaRboulLB6WuO5KPcxLeeJCLaZPiYVvmvGoG8ZsdGanoyNodU3JcP3Z/uxJCo4YM8eDNYl4AYRoVUDoGlrUa0/+ZGI/B9Ng3dPz+Tcxo0YI8qNs1VjJNJBwpznnHeCqLc8lDyHkRZ7YWdXiR75B0pVCkhAvZk0lj3lZ5CTbAVM+ki5X41/RiewOQh vagrant@devops-master"
}


output "PublicIPaddress" {
  value = aws_instance.ec2_test.public_ip
}

