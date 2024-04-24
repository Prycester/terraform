provider "aws" {
  region = "us-east-1"
}

variable "developer_name" {
  description = "List of developer names to create resources for"
  type        = string
}

variable "tech_stack" {
  description = "Technology stack for the provisioned resources (php or nodejs)"
  type        = string
}


resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet"
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

resource "aws_route_table_association" "tf-r-assoc" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

resource "aws_security_group" "tf-sg" {
  vpc_id = aws_vpc.tf-vpc.id

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

  ingress {
    from_port   = 8080
    to_port     = 8080
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

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtzAsza9CHf+87LIEY971bfVHAjxyBNlIRc+aZ1eLlZzATHzbahFCwSln0+PkyeZlaXYoy3xeqQiJsgzHYlxrQfxK0D4wn5Yj5PmCYfWKjPcIHnidk9fATS5d28e/w4hpmkBb7W88hgnDxOpETR9zss0VCpwMstCpQ1LIcvnjCUPPqoHggxeMs41kFKX0J/4dQe9pQHBkw859CrepBifouImT291LHUvaNBGwBCWHpKuFSJrwmp3mqQfU/B6dXIq9d/ghPoFqpMyQXq//7SIy5+mpvkthBsRl7cTc03ekIMn0a2nVO2JH0IRAS65lmAeMuJxY7aDKanWz6NaHW1km9 d00468971@desdemona"
}

resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key-2"
  public_key = var.public_key
}

resource "aws_instance" "user_instance" {
  for_each = toset([format("%s-%s", var.developer_name, var.tech_stack)])

  ami                          = "ami-080e1f13689e07408"
  instance_type                = "t2.micro"
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.tf-key.key_name
  subnet_id                    = aws_subnet.tf-subnet.id
  vpc_security_group_ids       = [aws_security_group.tf-sg.id]
  tags = {
    Name = each.value
  }
}


output "instance_ips" {
  value = {for instance in aws_instance.user_instance : instance.tags.Name => instance.public_ip}
  description = "Public IP addresses for each instance."
}
d00468971@ssh:~/it3110-bash-stuff-Pretzelmaster-byte/week4$ ls
assignment2.sh  assignment4.sh  attempt2.sh  attempt4.sh  dhcp.txt  main.tf               students.txt       terraform.tfstate
assignment3.sh  assignment.sh   attempt3.sh  attempt.sh   getin.sh  revised_students.txt  template_week3.sh  terraform.tfstate.backup
d00468971@ssh:~/it3110-bash-stuff-Pretzelmaster-byte/week4$ cat main
cat: main: No such file or directory
d00468971@ssh:~/it3110-bash-stuff-Pretzelmaster-byte/week4$ cat main.tf
provider "aws" {
  region = "us-east-1"
}

variable "developer_name" {
  description = "List of developer names to create resources for"
  type        = string
}

variable "tech_stack" {
  description = "Technology stack for the provisioned resources (php or nodejs)"
  type        = string
}


resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf-subnet" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet"
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

resource "aws_route_table_association" "tf-r-assoc" {
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-r.id
}

resource "aws_security_group" "tf-sg" {
  vpc_id = aws_vpc.tf-vpc.id

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

  ingress {
    from_port   = 8080
    to_port     = 8080
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

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtzAsza9CHf+87LIEY971bfVHAjxyBNlIRc+aZ1eLlZzATHzbahFCwSln0+PkyeZlaXYoy3xeqQiJsgzHYlxrQfxK0D4wn5Yj5PmCYfWKjPcIHnidk9fATS5d28e/w4hpmkBb7W88hgnDxOpETR9zss0VCpwMstCpQ1LIcvnjCUPPqoHggxeMs41kFKX0J/4dQe9pQHBkw859CrepBifouImT291LHUvaNBGwBCWHpKuFSJrwmp3mqQfU/B6dXIq9d/ghPoFqpMyQXq//7SIy5+mpvkthBsRl7cTc03ekIMn0a2nVO2JH0IRAS65lmAeMuJxY7aDKanWz6NaHW1km9 d00468971@desdemona"
}

resource "aws_key_pair" "tf-key" {
  key_name   = "tf-key-2"
  public_key = var.public_key
}

resource "aws_instance" "user_instance" {
  for_each = toset([format("%s-%s", var.developer_name, var.tech_stack)])

  ami                          = "ami-080e1f13689e07408"
  instance_type                = "t2.micro"
  associate_public_ip_address  = true
  key_name                     = aws_key_pair.tf-key.key_name
  subnet_id                    = aws_subnet.tf-subnet.id
  vpc_security_group_ids       = [aws_security_group.tf-sg.id]
  tags = {
    Name = each.value
  }
}


output "instance_ips" {
  value = {for instance in aws_instance.user_instance : instance.tags.Name => instance.public_ip}
  description = "Public IP addresses for each instance."
}
