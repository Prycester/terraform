provider "aws" {
  region = "us-east-1" # Adjust as needed
}

resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf-subnet" {
  vpc_id            = aws_vpc.tf-vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet"
  }
}

resource "aws_security_group" "tf-sg" {
  name        = "tf-sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.tf-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "tf-sg"
  }
}

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "tf-ig"
  }
}

resource "aws_route_table" "tf-r" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }

  tags = {
    Name = "tf-r"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

resource "aws_key_pair" "terr-key" {
  key_name   = "terr-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8NGaey9qYzCQ5fN5oqdChcQx9cCCPMVw93JwM7P7EQFXlPQrRg78miQPdft0bhPJPMfudzv0DFM3WC43W4iE1ezh1gpto+R53r+gFTUubLKGtetrpqdjLpUONc1z+1Qvnh9aRkn8WnOt9uZKDh0QLaFO7sPmBDV2URq1JI6f5Voz6VyTwIaek2jNkP9lEj73Ffiuj6Z5TYpMv5ZhYky3RUviozVnaDpFKTba3VRoRZOuPP31Ze0Rn7J/OafhpVpy9Qbjg0hjDTQq4U873Ycfnwr5RijyDb3N+oiEwWYEJ04z0NMlEba1DT2xuDV9DF+klAQvzlRzUng9lS5EUQmOswHXhHgxFVEfldOHeWONmIXiQt1rbusugDInFWyDVEcHY5GOsP09KIrsvrjNNCufbKYO8zuqq06amiFxYyyH3fW3SibK80e6C+/4SscMjkBzIG9z5Z5s7vHP70t76/dw7bn8s002RpWZYGoRAj5s4rxiKnUIdOrL1e4V05pdc7PM= pryce@dhcp"
}

resource "aws_instance" "instance" {
  count = 3
  ami           = "ami-07d9b9ddc6cd8dd30" # Use an appropriate Ubuntu AMI for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf-key.key_name
  vpc_security_group_ids = [aws_security_group.tf-sg.id]
  subnet_id = aws_subnet.tf-subnet.id
  associate_public_ip_address = true
  user_data = <<-EOF
                #!/bin/bash
                echo "Hello from ${count.index}" > index.html
                nohup busybox httpd -f -p 80 &
                EOF

  tags = {
    Name = "Instance-${count.index}"
  }
}

output "dev" {
  value = aws_instance.instance[0].public_ip
}

output "test" {
  value = aws_instance.instance[1].public_ip
}

output "prod" {
  value = aws_instance.instance[2].public_ip
}

