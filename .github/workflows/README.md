# GitHub Actions Workflows

## Deploy to Azure Container Registry

The `deploy-to-acr.yml` workflow automatically builds and pushes the Docker image to Azure Container Registry (ACR) when code is pushed to the `main` branch.

### Required Secrets

Configure the following secrets in your GitHub repository settings:

- `ACR_LOGIN_SERVER` - Your Azure Container Registry login server (e.g., `myregistry.azurecr.io`)
- `ACR_USERNAME` - Azure Container Registry username
- `ACR_PASSWORD` - Azure Container Registry password
- `ENV` - Environment variables for the application in the format shown in `src/env_sample.txt`

### How It Works

The workflow:
1. Checks out the code from the repository
2. Creates a `.env` file in the `src/` directory using the content from the `ENV` secret
3. Logs into Azure Container Registry
4. Builds the Docker image (which includes the `.env` file)
5. Tags the image with both the commit SHA and `latest`
6. Pushes both tagged images to ACR
7. Cleans up the `.env` file from the workspace

### Security Considerations

⚠️ **Important Security Note**: This workflow copies the `.env` file into the Docker image layers during build. While this makes deployment simpler, be aware that:

- Anyone with access to the container image in ACR can potentially extract the environment variables from the image layers
- For production environments with highly sensitive secrets, consider using:
  - Azure Key Vault references in Azure App Service
  - Azure Container Instances with secure environment variables
  - Kubernetes secrets if deploying to AKS
  - Docker BuildKit secrets for build-time secrets that don't persist in layers

The `.env` file is automatically cleaned up from the GitHub Actions workspace after the build and is excluded from git via `.gitignore`, so it will never be committed to the repository.

### Workflow Features

- ✅ Triggers on push to `main` branch (only when files in `src/` change)
- ✅ Manual trigger support via `workflow_dispatch`
- ✅ Concurrency control to prevent simultaneous deployments
- ✅ Tags images with both commit SHA and `latest` for version tracking
- ✅ Automatic cleanup of `.env` file from workspace

### Manual Trigger

You can manually trigger this workflow from the GitHub Actions tab, which is useful for:
- Testing deployments
- Deploying specific commits
- Triggering builds without code changes

### ENV Secret Format

The `ENV` secret should contain all environment variables in the format shown in `src/env_sample.txt`:

```
OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT="true"
AZURE_TRACING_GEN_AI_CONTENT_RECORDING_ENABLED="true"
FOUNDRY_ENDPOINT="https://..."
FOUNDRY_KEY="your-key-here"
FOUNDRY_API_VERSION="2025-01-01-preview"
# ... etc
```

Each line should be in the format `KEY="value"` or `KEY=value`.

### Image Naming

The Docker image is pushed to ACR with the name `chat-app` and tagged with:
- The commit SHA (e.g., `chat-app:abc123...`)
- The `latest` tag (e.g., `chat-app:latest`)

This allows you to deploy either a specific version or always pull the latest build.
