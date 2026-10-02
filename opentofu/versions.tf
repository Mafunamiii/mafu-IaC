terraform {
  # Declare the providers this OpenTofu configuration depends on.
  required_providers {
    azurerm = {
      # Azure Resource Manager provider from the Terraform registry.
      source = "hashicorp/azurerm"

      # Allow compatible 4.x releases, but don't automatically jump to 5.x.
      version = "~> 4.0"
    }
  }

  # Minimum OpenTofu/Terraform-compatible configuration version.
  required_version = ">= 1.6.0"
}

# Configure the Azure provider.
# Authentication will use the Azure CLI session on this machine.
provider "azurerm" {
  # Required by the AzureRM provider to enable its functionality.
  features {}
}
