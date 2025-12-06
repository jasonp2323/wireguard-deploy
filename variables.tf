variable "tags" {
  type = map(string)
  default = {
    Name = "wireguard-server"
  }
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

