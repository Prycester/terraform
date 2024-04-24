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

# Function to deploy selected tech stack (PHP or Node.js) and sample application
deploy_tech_stack() {
    tech_stack=$1
    echo "Deploying $tech_stack stack and sample application..."

    # Check if PHP or Node.js is selected and deploy the appropriate stack
    if [ "$tech_stack" == "PHP" ]; then
        ansible-playbook deploy_php.yml -i inventory.ini
    elif [ "$tech_stack" == "Node.js" ]; then
        ansible-playbook deploy_nodejs.yml -i inventory.ini
    else
        echo "Invalid tech stack. Exiting."
        exit 1
    fi
}

# Read AWS credentials from the credentials file
if [ -f ~/.aws/credentials ]; then
    aws_access_key_id=$(grep -oP '(?<=aws_access_key_id=).*' ~/.aws/credentials)
    aws_secret_access_key=$(grep -oP '(?<=aws_secret_access_key=).*' ~/.aws/credentials)
    aws_session_token=$(grep -oP '(?<=aws_session_token=).*' ~/.aws/credentials)

    # Export AWS credentials as environment variables
    export AWS_ACCESS_KEY_ID="$aws_access_key_id"
    export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"
    export AWS_SESSION_TOKEN="$aws_session_token"
else
    echo "AWS credentials file not found. Exiting."
    exit 1
fi

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
            tech_stack=$(prompt_for_input "Choose the tech stack (PHP/Node.js): ")
            deploy_tech_stack "$tech_stack"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Run the main function
main

