provider "vault" {
  namespace = "admin"
}

# Create KV Mount for Demo
resource "vault_mount" "kvv2" {
  path        = "dynatracekv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

# Create KV Mount for Demo and set the max versions and delete version after.
resource "vault_kv_secret_backend_v2" "example" {
  mount                = vault_mount.kvv2.path
  max_versions         = 5
  delete_version_after = 12600
}

# Add secret data to KV for demo.
resource "vault_kv_secret_v2" "example" {
  mount                      = vault_mount.kvv2.path
  name                       = "secret"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    secretuser       = "demouser",
    secretpassword   = "demopassword"
  }
  )
  custom_metadata {
    max_versions = 5
    data = {
      foo = "vault@example.com",
      bar = "12345"
    }
  }
}

# Mount Approle Auth engine. Set a max lease ttl of 168 hours (7 days) for all leases from this mount
resource "vault_auth_backend" "approle" {
  type = "approle"
  tune {
    max_lease_ttl = "168h"
  }
}

# Create an auth role. We also set a max TTL of 1 day for the token created by this role.
resource "vault_approle_auth_backend_role" "example" {
  backend        = vault_auth_backend.approle.path
  role_name      = "test-role"
  token_policies = ["default", "dynatrace-team"]
  secret_id_ttl = "86400"
  token_max_ttl = "86400"
}

# Create an secretid
# This should be done in a separate workflow, but we will keep it here for simplicity and demonstration.
resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.example.role_name

  metadata = jsonencode(
    {
      "hello" = "world"
    }
  )
}

# Create a policy for the AppRole to allow access to the KV secret engine. 
# We only allow read access to the secret path that was created above for this demo.
resource "vault_policy" "dynatrace" {
  name = "dynatrace-team"

  policy = <<EOT

path "dynatracekv/*" {
	capabilities = ["read","list"]
}
EOT
}