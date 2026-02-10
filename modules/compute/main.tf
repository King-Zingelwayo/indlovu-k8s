data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "master" {
  name_prefix   = "${var.cluster_name}-master-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.master_instance_type

  iam_instance_profile {
    name = var.ssm_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.k8s_sg_id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.root}/scripts/master-init.sh", {
    pod_network_cidr   = var.pod_network_cidr
    kubernetes_version = var.kubernetes_version
    master_as_worker   = var.master_as_worker
    cluster_name       = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-master"
      Role = "master"
    })
  }
}

resource "aws_launch_template" "worker" {
  name_prefix   = "${var.cluster_name}-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.worker_instance_type

  iam_instance_profile {
    name = var.ssm_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.k8s_sg_id]
    delete_on_termination       = true
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(templatefile("${path.root}/scripts/worker-init.sh", {
    kubernetes_version = var.kubernetes_version
    cluster_name       = var.cluster_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-worker"
      Role = "worker"
    })
  }
}

resource "aws_autoscaling_group" "master" {
  name                = "${var.cluster_name}-master-asg"
  vpc_zone_identifier = [var.private_subnet_id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.master.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-master"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "master"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "worker" {
  name                = "${var.cluster_name}-worker-asg"
  vpc_zone_identifier = [var.private_subnet_id]
  desired_capacity    = var.worker_count
  max_size            = var.worker_max_size
  min_size            = var.worker_min_size

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "worker"
    propagate_at_launch = true
  }
}
