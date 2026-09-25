output "vpc_id" {
  description = "Part 2 VPC ID"
  value       = aws_vpc.main.id
}

output "flask_instance_id" {
  description = "Flask EC2 instance ID"
  value       = aws_instance.flask.id
}

output "flask_public_ip" {
  description = "Flask EC2 public IP"
  value       = aws_instance.flask.public_ip
}

output "flask_private_ip" {
  description = "Flask EC2 private IP"
  value       = aws_instance.flask.private_ip
}

output "flask_url" {
  description = "Flask application URL"
  value       = "http://${aws_instance.flask.public_ip}:5000"
}

output "express_instance_id" {
  description = "Express EC2 instance ID"
  value       = aws_instance.express.id
}

output "express_public_ip" {
  description = "Express EC2 public IP"
  value       = aws_instance.express.public_ip
}

output "express_private_ip" {
  description = "Express EC2 private IP"
  value       = aws_instance.express.private_ip
}

output "express_url" {
  description = "Express application URL"
  value       = "http://${aws_instance.express.public_ip}:3000"
}

output "express_flask_health_url" {
  description = "Express endpoint testing communication with Flask"
  value       = "http://${aws_instance.express.public_ip}:3000/flask-health"
}
