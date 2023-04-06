output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.ado-aks.name
}

output "acr_url" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_user" {
  value     = azurerm_container_registry.acr.admin_username
  sensitive = true
}

output "acr_pass" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}