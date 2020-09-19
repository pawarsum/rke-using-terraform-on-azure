output "public_ip" {
  value = module.nodes.public_ip
}
output "internal_ip" {
  value = module.nodes.internal_ip
}
output "ssh_command" {
  value = module.nodes.ssh_command
}
