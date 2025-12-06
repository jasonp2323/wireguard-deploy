# WireGuard VPN on AWS

A Terraform and Python-based infrastructure-as-code project that deploys a self-hosted WireGuard VPN server on AWS with automated cost optimization.

## Architecture

- **Compute**: EC2 t2.micro instance running Ubuntu 24.04
- **Networking**: Custom VPC with public subnet and security groups
- **Automation**: Lambda functions with EventBridge triggers for automatic start/stop (6AM-10PM)
- **DNS**: Dynamic DNS updates via Cloudflare API

## Features

- Infrastructure provisioned entirely with Terraform
- Automated instance lifecycle management (cost-optimized for AWS free tier)
- Dynamic DNS integration with Cloudflare
- SSH key pair generation and management

## Quick Start

1. Configure Cloudflare API credentials in `scripts/dynamic-dns/cloudflare-keys.json`
2. Create the deployment package:
```bash
   powershell .\create-tar.ps1
```
3. Deploy with Terraform:
```bash
   terraform plan -var 'wg-key=YOUR_CLIENT_PUBLIC_KEY'
   terraform apply
```

## Client Setup

1. Download [WireGuard](https://www.wireguard.com/install/)
2. Add tunnel with interface address `10.11.0.36/24`
3. Add peer with server public key from Terraform output and endpoint `your-domain.com:51820`

## Cost

Deployed within AWS free tier with automatic shutdown during non-business hours.
