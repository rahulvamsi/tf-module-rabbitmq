resource "aws_security_group" "main" {
  name        = "${var.env}-rabbitmq"
  description = "${var.env}-rabbitmq"
  vpc_id      = var.vpc_id

  ingress {
    description = "rabbitmq"
    from_port   = 5672
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block, var.WORKSTATION_IP]
  }

  tags = {
    Name = "${var.env}-rabbitmq"
  }
}

resource "aws_spot_instance_request" "rabbitmq" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  subnet_id              = element(var.db_subnets_ids, 0)
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name = "rabbitmq-${var.env}"
  }
}

resource "aws_ec2_tag" "name-tag" {
  resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
  key         = "Name"
  value       = "rabbitmq-${var.env}"
}


