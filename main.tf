terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}


provider "aws" {
  region     = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Task Manager VPC
resource "aws_vpc" "task_manager_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet for the Presentation Layer
resource "aws_subnet" "task_manager_public_subnet" {
  vpc_id     = aws_vpc.task_manager_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Private Subnet for the Data and Logic Layers
resource "aws_subnet" "task_manager_private_subnet" {
  vpc_id     = aws_vpc.task_manager_vpc.id
  cidr_block = "10.0.2.0/24"
}

# An Internet Gateway to expose our layers to the internet safely
resource "aws_internet_gateway" "task_manager_igw" {
  vpc_id = aws_vpc.task_manager_vpc.id
}
# resource "aws_internet_gateway_attachment" "task_manager_vpc_attachment" {
#   vpc_id              = aws_vpc.task_manager_vpc.id
#   internet_gateway_id = aws_internet_gateway.task_manager_igw.id
# }

# A Public Route Table for the Public Subnet
resource "aws_route_table" "task_manager_public_rt" {
  vpc_id = aws_vpc.task_manager_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.task_manager_igw.id
  }
}

# Associating the Public Subnet with the Public Route Table
resource "aws_route_table_association" "task_manager_public_rt_association" {

  subnet_id      = aws_subnet.task_manager_public_subnet.id
  route_table_id = aws_route_table.task_manager_public_rt.id
}

# A NAT Gateway to ensure Private Subnets can access the Internet
resource "aws_nat_gateway" "task_manager_nat_gateway" {
  subnet_id     = aws_subnet.task_manager_public_subnet.id
  allocation_id = aws_eip.task_manager_eip.id
  
}
resource "aws_eip" "task_manager_eip" {  
  domain = "vpc"
}


# A private Route Table for the Private Subnet
resource "aws_route_table" "task_manager_private_rt" {
  vpc_id = aws_vpc.task_manager_vpc.id
}

# A route in the Private Route table for the NAT Gateway
resource "aws_route" "task_manager_private_route" {
  route_table_id         = aws_route_table.task_manager_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.task_manager_nat_gateway.id
}

# Linking the  Private Route Table to the Private Subnet
resource "aws_route_table_association" "task_manager_private_rt_association" {
  subnet_id      = aws_subnet.task_manager_private_subnet.id
  route_table_id = aws_route_table.task_manager_private_rt.id
}

# An Auto Scaling Group for the deployed resources
resource "aws_autoscaling_group" "task_manager_asg" {  
  launch_configuration = aws_launch_configuration.task_manager_lc.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = [
    aws_subnet.task_manager_public_subnet.id,
    aws_subnet.task_manager_private_subnet.id
  ]
}


data "aws_ami" "ubuntu" {
  most_recent = true

  # filter {
  #   name = "name"
  #   values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  # }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}
# Config for the Launch Config used Above
resource "aws_launch_configuration" "task_manager_lc" {
  name = "task_manager_lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

# An EC2 Instance within the  Created Network Config
resource "aws_instance" "task_manager_server" {
  ami                         = "ami-0cf10cdf9fcd62d37"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.task_manager_private_subnet.id
  associate_public_ip_address = false
  security_groups             = [aws_security_group.task_manager_sg.id]

}

# Security Group Config 
resource "aws_security_group" "task_manager_sg" {
  name        = "task_manager_sg"
  description = "Allowing Inbound traffic on ports 22 and 80"

  vpc_id = aws_vpc.task_manager_vpc.id

  ingress {
    description = "SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    
  }

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    
  }
  
}

# An S3 bucket to store the task images created by the users
resource "aws_s3_bucket" "task-manager-savannah7521" {
  bucket = "task-manager-savannah"
  tags = {
    Environment = "production"
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "task-manager-savannah_lc" {
  bucket = aws_s3_bucket.task-manager-savannah7521.id

  rule {
    id = "uploads"
    expiration {
      days = 90
    }
    filter {
      and {
        prefix = "task_images/"
      }
    }
    status = "Enabled"
    transition {
      days          = 60
      storage_class = "GLACIER"
    }

  }
}

# Accessing the web server using the Public DNS of the ECC2 Instance
output "ec2_instance_public_dns" {
  value = aws_instance.task_manager_server.public_dns
}

resource "aws_cloudwatch_metric_alarm" "task_manager_metrics" {
  alarm_name                = "task_manager_metrics"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors EC2 cpu utilization"
  insufficient_data_actions = []
}