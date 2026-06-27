# WireGuard VPN on AWS

A Terraform and Python-based infrastructure-as-code project that deploys a self-hosted WireGuard VPN server on AWS with automated cost optimization.

## Architecture

- **Compute**: EC2 t2.micro instance running Ubuntu 24.04 (IMDSv2 enforced, EBS encrypted)
- **Networking**: Custom VPC with public subnet and security groups
- **Automation**: Lambda functions with EventBridge triggers for automatic start/stop (6AM-10PM)
- **DNS**: Dynamic DNS updates via Cloudflare API

## Features

- Infrastructure provisioned entirely with Terraform
- Automated instance lifecycle management (cost-optimized for AWS free tier)
- Dynamic DNS integration with Cloudflare
- SSH key pair generation and management
- Least-privilege IAM roles for Lambda functions

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- AWS CLI configured with appropriate credentials
- A Cloudflare account with an API token and DNS zone (for dynamic DNS)

## Quick Start

1. Copy the Cloudflare credentials template and fill in your values:
```bash
cp scripts/dynamic-dns/cloudflare-keys.json.example scripts/dynamic-dns/cloudflare-keys.json
# Edit cloudflare-keys.json with your API token, zone ID, and DNS record
```

2. Create a `terraform.tfvars` file:
```hcl
wg-key           = "YOUR_CLIENT_WIREGUARD_PUBLIC_KEY"
ssh_allowed_cidr = "YOUR_IP_ADDRESS/32"  # e.g. 1.2.3.4/32
```

3. Create the deployment package:
```bash
# On Windows:
powershell .\create-tar.ps1

# On Linux/macOS:
tar -cvf scripts/vpn-scripts.tar -C scripts vpn-commands.sh
```

4. Deploy with Terraform:
```bash
terraform init
terraform plan
terraform apply
```

5. Retrieve the SSH private key after apply:
```bash
terraform output -raw private_key > wireguard-key.pem
chmod 600 wireguard-key.pem
```

## Client Setup

1. Download [WireGuard](https://www.wireguard.com/install/)
2. Get the server public key and IP:
```bash
terraform output wireguard_server_ip
```
3. Configure your WireGuard client:
   - Interface address: `10.11.0.36/24`
   - Peer endpoint: `your-domain.com:51820` (or the server IP)
   - Peer public key: from your server's `/etc/wireguard/publickey`

## Security Notes

- `scripts/dynamic-dns/cloudflare-keys.json` is gitignored — never commit real credentials
- SSH access is restricted to the CIDR set in `ssh_allowed_cidr` (set to your IP)
- IMDSv2 is enforced on the EC2 instance to prevent SSRF attacks
- EBS root volume is encrypted at rest
- Lambda IAM role is scoped to the specific EC2 instance ARN

## Cost

Deployed within AWS free tier with automatic shutdown during non-business hours.
