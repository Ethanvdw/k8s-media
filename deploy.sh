#!/bin/bash

# Set namespace
NAMESPACE="media"

echo "🧹 Cleaning up existing resources..."
# Delete existing deployments and services
kubectl delete deployment --all -n $NAMESPACE 2>/dev/null || true
kubectl delete service --all -n $NAMESPACE 2>/dev/null || true
kubectl delete configmap --all -n $NAMESPACE 2>/dev/null || true
kubectl delete secret --all -n $NAMESPACE 2>/dev/null || true
kubectl delete pvc --all -n $NAMESPACE 2>/dev/null || true

# Delete namespace if it exists
kubectl delete namespace $NAMESPACE 2>/dev/null || true

echo "⏳ Waiting for resources to be deleted..."
sleep 5

echo "🏗️ Creating namespace..."
kubectl create namespace $NAMESPACE

# In deploy.sh, after creating namespace
echo "📁 Creating base PVCs..."
kubectl apply -f manifests/base/pvcs.yaml

echo "⏳ Waiting for storage provisioning..."
sleep 10

echo "📁 Creating storage structure..."
kubectl apply -f manifests/apps/storage-structure.yaml
echo "⏳ Waiting for storage initialization..."
sleep 5

echo "⚙️ Applying ConfigMaps and Secrets..."
kubectl apply -f manifests/configs/qbittorrent-config.yaml
kubectl apply -f manifests/configs/sabnzbd-config.yaml
kubectl apply -f manifests/configs/radarr-config.yaml
kubectl apply -f manifests/configs/sonarr-config.yaml
kubectl apply -f manifests/configs/jellyfin-config.yaml

echo "📦 Deploying applications..."
# Deploy downloaders
kubectl apply -f manifests/apps/qbittorrent.yaml
kubectl apply -f manifests/apps/sabnzbd.yaml

# Deploy media managers
kubectl apply -f manifests/apps/radarr.yaml
kubectl apply -f manifests/apps/sonarr.yaml
kubectl apply -f manifests/apps/jellyfin.yaml

echo "⏳ Waiting for pods to start..."
sleep 10

echo "📊 Checking deployment status..."
kubectl get pods -n $NAMESPACE

echo "🌐 Service URLs:"
echo "Radarr:      http://media:7878"
echo "Sonarr:      http://media:8989"
echo "Jellyfin:    http://media:8096"
echo "qBittorrent: http://media:8080"
echo "SABnzbd:     http://media:8090"

echo "✅ Deployment complete!"
echo ""
echo "Default credentials:"
echo "qBittorrent: admin/adminadmin (please change on first login)"
echo "Other services will require initial setup on first access"
echo ""
echo "To check pod status:"
echo "kubectl get pods -n media"
echo ""
echo "To check logs for a specific pod:"
echo "kubectl logs -f -n media deploy/[podname]"
echo ""
echo "To restart a deployment:"
echo "kubectl rollout restart deployment [podname] -n media"