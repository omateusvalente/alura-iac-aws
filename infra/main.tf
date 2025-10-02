terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = var.regiao_aws
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_template" "maquina" {
  image_id = data.aws_ami.ubuntu.id
  instance_type = var.instancia
  key_name = var.chave
  tags = {
    Name = "Terraform Ansible Python"
  }
  security_group_names = [ var.grupoDeSeguranca ]
  user_data = filebase64("ansible.sh")
}

resource "aws_key_pair" "chaveSSH" {
  key_name = var.chave
  public_key = file("${var.chave}.pub")
}

resource "aws_autoscaling_group" "grupo" {
  availability_zones = ["${var.regiao_aws}a" , "${var.regiao_aws}a"]
  name = var.nomeGrupo
  max_size = var.maximo
  min_size = var.minimo
  launch_template {
    id = aws_launch_template.maquina.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alvoLoadBalancer.arn]
}

resource "aws_default_subnet" "subnet1" {
  availability_zone = "${var.regiao_aws}a"
}

resource "aws_default_subnet" "subnet2" {
  availability_zone = "${var.regiao_aws}c"
}

resource "aws_lb" "loadbalancer" {
  internal = false
  subnets = [ aws_default_subnet.subnet1.id, aws_default_subnet.subnet2.id ]
}

resource "aws_default_vpc" "vpc"{
}

resource "aws_lb_target_group" "alvoLoadBalancer" {
  name = "maquinasAlvo"
  port = "8000"
  protocol = "TCP"
  vpc_id = aws_default_vpc.vpc.id
}

resource "aws_lb_listener" "entradaLoadBalancer" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alvoLoadBalancer.arn
  }
}

resource "aws_autoscaling_policy" "escala-Producao" {
  name = "terraform-escala"
  autoscaling_group_name = var.nomeGrupo
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}
