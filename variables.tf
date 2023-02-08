variable "boundary_address" {
  description = "Boundary Host"
  default     = ""
}

variable "boundary_auth_method_id" {
  description = "Boundary Auth Method"
  default     = ""
}

variable "boundary_username" {
  description = "Boundary Username"
  default     = "admin"
}

variable "boundary_password" {
  description = "Boundary Password"
  default     = ""
}

variable "boundary_org_id" {
  description = "Boundary Org ID where project will be created in"
  
}

variable "ticket_number" {
  description = "Ticket Number of the approved breakglass request"
  default     = "8675309"
}

variable "node_fqdn" {
  description = "FQDN of the node we want to connect to"
  default     = "workers-0.guystack.original.aws.hashidemos.io"
}

################ Vault

 variable "vault_namespace" {
  description = "the HCP Vault namespace we will use for mounting the database secret engine"
  default = "admin/guystack"
}

 variable "vault_address" {
  description = "the Vault Address"
}

 variable "vault_token" {
  description = "the Vault Address"
  sensitive = true
}