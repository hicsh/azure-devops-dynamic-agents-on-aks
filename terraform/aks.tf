resource "azurerm_container_registry" "acr" {
  name                = "acradoagents"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "westeurope"
  sku                 = "Basic"
  admin_enabled       = true

}

resource "azurerm_kubernetes_cluster" "ado-aks" {
  name                    = "aks-ado-agents"
  location                = "westeurope"
  resource_group_name     = azurerm_resource_group.rg.name
  private_cluster_enabled = false
  dns_prefix              = "aks-ado-agents"

  default_node_pool {
    name                = "default"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    node_count          = 1
    max_count           = 3
    min_count           = 1
    vm_size             = "Standard_D2_v2"

  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "PoC"
    Project     = "AzureDevOpsAgents"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.ado-aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "local_file" "kubeconfig" {
  depends_on   = [azurerm_kubernetes_cluster.ado-aks]
  filename     = "./kubeconfig"
  content      = azurerm_kubernetes_cluster.ado-aks.kube_config_raw
}