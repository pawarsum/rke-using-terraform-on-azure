variable "resource_group_name" {
  type        = string
  default     = "terraform"
  description = "Resource group where resources will be created."
}

variable "location" {
  type        = string
  default     = "centralus"
  description = "Region where resources will be created."
}

variable "size" {
  description = "Size of VM e.g Standard_D2s_v3"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "username" {
  type        = string
  description = "Username to login VM"
  default     = "kuberoot"
  validation {
    condition     = length(var.username) > 4 && substr(var.username, 0, 4) == "kube"
    error_message = "The username value must start with kube."
  }
}

variable "publickey" {
  type = string
  description = "public key to access virtual machine"
}
variable "environment_setup" {
  type    = string
  default = "pre_rke_setup.bash"
}

variable "tags" {
  type = map(string)
  default = {
    "environment" = "dev"
  }
  description = "Tags to identify the resources."
}

variable "prefix" {
  type        = string
  default     = "rke"
  description = "Prefix to be added before resources"
}

variable "address_spaces" {
  type        = string
  description = "List of address spaces defined for virtual network."
  default     = "10.0.0.0/16"
}

variable "address_prefixes" {
  type        = list(string)
  description = "List of address prefixes of a subnet."
  default     = ["10.0.2.0/24"]
}