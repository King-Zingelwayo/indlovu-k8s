#!/bin/bash
set -e

echo "=========================================="
echo "Kubernetes Cluster Test Script"
echo "=========================================="
echo ""

# Check cluster status
echo "1. Checking cluster status..."
kubectl cluster-info
echo ""

# Check nodes
echo "2. Checking nodes..."
kubectl get nodes -o wide
echo ""

# Verify all nodes are ready
NOT_READY=$(kubectl get nodes --no-headers | grep -v " Ready " | wc -l)
if [ "$NOT_READY" -gt 0 ]; then
    echo "Warning: Some nodes are not ready!"
    exit 1
fi
echo "✓ All nodes are ready"
echo ""

# Check system pods
echo "3. Checking system pods..."
kubectl get pods -n kube-system
echo ""

# Verify all system pods are running
NOT_RUNNING=$(kubectl get pods -n kube-system --no-headers | grep -v "Running\|Completed" | wc -l)
if [ "$NOT_RUNNING" -gt 0 ]; then
    echo "Warning: Some system pods are not running!"
fi
echo ""

# Deploy test application
echo "4. Deploying test nginx application..."
kubectl apply -f k8s-examples/nginx-deployment.yaml
echo ""

# Wait for deployment
echo "5. Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/nginx-deployment
echo ""

# Check deployment
echo "6. Checking deployment..."
kubectl get deployments
kubectl get pods -l app=nginx
kubectl get svc nginx-service
echo ""

# Get NodePort
NODE_PORT=$(kubectl get svc nginx-service -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

echo "7. Testing connectivity..."
echo "Service available at: http://$NODE_IP:$NODE_PORT"
echo ""

# Show resource usage
echo "8. Resource usage..."
kubectl top nodes 2>/dev/null || echo "Metrics server not installed (optional)"
echo ""

echo "=========================================="
echo "Test Complete!"
echo "=========================================="
echo ""
echo "Cleanup commands:"
echo "  kubectl delete -f k8s-examples/nginx-deployment.yaml"
echo ""
