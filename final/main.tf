#!/bin/bash

# Enable strict mode
set -euo pipefail

# Function to prompt for user input
prompt_for_input() {
    read -p "$1" input
    echo "$input"
}

# Function to SSH into the machine and run the VM creation command
ssh_and_create_vm() {
    username=$(prompt_for_input "Enter the SSH username for 'desdemona': ")
    password=$(prompt_for_input "Enter the SSH password: ")
    vm_user=$(prompt_for_input "Enter the username for the virtual machine: ")
    ram=$(prompt_for_input "Enter RAM size in MBytes for the VM: ")
    disk=$(prompt_for_input "Enter Disk size in GBytes for the VM: ")
    vlan=$(prompt_for_input "Enter VLAN number for the VM: ")
    cpu=$(prompt_for_input "Enter CPU count for the VM: ")

    echo "Connecting to 'desdemona' and executing VM creation command..."
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no "$username@desdemona" \
    "/qemu/bin/citv createvm $vm_user $ram $disk $vlan $cpu"
}

# Function to deploy cloud infrastructure using Terraform
deploy_cloud_infrastructure() {
    echo "Deploying cloud infrastructure with Terraform..."
    terraform init
    terraform apply -auto-approve
}

# Main function to orchestrate the script
main() {
    echo "Welcome to the VM provisioning tool. Please follow the prompts."
    choice=$(prompt_for_input "Choose the environment (on-premises/cloud): ")

    case "$choice" in
        "on-premises")
            ssh_and_create_vm
            ;;
        "cloud")
            deploy_cloud_infrastructure
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run the main function
main

d00468971@ssh:~/it3110-bash-stuff-Pretzelmaster-byte/week4$ cat main.tf
provider "aws" {
  region = "us-east-1" # Adjust as needed
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "tf_subnet" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "Instance-${count.index}"
  }
}

resource "aws_security_group" "tf_sg" {
  name        = "tf_sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

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
    Name = "tf_sg"
  }
}

resource "aws_internet_gateway" "tf_ig" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf_ig"
  }
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_ig.id
  }

  tags = {
    Name = "tf_rt"
  }
}

resource "aws_route_table_association" "tf_rta" {
  subnet_id      = aws_subnet.tf_subnet.id
  route_table_id = aws_route_table.tf_rt.id
}

resource "aws_key_pair" "tf_key" {
  key_name   = "terr-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8NGaey9qYzCQ5fN5oqdChcQx9cCCPMVw93JwM7P7EQFXlPQrRg78miQPdft0bhPJPMfudzv0DFM3WC43W4iE1ezh1gpto+R53r+gFTUubLKGtetrpqdjLpUONc1z+1Qvnh9aRkn8WnOt9uZKDh0QLaFO7sPmBDV2URq1JI6f5Voz6VyTwIaek2jNkP9lEj73Ffiuj6Z5TYpMv5ZhYky3RUviozVnaDpFKTba3VRoRZOuPP31Ze0Rn7J/OafhpVpy9Qbjg0hjDTQq4U873Ycfnwr5RijyDb3N+oiEwWYEJ04z0NMlEba1DT2xuDV9DF+klAQvzlRzUng9lS5EUQmOswHXhHgxFVEfldOHeWONmIXiQt1rbusugDInFWyDVEcHY5GOsP09KIrsvrjNNCufbKYO8zuqq06amiFxYyyH3fW3SibK80e6C+/4SscMjkBzIG9z5Z5s7vHP70t76/dw7bn8s002RpWZYGoRAj5s4rxiKnUIdOrL1e4V05pdc7PM= pryce@dhcp"
}

resource "aws_instance" "instance" {
  count = 3
  ami           = "ami-07d9b9ddc6cd8dd30" # Update with the specific AMI for your region
  instance_type = "t2.micro"
  key_name      = aws_key_pair.tf_key.key_name
  vpc_security_group_ids = [aws_security_group.tf_sg.id]
  subnet_id = aws_subnet.tf_subnet.id
  associate_public_ip_address = true

  user_data = <<-EOF
                #!/bin/bash
                echo "Hello from \${count.index}" > /var/www/html/index.html
                nohup busybox httpd -f -p 80 &
                EOF

  tags = {
    Name = "Instance-\${count.index}"
  }
}

output "dev_ip" {
  value = aws_instance.instance[0].public_ip
}

output "test_ip" {
  value = aws_instance.instance[1].public_ip
}

output "prod_ip" {
  value = aws_instance.instance[2].public_ip
}
