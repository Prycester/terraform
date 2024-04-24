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
