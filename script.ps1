# Define a function to extract the creation date from the table name
function Get-CreationDateFromTableName {
    param (
        [string]$tableName
    )

    $datePattern = '\d{8}$'  # Assuming the date is in the format "YYYYMMDD" at the end of the storage account name
    $match = [regex]::Match($tableName, $datePattern)
    if ($match.Success) {
        $creationDate = [datetime]::ParseExact($match.Value, 'yyyyMMdd', $null)
        return $creationDate
    } else {
        return $null
    }
}

function PurgeOldAzureTablesStorage {
    param (
        [int] $maxDurationDays
    )
    Connect-AzAccount
    $Storageaccounts = Get-AzStorageAccount

    # Loop through each storage account
    foreach ($storageAccount in $storageAccounts) {
        $accountName = $storageAccount.StorageAccountName

        # Get all tables in the storage account
        $tables = Get-AzStorageTable -Context (New-AzStorageContext -StorageAccountName $accountName )

        # Loop through each table
        foreach ($table in $tables) {
            $tableName = $table.Name
            $creationTime = Get-CreationDateFromTableName -tableName $tableName
            if ($null -ne $creationTime) {
                # Calculate the duration since the table was created
                $durationDays = (Get-Date) - $creationTime | Select-Object -ExpandProperty Days

                # Check if the table exceeds the maximum duration
                if ($durationDays -gt $maxDurationDays) {
                    Write-Host "Deleting table '$tableName' in storage account '$accountName'  created $durationDays days ago."

                    # Uncomment the line below to actually delete the table
                    Remove-AzStorageTable -Context $table.Context -Name $tableName -Force
                }
            }
        }
    }
}



PurgeOldAzureTablesStorage -maxDurationDays 10

