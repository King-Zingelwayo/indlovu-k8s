data "aws_ami" "nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nat" {
  ami                    = data.aws_ami.nat.id
  instance_type          = "t3.nano"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.nat_sg_id]
  source_dest_check      = false
  iam_instance_profile   = var.ssm_profile_name

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-nat"
  })
}
