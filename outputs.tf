# Output the secret ID for use in other resources
# Used for debugging and testing purposes.
output "AppRoleSecretID" {
  value = vault_approle_auth_backend_role_secret_id.id.secret_id
  sensitive = true
}

# Output the secret ID for use in other resources
# Used for debugging and testing purposes.
output "AppRoleRoleID" {
  value = vault_approle_auth_backend_role.example.role_id
}