$dbName = SQL01
$configDbName = SharePoint_Config
$adminContentDbName = SharePoint_Admin_Content_DB
$role = SingleServerFarm
New-SPConfigurationDatabase -DatabaseName $configDbName -
DatabaseServer $dbName -AdministrationContentDatabaseName $adminContentDbName -LocalServerRole $role -Verbose