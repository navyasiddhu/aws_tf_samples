terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" 
  }
  
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name            = "webservers-stage"
  instance_type           = "t2.micro"
  webport                 = 8080
  sshport                 = 22
  public_cidr             = "0.0.0.0/0"
  tags                    = {"owner": "terraform", "env": "deve"}
  region = "us-east-2" 
}

