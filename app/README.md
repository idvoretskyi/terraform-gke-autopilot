# Demo Go Application

A simple web application designed to demonstrate deployment on GKE Autopilot cluster.

## Features

- Simple HTTP server with multiple endpoints
- Health check endpoint for Kubernetes probes
- JSON API endpoint with application information
- Web interface with application details
- Docker containerization ready
- Kubernetes deployment manifests included

## Endpoints

- `GET /` - Web interface with application information
- `GET /health` - Health check endpoint (returns JSON)
- `GET /api/info` - JSON API with application details

## Local Development

### Prerequisites

- Go 1.21 or later
- Docker (for containerization)

### Running Locally

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Run the application:
   ```bash
   go run main.go
   ```

3. Open your browser and visit: http://localhost:8080

## Docker Build

1. Build the Docker image:
   ```bash
   cd app
   docker build -t demo-go-app:latest .
   ```

2. Run the container locally:
   ```bash
   docker run -p 8080:8080 demo-go-app:latest
   ```

## Deploy to GKE Autopilot

### Prerequisites

1. GKE Autopilot cluster deployed (use the Terraform configuration in the parent directory)
2. Docker image pushed to a container registry
3. `kubectl` configured to access your cluster

### Steps

1. **Build and push the Docker image to Google Container Registry:**
   ```bash
   cd app
   
   # Get your project ID
   PROJECT_ID=$(gcloud config get-value project)
   
   # Build and tag the image
   docker build -t gcr.io/$PROJECT_ID/demo-go-app:latest .
   
   # Push to GCR
   docker push gcr.io/$PROJECT_ID/demo-go-app:latest
   ```

2. **Update the Kubernetes deployment with your image:**
   ```bash
   cd ../k8s
   
   # Replace the image reference in deployment.yaml
   sed -i "s|demo-go-app:latest|gcr.io/$PROJECT_ID/demo-go-app:latest|g" deployment.yaml
   ```

3. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f deployment.yaml
   ```

4. **Check the deployment status:**
   ```bash
   kubectl get deployments
   kubectl get pods
   kubectl get services
   ```

5. **Get the external IP address:**
   ```bash
   kubectl get service demo-go-app-service
   ```
   
   Wait for the `EXTERNAL-IP` to be assigned (it may take a few minutes).

6. **Access your application:**
   Once you have the external IP, you can access your application at:
   ```
   http://EXTERNAL-IP
   ```

## Kubernetes Resources

The deployment creates:

- **Deployment**: Runs 2 replicas of the Go application with resource limits
- **Service**: LoadBalancer service exposing the application on port 80
- **Health Checks**: Liveness and readiness probes using the `/health` endpoint

## Resource Configuration

- **CPU Request**: 100m (0.1 CPU cores)
- **CPU Limit**: 500m (0.5 CPU cores)  
- **Memory Request**: 128Mi
- **Memory Limit**: 256Mi

These settings are optimized for cost-efficiency on GKE Autopilot.

## Cleanup

To remove the application from your cluster:

```bash
kubectl delete -f k8s/deployment.yaml
```