terraform {
    required_providers {
        dynatrace = {
            version = "~> 1.78.0"
            source = "dynatrace-oss/dynatrace"
        }
        vault = {
            version = "~> 4.7.0"
            source = "hashicorp/vault"
        }
    }
} 

# Create an Credential using AppRole SecretID to showcase how TFE can manage this.
resource "dynatrace_credentials" "AppRoleSecretID" {
  name     = "TFE_Secret_ID"
  scopes    = ["SYNTHETIC"]
  token = vault_approle_auth_backend_role_secret_id.id.secret_id
}

# Create an example Secret to showcase how TFE can manage this.
resource "dynatrace_credentials" "ExampleCredential" {
  name     = "TFE_Example_Secret"
  scopes    = ["SYNTHETIC"]
  
  # Here we will manually set the username and password, but in a real-world scenario, you would use the secret ID from Vault.
  # This also works around a bug in the Dynatrace provider that currently doesn't support the external block.
  
  #token = vault_approle_auth_backend_role_secret_id.id.secret_id
  username = "secretuser"
  password = "secretpassword"

  # Restrict access to our new user.
  owner_access_only = false
  allowed_entities {
    entity {
      type = "USER"
      id   = dynatrace_iam_user.new_user.id
    }
  }
  description = "Example value for credentials"
}

/*
# This is our proper configuration for AppRole that will consume a SecretID inject by Terrafor, and sync a KV value from Vault.
resource "dynatrace_credentials" "KVSync1" {
  name     = "TFEAppRoleSync1"
  scopes    = ["SYNTHETIC"]
  external {
    path_to_credentials = "kv/data/dynatrace"

    # x_secret_name represent the Key of the value in the vault KV.
    username_secret_name = "secretusername"
    password_secret_name = "secretpassword"
    
    # AppRole details configured within Vault.
    roleid = vault_approle_auth_backend_role.example.role_id
    secretid = dynatrace_credentials.AppRoleSecretID.id

    # Vault namespace and URL, use the 'admin' namespace for HCP Vault.
    vault_namespace = "admin"
    vault_url = "https://vault-cluster.hashicorp.cloud:8200"
  }
}
*/
# Create a synthetic monitor using the credentials.
# This is a simple monitor that will check the availability of google.com every 60 seconds.
resource "dynatrace_http_monitor" "synthetic_monitor" {
  name      = "synthetic_monitor"
  frequency = 60
  locations = ["GEOLOCATION-F3E06A526BE3B4C4"]
  enabled = true
  anomaly_detection {
    loading_time_thresholds {
    }
    outage_handling {
    }
  }
  script {
    request {
      description     = "Google monitor"
      method          = "GET"
      url             = "https://google.com"
      # Add the credentials to the request from the credential store.
      authentication {
        type = "BASIC_AUTHENTICATION"
        # Use the unqiue ID of the credentials created above. User must have access to the credentials.
        credentials = dynatrace_credentials.ExampleCredential.id
      }
    }
  }
}

# Create a new user who will have access to the credentials.
# This user will need to accept the email invitation to join Dynatrace and be active for demo use.
resource "dynatrace_iam_user" "new_user" {
  email  = "pcarey+user1@hashicorp.com"
  groups = [ data.dynatrace_iam_group.standard_user.id ]
}

# Add the user to the group.
data "dynatrace_iam_group" "standard_user" {
  name = "Default group with all users"
}

