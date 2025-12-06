// Security Group
resource "aws_security_group" "wireguard-sg" {
    vpc_id = aws_vpc.main.id
    name = "wireguard-sg"
    description = "Security group for WireGuard VPN Server"

    // Ingress rules
    egress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "0"
        protocol    = "-1"
        self        = "false"
        to_port     = "0"
        description = "Allow all traffic outbound"
    }  

    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "51820"
        protocol    = "udp"
        self        = "false"
        to_port     = "51820"
        description = "WireGuard VPN UDP Port"
    }   
    
    ingress {
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = "22"
        protocol    = "tcp"
        self        = "false"
        to_port     = "22"
        description = "SSH"
    }
}