# Login to Azure (if not already logged in)
az login --only-show-errors

# Get all storage accounts in the subscription
$storageAccounts = az storage account list --query "[].{name:name, resourceGroup:resourceGroup, tls:minimumTlsVersion}" --output json | ConvertFrom-Json

# Filter storage accounts that do not have TLS 1.2
$nonCompliantStorageAccounts = $storageAccounts | Where-Object { $_.tls -ne "TLS1_2" }

if ($nonCompliantStorageAccounts.Count -eq 0) {
    Write-Host "All storage accounts are already set to TLS 1.2."
} else {
    Write-Host "Updating storage accounts to use TLS 1.2..."

    foreach ($storageAccount in $nonCompliantStorageAccounts) {
        Write-Host "Updating $($storageAccount.name) in $($storageAccount.resourceGroup)..."

        az storage account update --name $storageAccount.name `
                                  --resource-group $storageAccount.resourceGroup `
                                  --set minimumTlsVersion=TLS1_2

        Write-Host "Updated $($storageAccount.name) to TLS 1.2."
    }

    Write-Host "All non-compliant storage accounts have been updated."
}