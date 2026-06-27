data "aws_ami" "ubuntu" {
    most_recent   = true
    owners        = ["099720109477"] // Canonical

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_instance" "wireguard-server" {
    ami                         = data.aws_ami.ubuntu.id
    associate_public_ip_address = "true"    
    capacity_reservation_specification {
      capacity_reservation_preference = "open"
    }   
    credit_specification {
        cpu_credits = "standard"
    }   
    disable_api_stop        = "false"
    disable_api_termination = "false"
    ebs_optimized           = "false"

    enclave_options {
        enabled = "false"
    }   
    get_password_data                    = "false"
    hibernation                          = "false"
    instance_initiated_shutdown_behavior = "stop"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = "0"
    key_name                             = aws_key_pair.wireguard-key-pair.key_name     
    maintenance_options {
        auto_recovery = "default"
    }   
    metadata_options {
        http_endpoint               = "enabled"
        http_protocol_ipv6          = "disabled"
        http_put_response_hop_limit = "1"
        http_tokens                 = "required"
        instance_metadata_tags      = "disabled"
    }   
    monitoring                 = "false"
    placement_partition_number = "0"    
    private_dns_name_options {
        enable_resource_name_dns_a_record    = "false"
        enable_resource_name_dns_aaaa_record = "false"
        hostname_type                        = "ip-name"
    }   
    private_ip = "10.21.32.5"       
    root_block_device {
        delete_on_termination = "true"
        encrypted             = "true"
        iops                  = "3000"
        throughput            = "125"
        volume_size           = "8"
        volume_type           = "gp3"
    }   
    source_dest_check = "true"
    subnet_id         = aws_subnet.main.id    
    tags = var.tags   
    tags_all = {
        Name = "wireguard-server"
    }   
    tenancy                = "default"
    vpc_security_group_ids = [aws_security_group.wireguard-sg.id]   
    provisioner "remote-exec" {
        inline = [
            "mkdir -p /home/ubuntu/scripts"
        ]   
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = tls_private_key.wireguard-key-pair.private_key_pem
            host        = self.public_ip
        }
    }   
    provisioner "file" {
        source      = "scripts/vpn-scripts.tar"
        destination = "/home/ubuntu/vpn-scripts.tar"    
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = tls_private_key.wireguard-key-pair.private_key_pem
            host        = self.public_ip
        }
    }   
    provisioner "remote-exec" {
        inline = [
            "tar -xvf /home/ubuntu/vpn-scripts.tar -C /home/ubuntu/scripts",
            "chmod +x /home/ubuntu/scripts/vpn-commands.sh",
            "sed -i 's/\r//' /home/ubuntu/scripts/vpn-commands.sh",
            "/home/ubuntu/scripts/vpn-commands.sh",
            "sudo wg set wg0 peer ${var.wg-key} allowed-ips 10.11.0.36/32",
            "echo \"peer ${var.wg-key} with allowed-ips 10.11.0.36/32 added\"",
            "echo \"All scripting complete\""
        ]   
        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = tls_private_key.wireguard-key-pair.private_key_pem
            host        = self.public_ip
        }
    }
}

resource "tls_private_key" "wireguard-key-pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "wireguard-key-pair" {
  key_name   = "wireguard-key-pair"
  public_key = tls_private_key.wireguard-key-pair.public_key_openssh
}

output "private_key" {
  value = tls_private_key.wireguard-key-pair.private_key_pem
  sensitive = true
}

output "wireguard_server_ip" {
  value = aws_instance.wireguard-server.public_ip
}
