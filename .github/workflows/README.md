# GitHub Actions Workflows

## Deploy to Azure Container Registry

The `deploy-to-acr.yml` workflow automatically builds and pushes the Docker image to Azure Container Registry (ACR) when code is pushed to the `main` branch.

### Required Secrets

Configure the following secrets in your GitHub repository settings:

- `ACR_LOGIN_SERVER` - Your Azure Container Registry login server (e.g., `myregistry.azurecr.io`)
- `ACR_USERNAME` - Azure Container Registry username
- `ACR_PASSWORD` - Azure Container Registry password
- `ENV` - Environment variables for the application (see below)

### Security Design

For security reasons, the `.env` file is **NOT baked into the Docker image**. This prevents secrets from being exposed in image layers which could be extracted by anyone with access to the container image in ACR.

Instead, environment variables should be provided to the container at runtime using one of these methods:

#### Option 1: Environment Variables (Recommended)

When running the container, pass environment variables directly:

```bash
docker run -e FOUNDRY_ENDPOINT="..." -e FOUNDRY_KEY="..." ... myregistry.azurecr.io/techworkshop-app:latest
```

Or for Azure Container Instances:
```bash
az container create \
  --resource-group myResourceGroup \
  --name mycontainer \
  --image myregistry.azurecr.io/techworkshop-app:latest \
  --environment-variables 'FOUNDRY_ENDPOINT=...' 'FOUNDRY_KEY=...' ...
```

#### Option 2: Volume Mount with .env File

Create a `.env` file on the host and mount it into the container:

```bash
# Create .env file on host (using the ENV secret content)
echo "$ENV_CONTENT" > /path/to/.env

# Run container with volume mount
docker run -v /path/to/.env:/app/.env myregistry.azurecr.io/techworkshop-app:latest
```

#### Option 3: Azure App Service Configuration

If deploying to Azure App Service, use Application Settings to configure environment variables through the Azure Portal or CLI.

### Workflow Features

- ✅ Triggers on push to `main` branch
- ✅ Manual trigger support via `workflow_dispatch`
- ✅ Validates all required secrets are configured
- ✅ Concurrency control to prevent simultaneous deployments
- ✅ Tags images with both commit SHA and `latest`
- ✅ Secure - no secrets baked into image layers

### Manual Trigger

You can manually trigger this workflow from the GitHub Actions tab, which is useful for:
- Testing deployments
- Deploying specific commits
- Rollbacks

### ENV Secret Format

The `ENV` secret should contain all environment variables in the format shown in `src/env_sample.txt`:

```
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT="true"
FOUNDRY_ENDPOINT="..."
FOUNDRY_KEY="..."
# ... etc
```

These values will be used when running the container, not during the build process.
