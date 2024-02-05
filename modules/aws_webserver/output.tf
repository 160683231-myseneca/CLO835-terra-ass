output "private_ip_ec2" {
  value = aws_instance.ec2_instance.*.private_ip
}

output "public_ip_ec2" {
  value = aws_instance.ec2_instance.*.public_ip
}

output "ec2_ids" {
    value = aws_instance.ec2_instance[*].id
}