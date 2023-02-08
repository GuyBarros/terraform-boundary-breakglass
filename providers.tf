provider "vault" {
  address = var.vault_address
  namespace = var.vault_namespace
  token   = var.vault_token
}