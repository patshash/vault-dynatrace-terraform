# Dynatrace Vault Terraform Module

A Terraform module for securely managing Dynatrace secrets and configurations.

## Features

- Secure storage and synchronisation of credentials using Vault.
- Automated provisioning and configuration of Dynatrace resources
- Integration with Dynatrace APIs via Terraform providers

## Requirements

- [Terraform](https://www.terraform.io/downloads.html)
- Dynatrace Terraform provider
  - [Configure the provider](https://registry.terraform.io/providers/dynatrace-oss/dynatrace/latest/docs)
  - [More details here](https://docs.dynatrace.com/docs/deliver/configuration-as-code/terraform)
- To manage Dynatrace users, please define the environment variables `DT_CLUSTER_URL` and `DT_CLUSTER_API_TOKEN` with the cluster API token scope Service Provider API (ServiceProviderAPI).
- Vault Terraform provider
  - [Configure Vault provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)

## Usage

1. **Initialize and apply:**
    ```bash
    terraform init
    terraform apply
    ```

## Contributing

Contributions are welcome! Please open issues or submit pull requests.

## License

This project is licensed under the MIT License.