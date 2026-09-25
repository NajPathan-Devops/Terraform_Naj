data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform-Naj-Part2-VPC"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Terraform-Naj-Part2-IGW"
  }
}

# -------------------------
# Public Subnet - Flask
# -------------------------

resource "aws_subnet" "flask" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform-Naj-Part2-Flask-Subnet"
  }
}

# -------------------------
# Public Subnet - Express
# -------------------------

resource "aws_subnet" "express" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform-Naj-Part2-Express-Subnet"
  }
}

# -------------------------
# Route Table
# -------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Terraform-Naj-Part2-Public-RT"
  }
}

resource "aws_route_table_association" "flask" {
  subnet_id      = aws_subnet.flask.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "express" {
  subnet_id      = aws_subnet.express.id
  route_table_id = aws_route_table.public.id
}

# -------------------------
# Flask Security Group
# -------------------------

resource "aws_security_group" "flask" {
  name        = "terraform-naj-part2-flask-sg"
  description = "Security group for Flask EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Flask public access"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Flask access from Express EC2"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.express.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Naj-Part2-Flask-SG"
  }
}

# -------------------------
# Express Security Group
# -------------------------

resource "aws_security_group" "express" {
  name        = "terraform-naj-part2-express-sg"
  description = "Security group for Express EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Express public access"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terraform-Naj-Part2-Express-SG"
  }
}

# -------------------------
# Flask EC2
# -------------------------

resource "aws_instance" "flask" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.flask.id
  vpc_security_group_ids      = [aws_security_group.flask.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = file("${path.module}/user_data_flask.sh")

  tags = {
    Name = "Terraform-Naj-Part2-Flask"
  }
}

# -------------------------
# Express EC2
# -------------------------

resource "aws_instance" "express" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.express.id
  vpc_security_group_ids      = [aws_security_group.express.id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  user_data = templatefile("${path.module}/user_data_express.sh", {
    flask_private_ip = aws_instance.flask.private_ip
  })

  tags = {
    Name = "Terraform-Naj-Part2-Express"
  }
}
