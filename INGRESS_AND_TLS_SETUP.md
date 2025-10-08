# Ingress and TLS Setup Prerequisites

This guide covers the ingress and TLS prerequisites for the Corrino Lens Helm chart installation. The chart automatically installs **ingress-nginx**, **cert-manager**, and configures **Let's Encrypt** for TLS certificates.

## Overview

The Corrino Lens Helm chart automatically installs and configures:

1. **ingress-nginx** (v4.13.2) - Kubernetes Ingress Controller
2. **cert-manager** (v1.13.2) - Automated TLS certificate management
3. **Let's Encrypt ClusterIssuer** - Production ACME certificates

**Important:** These components are **always installed** as Helm subchart dependencies and cannot currently be disabled. Customizable options are coming soon in the future release!

### Architecture

```
Internet → [LoadBalancer Service] → [ingress-nginx Controller] → [Ingress Resources] → [Application Services]
```

### Components Created

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| ingress-nginx controller | `ingress-nginx` | Routes traffic based on hostnames |
| cert-manager | `cert-manager` | Manages TLS certificates |
| Let's Encrypt ClusterIssuer | cluster-wide | Issues production TLS certificates |
| Application Ingresses | `lens` | Backend, Frontend, Grafana, Prometheus |

---

## Pre-Installation: Check and Clean Up Existing Infrastructure

**Before installing**, check if ingress-nginx or cert-manager already exist in your cluster. Conflicts will cause installation failures.

### Step 1: Check for Existing Infrastructure

```bash
# Check for existing namespaces
kubectl get namespace ingress-nginx cert-manager

# Check for existing IngressClass
kubectl get ingressclass nginx

# Check for existing cert-manager CRDs
kubectl get crd | grep cert-manager

# Check for existing ClusterIssuer
kubectl get clusterissuer letsencrypt-prod

# Check for any running ingress controllers
kubectl get pods -A | grep ingress
kubectl get pods -n cert-manager
```

### Step 2: Clean Up if Infrastructure Exists

If any of the above commands return existing resources, **you must clean them up**:

```bash
# 1. Find and uninstall existing Helm releases
helm ls -A  # Find any ingress-nginx or cert-manager releases
helm uninstall <release-name> -n <namespace>

# 2. Delete infrastructure namespaces
kubectl delete namespace ingress-nginx cert-manager

# 3. Delete cert-manager CRDs (not automatically removed by Helm)
kubectl get crd | grep cert-manager | awk '{print $1}' | xargs kubectl delete crd

# 4. Delete cluster-wide resources
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found=true
kubectl delete ingressclass nginx --ignore-not-found=true

# 5. Delete webhook configurations
kubectl delete validatingwebhookconfiguration -l app.kubernetes.io/instance=cert-manager --ignore-not-found=true
kubectl delete mutatingwebhookconfiguration -l app.kubernetes.io/instance=cert-manager --ignore-not-found=true

```

### Step 3: Verify Clean State

Before proceeding with installation, verify everything is cleaned up:

```bash
# All of these should return "NotFound" or no results:
kubectl get namespace ingress-nginx cert-manager 2>&1 | grep "NotFound"
kubectl get ingressclass nginx 2>&1 | grep "NotFound"
kubectl get crd | grep cert-manager  # Should return nothing
kubectl get clusterissuer letsencrypt-prod 2>&1 | grep "NotFound"
```

✅ If verification passes, you're ready to proceed with the Helm installation!

---

## Post-Installation: Verification

After installing the Helm chart, verify all components are running correctly:

### Check Infrastructure Components

```bash
# Verify all namespaces exist
kubectl get namespace lens ingress-nginx cert-manager

# Verify controllers are running
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager

# Check IngressClass
kubectl get ingressclass nginx

# Check ClusterIssuer is ready
kubectl get clusterissuer letsencrypt-prod
```

### Check LoadBalancer

```bash
# Get external IP (wait if showing <pending>)
kubectl get svc -n ingress-nginx -l app.kubernetes.io/component=controller

# Save external IP for later use
EXTERNAL_IP=$(kubectl get svc -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "External IP: $EXTERNAL_IP"
```

### Check Ingress Resources

```bash
# View all ingress resources
kubectl get ingress -n lens

# Check specific ingress details
kubectl describe ingress lens-backend-ingress -n lens
kubectl describe ingress lens-frontend-ingress -n lens
```

### Check TLS Certificates

```bash
# View certificate status (should show READY=True)
kubectl get certificate -n lens

# Check certificate details
kubectl describe certificate lens-backend-tls -n lens
kubectl describe certificate lens-frontend-tls -n lens

# If certificates not ready, check requests and challenges
kubectl get certificaterequest -n lens
kubectl get challenge -n lens
```

## Quick Reference

### View All Resources
```bash
kubectl get namespace ingress-nginx cert-manager lens
kubectl get ingressclass
kubectl get clusterissuer
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get certificate,certificaterequest,ingress -n lens
```

### Get External IP
```bash
kubectl get svc -n ingress-nginx -l app.kubernetes.io/component=controller
```

### View Logs
```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=100
kubectl logs -n cert-manager -l app=cert-manager --tail=100
kubectl logs -n cert-manager -l app=webhook --tail=100
```

### Force Certificate Renewal
```bash
kubectl delete certificate <cert-name> -n lens
# cert-manager will automatically recreate it
```

---

## Complete Cleanup

To completely remove ingress and TLS infrastructure:

```bash
# 1. Uninstall Helm release
helm uninstall lens -n lens

# 2. Delete all namespaces
kubectl delete namespace lens ingress-nginx cert-manager

# 3. Delete cert-manager CRDs
kubectl get crd | grep cert-manager | awk '{print $1}' | xargs kubectl delete crd

# 4. Delete cluster-wide resources
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found=true
kubectl delete ingressclass nginx --ignore-not-found=true

# 5. Delete webhooks
kubectl delete validatingwebhookconfiguration -l app.kubernetes.io/instance=lens --ignore-not-found=true
kubectl delete mutatingwebhookconfiguration -l app.kubernetes.io/instance=lens --ignore-not-found=true

# 6. If namespaces stuck in Terminating state
kubectl patch namespace cert-manager -p '{"metadata":{"finalizers":[]}}' --type=merge
kubectl patch namespace ingress-nginx -p '{"metadata":{"finalizers":[]}}' --type=merge
```
---

## Additional Resources

- **ingress-nginx**: https://kubernetes.github.io/ingress-nginx/
- **cert-manager**: https://cert-manager.io/docs/
- **Let's Encrypt**: https://letsencrypt.org/docs/

**Report Issues:**
- GitHub: https://github.com/oci-ai-incubations/corrino-lens-devops

