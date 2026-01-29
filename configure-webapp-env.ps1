# Script to configure Azure Web App environment variables for Zava Chat App
# This sets all required environment variables for the deployed application

$resourceGroup = "techworkshop-l300"
$webAppName = "mq43qjornukki-app"

Write-Host "Configuring environment variables for $webAppName..." -ForegroundColor Cyan

# Get AI Foundry account information
Write-Host "Retrieving AI Foundry endpoints..." -ForegroundColor Yellow
$aiFoundryEndpoint = az cognitiveservices account show `
    --name "aif-mq43qjornukki" `
    --resource-group $resourceGroup `
    --query "properties.endpoint" `
    --output tsv

$aiFoundryKey = az cognitiveservices account keys list `
    --name "aif-mq43qjornukki" `
    --resource-group $resourceGroup `
    --query "key1" `
    --output tsv

# Construct AI Foundry project endpoint
# The project endpoint is: https://{region}.api.azureml.ms/v1.0/subscriptions/{sub-id}/resourceGroups/{rg-name}/providers/Microsoft.MachineLearningServices/workspaces/{project-name}
# However, for AI Projects (Foundry projects), we use the AIServices endpoint with project scope
$subscriptionId = (az account show --query id --output tsv)
$foundryProjectEndpoint = "https://aif-mq43qjornukki.cognitiveservices.azure.com/projects/proj-mq43qjornukki"

# Get Cosmos DB information
Write-Host "Retrieving Cosmos DB endpoints..." -ForegroundColor Yellow
$cosmosEndpoint = "https://mq43qjornukki-cosmosdb.documents.azure.com:443/"
$cosmosKey = az cosmosdb keys list `
    --name "mq43qjornukki-cosmosdb" `
    --resource-group $resourceGroup `
    --query "primaryMasterKey" `
    --output tsv

# Get Storage Account information
Write-Host "Retrieving Storage Account connection string..." -ForegroundColor Yellow
$storageConnectionString = az storage account show-connection-string `
    --name "mq43qjornukkisa" `
    --resource-group $resourceGroup `
    --query "connectionString" `
    --output tsv

# Get Application Insights connection string
Write-Host "Retrieving Application Insights connection string..." -ForegroundColor Yellow
$appInsightsConnectionString = az monitor app-insights component show `
    --app "mq43qjornukki-cosu-ai" `
    --resource-group $resourceGroup `
    --query "connectionString" `
    --output tsv

Write-Host "All endpoints retrieved successfully!" -ForegroundColor Green
Write-Host ""

# Configure all environment variables
Write-Host "Setting environment variables in Web App..." -ForegroundColor Cyan

az webapp config appsettings set `
    --name $webAppName `
    --resource-group $resourceGroup `
    --settings `
        "FOUNDRY_ENDPOINT=$foundryProjectEndpoint" `
        "FOUNDRY_KEY=$($aiFoundry.key)" `
        "FOUNDRY_API_VERSION=2025-01-01-preview" `
        "gpt_endpoint=$($aiFoundry.endpoint)" `
        "gpt_deployment=gpt-5-mini" `
        "gpt_api_key=$($aiFoundry.key)" `
        "gpt_api_version=2025-01-01-preview" `
        "phi_4_endpoint=$($aiFoundry.endpoint)" `
        "phi_4_deployment=Phi-4" `
        "phi_4_api_key=$($aiFoundry.key)" `
        "phi_4_api_version=2024-05-01-preview" `
        "embedding_endpoint=$($aiFoundry.endpoint)" `
        "embedding_deployment=text-embedding-3-large" `
        "embedding_api_key=$($aiFoundry.key)" `
        "embedding_api_version=2025-01-01-preview" `
        "blob_connection_string=$storageConnectionString" `
        "storage_account_name=mq43qjornukkisa" `
        "storage_container_name=zava" `
        "COSMOS_ENDPOINT=$cosmosEndpoint" `
        "COSMOS_KEY=$cosmosKey" `
        "DATABASE_NAME=zava" `
        "CONTAINER_NAME=product_catalog" `
        "APPLICATIONINSIGHTS_CONNECTION_STRING=$appInsightsConnectionString" `
        "MCP_SERVER_URL=http://localhost:8000/mcp-inventory/sse" `
        "customer_loyalty=customer-loyalty" `
        "inventory_agent=inventory-agent" `
        "interior_designer=interior-designer" `
        "cora=cora" `
        "cart_manager=cart-manager" `
        "handoff_service=handoff-service" `
        "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true" `
        "AZURE_TRACING_GEN_AI_CONTENT_RECORDING_ENABLED=true" `
        "WEBSITES_PORT=8000" `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "Environment variables configured successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Restarting web app to apply changes..." -ForegroundColor Cyan
    
    az webapp restart --name $webAppName --resource-group $resourceGroup --output none
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Web app restarted successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your application should now be accessible at:" -ForegroundColor Green
        Write-Host "   https://mq43qjornukki-app.azurewebsites.net" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Note: It may take 1-2 minutes for the app to fully start." -ForegroundColor Yellow
    } else {
        Write-Host "Failed to restart web app. You may need to restart it manually." -ForegroundColor Red
    }
} else {
    Write-Host "Failed to configure environment variables." -ForegroundColor Red
    Write-Host "Please check the error messages above and try again." -ForegroundColor Red
}
