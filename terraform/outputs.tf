output "instance_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "instance_user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "instance_region" {
  value = data.aws_region.current
}

output "instance_ip_addr" {
  value = aws_instance.web.private_ip
}

output "instance_subnet_id" {
  value = aws_instance.web.subnet_id
}

