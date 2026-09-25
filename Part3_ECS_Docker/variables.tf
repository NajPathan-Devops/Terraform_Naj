variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "Kept for consistency with Parts 1 and 2"
  type        = string
  default     = "t3.micro"
}
