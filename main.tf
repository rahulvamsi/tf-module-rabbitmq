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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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
  wait_for_fulfillment   = true
  iam_instance_profile   = aws_iam_instance_profile.parameter-store-access.name
  tags = {
    Name = "rabbitmq-${var.env}"
  }
}

resource "aws_ec2_tag" "name-tag" {
  resource_id = aws_spot_instance_request.rabbitmq.spot_instance_id
  key         = "Name"
  value       = "rabbitmq-${var.env}"
}

resource "null_resource" "ansible-apply" {
  //  triggers = {
  //    always = timestamp()
  //  }
  provisioner "remote-exec" {
    connection {
      host     = aws_spot_instance_request.rabbitmq.private_ip
      user     = local.ssh_username
      password = local.ssh_password
    }
    inline = [
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb66/roboshop-mutable-ansible roboshop.yml -e HOSTS=localhost -e APP_COMPONENT_ROLE=rabbitmq -e ENV=${var.env} -e RABBITMQ_PASSWORD=${local.password} &>/tmp/rabbitmq.log"
    ]
  }
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = data.aws_route53_zone.private.id
  name    = "rabbitmq-${var.env}.roboshop.internal"
  type    = "A"
  ttl     = 30
  records = [aws_spot_instance_request.rabbitmq.private_ip]
}

