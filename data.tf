data "aws_ssm_parameter" "credentials" {
  name = "mutable.rabbitmq.${var.env}.credentials"
}

data "aws_ssm_parameter" "ssh_credentials" {
  name = "ssh.credentials"
}

data "aws_ami" "ami" {
  most_recent = true
  name_regex  = "centos7-devops-practice-with-ansible"
  owners      = ["self"]
}

