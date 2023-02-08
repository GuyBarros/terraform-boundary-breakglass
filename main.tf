provider "boundary" {
  addr                            = var.boundary_address
  auth_method_id                  = var.boundary_auth_method_id
  password_auth_method_login_name = var.boundary_username
  password_auth_method_password   = var.boundary_password
}




resource "boundary_scope" "ticket" {
  name                   = "ticket_${var.ticket_number}"
  description            = "temporary project for breakglass access related to ticket - ${var.ticket_number}"
  scope_id               = var.boundary_org_id
  auto_create_admin_role = true
}


resource "boundary_host_catalog_static" "ticket_host_catalog" {
  name        = "${var.ticket_number} host catalog"
  description = "${var.ticket_number} host catalog"
  scope_id    = boundary_scope.ticket.id
}


resource "boundary_host_static" "ticket_host" {
  type            = "static"
  name            = "${var.ticket_number}_host"
  host_catalog_id = boundary_host_catalog_static.ticket_host_catalog.id
  address         = var.node_fqdn
}

resource "boundary_host_set_static" "ticket_host_set" {
  type            = "static"
  name            = "${var.ticket_number}_host_set"
  host_catalog_id = boundary_host_catalog_static.ticket_host_catalog.id

  host_ids = [
    boundary_host_static.ticket_host.id,
  ]
}


# create target for accessing backend servers on port :22
resource "boundary_target" "ticket_ssh" {
  type                     = "tcp"
  name                     = var.ticket_number
  description              = "${var.ticket_number} SSH target"
  scope_id                 = boundary_scope.ticket.id
  default_port             = "22"
  session_connection_limit = -1
  worker_filter = " \"demostack\" in \"/tags/type\" "
  host_source_ids = [
    boundary_host_set_static.ticket_host_set.id
  ]
  
  /*
   brokered_credential_source_ids   = [
    boundary_credential_library_vault.ticket-ssh.id
   ]
   */

  

}
resource "vault_token" "boundary" {
  no_parent = true
  policies = ["dev-team","superadmin","admin-policy"]
  display_name = "boundary cred store"
  renewable = true
  period = "72h"
}

resource "boundary_credential_store_vault" "app_vault" {
  name        = "${var.ticket_number} cred store"
  description = "${var.ticket_number} Vault Credential Store"
address         = var.vault_address
token       = vault_token.boundary.client_token
  namespace   = "admin/guystack"
  scope_id    = boundary_scope.ticket.id
}

resource "boundary_credential_library_vault" "ticket-ssh" {
  name                = "vault_token"
  description         = "Credential Library for Vault Token"
  credential_store_id = boundary_credential_store_vault.app_vault.id
  path                = "boundary_creds/data/ssh" # change to Vault backend path
  http_method         = "GET"
  credential_type     = "ssh_private_key"
}
