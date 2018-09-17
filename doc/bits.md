# Prepare the DB2 pureScale bits

## Create a storage account

```bash
rg1=b_db2_7up
storage=db27up34
location=westeurope
```

```
az group create ...
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

