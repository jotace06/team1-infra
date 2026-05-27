output "role_arn" {
  value = module.irsa.role_arn
}

output "addon_name" {
  value = aws_eks_addon.this.addon_name
}
