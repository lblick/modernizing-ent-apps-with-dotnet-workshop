#
# Create an App Service app with deployment from GitHub
#
# This sample script creates an app in App Service with its related resources,
# and then sets up continuous deployment from a GitHub repository. For GitHub 
# deployment without continuous deployment, see Create an app and deploy code
# from GitHub. 
#
# For this sample, you need:
# - A GitHub repository with application code, that you have administrative 
#   permissions for. To get automatic builds, structure your repository 
#   according to the Prepare your repository table.
# - A Personal Access Token (PAT) for your GitHub account.
#

# General variables
$randomId=Get-Random -Minimum 10000 -Maximum 99999
$location="East US"
$tenant="697ef739-95d1-4bdb-8713-18ca3377dab3"
$subscription="2e5232f8-03a1-4529-9c05-7a67f074b553"
$resourceGroup="rg-modernize-ent-apps-$randomId"
$tag="modernize-ent-apps-dotnet"

# App Service variables
$gitrepo="https://github.com/lblick/modernizing-ent-apps-with-dotnet-workshop" # Replace the following URL with your own public GitHub repo URL if you have one
$appServicePlan="asp-modernize-ent-apps-$randomId"
$webapp="wa-modernize-ent-apps-$randomId"

# Azure SQL variables
$sqlServerName="asql-modernize-ent-apps-$randomId"
$sqlAdminUserName="sqladmin"
$sqlAdminPassword="sql@dminP@ss"
$sqlDatabaseName="db-modernize-ent-apps"
$sqlEdition="Standard"
$sqlServiceObjective="S1"

# Login to Azure and select the subscription
az login --tenant $tenant --use-device-code
az account set --subscription $subscription

# Create a resource group.
Write-Host "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create an App Service plan in `FREE` tier.
Write-Host "Creating $appServicePlan..."
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku FREE

# Create a web app.
Write-Host "Creating $webapp..."
az webapp create --name $webapp --resource-group $resourceGroup --plan $appServicePlan

# Deploy code from a public GitHub repository. 
az webapp deployment source config --name $webapp --resource-group $resourceGroup --repo-url $gitrepo --branch main --manual-integration

# Use curl to see the web app.
$site="http://$webapp.azurewebsites.net"
Write-Host $site
curl "$site" # Optionally, copy and paste the output of the previous command into a browser to see the web app

# Create Azure SQL server
az sql server create --name $sqlServerName --location $location --resource-group $resourceGroup --admin-user $sqlAdminUserName --admin-password $sqlAdminPassword

# Create Azure SQL database
az sql db create --resource-group $resourceGroup --server $sqlServerName --name $sqlDatabaseName --edition $sqlEdition --service-objective $sqlServiceObjective

