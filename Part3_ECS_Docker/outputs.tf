output "vpc_id" {
  description = "Part 3 VPC ID"
  value       = aws_vpc.main.id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "flask_ecr_repository" {
  description = "Flask ECR repository URL"
  value       = aws_ecr_repository.flask.repository_url
}

output "express_ecr_repository" {
  description = "Express ECR repository URL"
  value       = aws_ecr_repository.express.repository_url
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "express_url" {
  description = "Express application through ALB"
  value       = "http://${aws_lb.main.dns_name}/"
}

output "flask_url" {
  description = "Flask application through ALB"
  value       = "http://${aws_lb.main.dns_name}/api/"
}
