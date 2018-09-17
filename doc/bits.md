# Prepare the bits

The deployment needs two files that you need to download first from the IBM and Microsoft web sites, and then make them available to the scripts that would download them in an unattended way from the different nodes that need them.

File name | Description | URL
----------|-------------|-----
`lis-rpms-4.2.x.tar.gz` | Linux Integration Services v4.2 for Hyper-V and Azure | <https://www.microsoft.com/en-us/download/details.aspx?id=55106>
`v11.1_linuxx64_server_t.tar.gz` | DB2 trial bits | <https://www.ibm.com/analytics/us/en/db2/trials/>

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

The following block should not have to be changed. 
It creates the resource group, the storage account and creates a container into it.
Then a shared access policy is created on that container to provide read access for some time.

```bash
az group create --name $rg1 --location $location
az storage account create -g $rg1 --name $stor1 --kind StorageV2 --sku Standard_LRS --https-only true 
az storage container create --account-name $stor1 --name "setup" --public-access off
az storage container policy create --account-name $stor1 --container-name "setup" --name "readuntileofcy2020" --expiry "2020-12-31T23:59:59Z" --permissions "r"
```

## downloads the bits from Microsoft web site

Download file `lis-rpms-4.2.6.tar.gz` (Linux Integration Services v4.2 for Hyper-V and Azure) from <https://www.microsoft.com/en-us/download/details.aspx?id=55106>

NB: a more recent version may exist when you download the file. 
So let's fill a variable with the exact name we have, and the generic one that will be used in the [db2_root.sh](../deployment/initscripts/helperscripts/db2_root.sh) script. 
Let's also have another variable that points to the location where the file was downloaded.

```bash
lisbitsfilename=lis-rpms-4.2.6.tar.gz
lisbitsgenericfilename=lis-rpms-4.2.x.tar.gz
downloadlocation=/mnt/c/Users/bengui/Downloads
```

## download the bits from IBM web site

Download file `v11.1_linuxx64_server_t.tar.gz` (DB2 trial) from <https://www.ibm.com/analytics/us/en/db2/trials/>

Choose the following in the IBM web site:
- IBM Db2 database
- DB2 with BLU Acceleration for Linux, UNIX and Windows
- optionally: Download using http
- DB2 11.1 data server trial for Linux® on AMD64 and Intel® EM64T systems (x64) - v11.1_linuxx64_server_t.tar.gz  (1949 MB) 

```bash
db2bitsfilename=v11.1_linuxx64_server_t.tar.gz
```

## Upload to Azure storage and get the URLs for the bits (thru Shared Access Signature)

```bash
az storage blob upload --account-name $stor1 --container-name "setup" --name "$lisbitsgenericfilename" --file "$downloadlocation/$lisbitsfilename"
az storage blob upload --account-name $stor1 --container-name "setup" --name "$db2bitsfilename" --file "$downloadlocation/$db2bitsfilename"
```

Then we can get the shared access signature URLs from those blobs:

```bash
lisbitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$lisbitsgenericfilename" --output tsv`
db2bitssas=`az storage blob generate-sas --account-name $stor1 --container-name "setup" --policy-name "readuntileofcy2020" --name "$db2bitsfilename" --output tsv`
```

## clone the db2OnAzure GitHub repo

```bash
cd $localGitFolderpath
git clone $githubRepoCloneUrl
```

## update the `01init.sh` file

Update the `01init.sh` file based on:
- the steps you followed previously in [bits](bits.md)
- the names you choose (like `dateid` or `adwinPassword`)
- your environment (e.g.: `subscription`)
