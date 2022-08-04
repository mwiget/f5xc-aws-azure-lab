resource "aws_key_pair" "aws-key" {
  key_name   = format("%s-key", var.aws_ec2_instance_name)
  public_key = var.ssh_public_key
}

resource "aws_security_group" "public" {
  name   = format("%s-public-sg", var.aws_ec2_instance_name, )
  vpc_id = var.aws_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.allow_cidr_blocks
  }

  tags = {
    Owner = var.aws_owner_tag
  }
}

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.aws_ec2_instance_type
  subnet_id                   = var.aws_subnet_id
  vpc_security_group_ids      = [aws_security_group.public.id]
  key_name                    = aws_key_pair.aws-key.id
  user_data_replace_on_change = true
  user_data                   = var.user_data

  tags = {
    Name        = var.aws_ec2_instance_name
    Version     = "1"
    Owner       = var.aws_owner_tag
  }
}
