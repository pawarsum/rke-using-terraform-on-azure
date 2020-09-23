variable "username" {
  type        = string
  description = "Specifies the name of the local administrator account"
  default     = "kuberoot"
}
variable "publickey" {
  type = string
  description = "public key to access virtual machine"
}