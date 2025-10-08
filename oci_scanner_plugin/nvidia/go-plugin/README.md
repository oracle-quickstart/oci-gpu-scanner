
How to deploy on k8s:
kubectl apply -f k8s/namespace.yaml

# 2. Apply RBAC
kubectl apply -f k8s/rbac.yaml

# 3. Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# 4. Apply Service
kubectl apply -f k8s/service.yaml

# 5. Apply DaemonSet
kubectl apply -f k8s/daemonset.yaml



How to deploy on k8s:
kubectl delete -f k8s/namespace.yaml

# 2. Apply RBAC
kubectl delete -f k8s/rbac.yaml

# 3. Apply ConfigMap
kubectl delete -f k8s/configmap.yaml

# 4. Apply Service
kubectl delete -f k8s/service.yaml

# 5. Apply DaemonSet
kubectl delete -f k8s/daemonset.yaml