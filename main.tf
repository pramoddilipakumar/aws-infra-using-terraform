provider "aws" {
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyVPC"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create a security group for the EC2 instance
resource "aws_security_group" "instance_sg" {
  name_prefix = "instance_sg_"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "example_instance" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace this with the desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  tags = {
    Name = "ExampleInstance"
  }
}

# Create an RDS instance in the private subnet
resource "aws_db_instance" "example_db" {
  engine           = "mysql"
  instance_class   = "db.t2.micro"
  name             = "exampledb"
  username         = "admin"
  password         = "adminpassword"
  allocated_storage = 20
  engine_version   = "5.7"
  storage_type     = "gp2"
  multi_az         = false
  db_subnet_group_name = aws_db_subnet_group.example_db_subnet_group.name

  tags = {
    Name = "DynamoDB"
  }
}

# Create a DB subnet group for RDS
resource "aws_db_subnet_group" "example_db_subnet_group" {
  name       = "example-db-subnet-group"
  subnet_ids = [aws_subnet.private.id]
}
