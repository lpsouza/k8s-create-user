# User creator for Kubernetes

This script creates a user in Kubernetes and adds it to the specified groups.

## Usage

```bash
./create-user.sh <username> <group>
```

## Examples

```bash
# Create a user and add it to the group "developers"
./create-user.sh john developers
```

## Get a list of groups

```bash
# Cluster roles
kubectl get clusterrolebindings -o json | jq -r '.items[] | select(.subjects[0].kind=="Group") | .metadata.name'

# Roles from all namespaces
kubectl get rolebindings -A -o json | jq -r '.items[] | select(.subjects[0].kind=="Group") | .metadata.name'
```
