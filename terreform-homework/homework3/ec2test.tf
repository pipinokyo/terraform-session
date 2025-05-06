# Create Security Group for Frontend Instance
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = aws_vpc.app_vpc1.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "frontend-sg"
  }
}

# Create Security Group for MySQL Instance
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  description = "Allow MySQL and SSH traffic from Frontend"
  vpc_id      = aws_vpc.app_vpc1.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql-sg"
  }
}

# Create SSH Key Pair for Frontend
resource "aws_key_pair" "frontend_key" {
  key_name   = "FrontendKey"
  public_key = tls_private_key.frontend_key_pair.public_key_openssh
}

resource "tls_private_key" "frontend_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.frontend_key_pair.private_key_pem
  filename = "FrontendKey.pem"
  file_permission = "0400"
}

# Create Frontend EC2 Instance
resource "aws_instance" "frontend_instance" {
  ami                         = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.app_pub_subnet_1a.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  key_name                    = aws_key_pair.frontend_key.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd php php-mysqlnd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo wget https://wordpress.org/latest.tar.gz -P /var/www/html
              sudo tar -xzvf /var/www/html/latest.tar.gz -C /var/www/html
              sudo chown -R apache:apache /var/www/html/wordpress
              EOF

  tags = {
    Name = "FrontendInstance"
  }
}

# Create MySQL EC2 Instance
resource "aws_instance" "mysql_instance" {
  ami                         = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.app_priv_subnet_3c.id
  vpc_security_group_ids      = [aws_security_group.mysql_sg.id]
  key_name                    = aws_key_pair.frontend_key.key_name
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y mysql-server
              sudo systemctl start mysqld
              sudo systemctl enable mysqld
              sudo mysql -e "CREATE DATABASE wordpress;"
              sudo mysql -e "CREATE USER 'wordpress'@'%' IDENTIFIED BY 'password';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'%';"
              sudo mysql -e "FLUSH PRIVILEGES;"
              EOF

  tags = {
    Name = "MySQLInstance"
  }
}

output "frontend_instance_public_ip" {
  value = aws_instance.frontend_instance.public_ip
}

output "mysql_instance_private_ip" {
  value = aws_instance.mysql_instance.private_ip
}