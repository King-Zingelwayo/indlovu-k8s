resource "aws_security_group" "nat" {
  name        = "${var.cluster_name}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat-sg"
  })
}

resource "aws_security_group" "k8s" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for Kubernetes cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API Server"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    self        = true
    description = "Kubelet API"
  }

  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    self        = true
    description = "kube-scheduler"
  }

  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    self        = true
    description = "kube-controller-manager"
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    self        = true
    description = "etcd"
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    self        = true
    description = "Flannel VXLAN"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Internal cluster traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-sg"
  })
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.cluster_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.cluster_name}-ssm-profile"
  role = aws_iam_role.ssm_role.name

  tags = var.tags
}
