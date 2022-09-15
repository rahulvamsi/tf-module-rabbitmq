locals {
  username     = element(split("/", data.aws_ssm_parameter.credentials.value), 0)
  password     = element(split("/", data.aws_ssm_parameter.credentials.value), 1)
  ssh_password = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 0)
  ssh_username = element(split("/", data.aws_ssm_parameter.ssh_credentials.value), 1)
}
