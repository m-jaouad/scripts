Describe "Get-AzureTablesToRemove Tests" {
    Mock Get-AzStorageAccount {
        # Mock Get-AzStorageAccount to return dummy storage account objects
        [PSCustomObject]@{
            StorageAccountName = "MockStorageAccount1"
            ResourceGroupName = "MockResourceGroup1"
        },
        [PSCustomObject]@{
            StorageAccountName = "MockStorageAccount2"
            ResourceGroupName = "MockResourceGroup2"
        }
    }

    Mock Get-AzStorageTable {
        # Mock Get-AzStorageTable to return dummy table objects
        [PSCustomObject]@{
            Name = "TableName20230101"  # A table name for testing
        },
        [PSCustomObject]@{
            Name = "TableName20230115"  # A table name that exceeds the max duration
        }
    }

    Mock Get-DateFromTableName {
        # Mock Get-DateFromTableName to simulate date extraction
        param($TableName)
        if ($TableName -eq "TableName20230101") {
            return Get-Date "2023-01-01"
        } elseif ($TableName -eq "TableName20230115") {
            return Get-Date "2023-01-15"
        } else {
            return $null
        }
    }

    It "Retrieves tables to be removed based on max duration" {
        # Arrange
        $expectedTables = @(
            [PSCustomObject]@{
                Name = "TableName20230115"
            }
        )

        # Act
        $result = Get-AzureTablesToRemove -MaxDurationDays 10

        # Assert
        $result | Should -Be $expectedTables -Property Name
    }
}
