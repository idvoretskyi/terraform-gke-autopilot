# Demo Go Application

A simple HTTP web application demonstrating deployment on a GKE Autopilot cluster.

## Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | HTML page with server info |
| `/health` | GET | Health check — returns `{"status":"healthy","timestamp":"..."}` |
| `/api/info` | GET | JSON application info (name, version, hostname, environment) |

## Local Development

### Prerequisites

- Go 1.24 or later

### Run locally

```bash
cd app
go run .
# open http://localhost:8080
```

### Run tests

```bash
cd app
go test -v ./...
```

## Docker

### Build

```bash
cd app
docker build -t demo-go-app:latest .
```

### Run

```bash
docker run -p 8080:8080 demo-go-app:latest
```

### Build with version injection

```bash
docker build \
  --build-arg VERSION=1.2.3 \
  -t demo-go-app:1.2.3 .
```

## Deploy to GKE Autopilot

### Prerequisites

1. GKE Autopilot cluster deployed (use the Terraform configuration in the parent directory)
2. `kubectl` configured to access the cluster
3. Docker image pushed to a container registry

### Steps

1. **Build and push to Google Artifact Registry (or GCR):**
   ```bash
   PROJECT_ID=$(gcloud config get-value project)
   cd app
   gcloud builds submit --tag gcr.io/$PROJECT_ID/demo-go-app:latest .
   ```

2. **Update the image reference in the manifest:**
   ```bash
   sed -i "s|<PROJECT_ID>|$PROJECT_ID|g" ../k8s/deployment.yaml
   ```

3. **Apply:**
   ```bash
   kubectl apply -f ../k8s/deployment.yaml
   kubectl get service demo-go-app-service --watch
   ```

## Resource Configuration

| Resource | Request | Limit |
|----------|---------|-------|
| CPU | 100m | 500m |
| Memory | 128Mi | 256Mi |

## Cleanup

```bash
kubectl delete -f ../k8s/deployment.yaml
```
