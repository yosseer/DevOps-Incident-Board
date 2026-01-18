cat > deploy-simple.sh << 'EOF'
#!/bin/bash
PROJECT_NAME="incident-board-devops-app"

echo "🚀 Deploying to $PROJECT_NAME..."

# Create project
oc new-project $PROJECT_NAME --display-name="DevOps Incident Board"

# Apply all YAML files from your repo
echo "Applying configuration files..."
# Find and apply all YAML files, fixing namespaces
find . -name "*.yaml" -exec sed -i "s/namespace: incident-board/namespace: $PROJECT_NAME/g" {} \;
find . -name "*.yaml" -exec sed -i "s/namespace: devops-incident-board/namespace: $PROJECT_NAME/g" {} \;
find . -name "*.yaml" -exec oc apply -f {} \;

echo "✅ Deployment started!"
echo "Frontend URL: https://$(oc get route frontend -n $PROJECT_NAME -o jsonpath='{.spec.host}')"
EOF