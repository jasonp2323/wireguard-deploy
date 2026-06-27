variable "tags" {
  type = map(string)
  default = {
    Name = "wireguard-server"
  }
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the WireGuard server. Restrict to your IP (e.g. 1.2.3.4/32)."
  type        = string
}

variable "wg-key" {
  description = "The public key for the WireGuard peer"
  type        = string
  default     = ""

  validation {
    condition     = length(var.wg-key) > 0
    error_message = "Error: wg-key variable is blank. If using the destroy command input any value for this variable."
  }
}

