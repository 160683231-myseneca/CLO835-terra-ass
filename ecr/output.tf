output "mysql_repository_name" {
  value = aws_ecr_repository.mysql_image.name
}

output "mysql_repository_url" {
  value = aws_ecr_repository.mysql_image.repository_url
}

output "app_repository_name" {
  value = aws_ecr_repository.app_image.name
}

output "app_repository_url" {
  value = aws_ecr_repository.app_image.repository_url
}

output "proxy_repository_name" {
  value = aws_ecr_repository.proxy_image.name
}

output "proxy_repository_url" {
  value = aws_ecr_repository.proxy_image.repository_url
}