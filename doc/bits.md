# Prepare the bits

The deployment needs two files that you need to download first from the IBM and Microsoft web sites, and then make them available to the scripts that would download them in an unattended way from the different nodes that need them.

File name | Description | URL
----------|-------------|-----
`v11.1_linuxx64_server_t.tar.gz` | DB2 trial bits | <https://www.ibm.com/analytics/us/en/db2/trials/>
`lis-rpms-4.2.4-2.tar.gz` | Linux Integration Services v4.2 for Hyper-V and Azure | <https://www.microsoft.com/en-us/download/details.aspx?id=55106>

This documentation assumes you're using DB2 trial bits, but you may prefer to get the real bits. Please contact your IBM sales representative to know how to get those instead.

## Create a storage account

The way to make the bits available to the scripts is to copy them to a storage account, then get a URL that we'll provide to the scripts.

First, let's create a storage account in the Azure subscription.

The following block initializes a few variables. The `stor1` needs to be globally unique, so you need to choose your own and follow the rules documented [here](https://docs.microsoft.com/en-us/rest/api/storageservices/Naming-and-Referencing-Containers--Blobs--and-Metadata#resource-names).

```bash
rg1=b_db2_7up
stor1=db27up34
location=westeurope
```

The following block should not have to be changed

```
az group create --name $rg1 --location $location
az storage account create ...
```

## download the bits from IBM web site



## Upload to Azure storage and get the URL for the bits (thru Shared Access Signature)

```bash
```

## clone the db2OnAzure GitHub repo

```bash
cd $localGitFolderpath
git clone $githubRepoCloneUrl
```

## update the `01init.sh` file

