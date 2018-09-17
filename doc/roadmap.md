# Roadmap, Possible enhancements, Ideas

## scale out the IOs

In the current setup, we have several Db2 members accessing several disks in a GlusterFS cluster.

## add tests

A first simple version could be to add SQL statements that put some load on the database.

Then, we should also add a way to test with a more realistic workload. The following tools may be good candidates:
- [HammerDB](https://hammerdb.com/)

## leverage other tools for IOs

The following tools may be tried to see how they can enhance the current setup:
- [dysk](https://github.com/khenidak/dysk)

## Use a DNS instead of `hosts` files

The current setup leverages hosts. Azure DNS can be used for private VNET, so it could be leveraged.

## Enhance the way SSH keys are distributed

The current setup leverages bash only to distribute SSH keys. 
Azure VM Managed identities and KeyVault could be leveraged instead.

resources:
- <https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/tutorial-linux-vm-access-nonaad>

first ideas, as bash script:

```bash
az keyvault secret set --vault-name 'myvault' -n 'secret-name' -f '~/.ssh/id_rsa' 
az keyvault secret show --vault-name myvault --name 'secret-name' | jq -r .value > ~/.ssh/mykey 
ssh-keygen -y -f ~/.ssh/myfile > ~/.ssh/myfile.pub
```
