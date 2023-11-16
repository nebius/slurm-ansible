# Nebius NFS Module

This Terraform module provisions an NFS server on Nebius Cloud. It creates a virtual machine with a secondary disk attached, formats the disk, and sets up an NFS server that exports the disk as an NFS share.

## Module Structure

The module includes the following files and directories:

- `main.tf` - The main Terraform configuration file for the module.
- `variables.tf` - Definitions of variables used within the module.
- `outputs.tf` - Outputs after the module has been applied.
- `provider.tf` - The provider configuration file (to be filled in with your provider's details).
- `files/`
  - `cloud-config.sh` - A shell script that initializes the NFS server on the virtual machine.


## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export YC_TOKEN=$(ncp iam create-token)
```


## Usage


To use this module in your Terraform environment, you will need to create a Terraform configuration for example file `terraform.tfvars` with example conent:

```hcl
folder_id = "bjebhkj34fo1db6n4gdu"
sshkey = "<ssh_key>"
cluster_nodes_count = 4
```

Then you need to postinstall slurm config with ansbile
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yaml update-conf.yaml
```
