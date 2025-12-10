# Ingress and TLS Setup Guide

This guide covers ingress and TLS prerequisites for Corrino Lens Helm chart installation.

## Overview

The Helm chart automatically installs as dependencies:
- **ingress-nginx** (v4.13.2) - Kubernetes Ingress Controller in `lens` namespace
- **cert-manager** (v1.13.2) - TLS certificate management in `lens` namespace  
- **Let's Encrypt ClusterIssuer** - Production ACME certificates (cluster-wide)
- **IngressClass** `lens-nginx` (cluster-wide)

**Architecture:**
```
Internet → [LoadBalancer] → [ingress-nginx] → [Ingress] → [Apps]
```

**Alternative:** If your cluster already has cert-manager and an ingress controller, you can configure the chart to use these existing components instead. See the [Using Existing cert-manager and Ingress Controller](#using-existing-cert-manager-and-ingress-controller) section for details.

**Important:** Deleting the `lens` namespace is safe and removes all namespace-scoped resources. Only delete cluster-wide resources (IngressClass, ClusterIssuer, CRDs) if certain no other applications use them.

---

## Pre-Install Check

Check for existing resources before installation:

```bash
# Check if lens namespace exists
kubectl get ns lens 2>&1

# Check for existing pods in lens namespace
kubectl get pods -n lens 2>&1

# Check cluster-wide resources
kubectl get ingressclass lens-nginx 2>&1
kubectl get clusterissuer letsencrypt-prod 2>&1
kubectl get crd | grep cert-manager
```

**If any resources exist from a previous installation, proceed to the [Uninstall](#uninstall) section.**

---

## Installation Options

### Option 1: Default Installation (with nip.io)

By default, OCI GPU Scanner uses `nip.io` for ingress, which is a wildcard DNS service that requires no manual DNS configuration. All URLs will be in the format `<service>.<LOADBALANCER_IP>.nip.io` (e.g., `lens.129.80.43.138.nip.io`).

**No DNS configuration required!** The deployment automatically uses `nip.io`, which provides wildcard DNS resolution based on the LoadBalancer IP address.

**Helm installation:**
```bash
helm install lens oci-ai-incubations/lens -n lens --create-namespace
```

**Resource Manager:** Leave the "Ingress Domain" field empty.

### Option 2: Custom Domain

If you prefer to use your own domain instead of `nip.io`, you can configure a custom domain during installation. However, you **must manually create DNS A records** in your DNS provider.

If you prefer to use `.oci-incubations.com` as your domain, contact amar.gowda@oracle.com or gabrielle.lyu@oracle.com for adding DNS A records after deployment.

**For Helm installations:**
```bash
helm install lens oci-ai-incubations/lens -n lens --create-namespace \
  --set ingress.domain="your-domain" \
  [... other parameters ...]
```

**For Resource Manager deployments:**
Enter your domain in the "Ingress Domain" field (e.g., `oci-incubations.com`).

**After deployment, create DNS A records:**

1. Get the LoadBalancer IP:
   ```bash
   kubectl get svc lens-ingress-nginx-controller -n lens
   ```
   Look for the `EXTERNAL-IP` value (e.g., `137.131.36.226`).

2. Create DNS A record in your DNS provider:
   - Record: `*.<LOADBALANCER_IP>.<YOUR_DOMAIN>` → Points to: `<LOADBALANCER_IP>`
   - Example: `*.137.131.36.226.oci-incubations.com` → `137.131.36.226`

3. Verify DNS resolution (allow 5-15 minutes for propagation):
   ```bash
   nslookup lens.137.131.36.226.oci-incubations.com
   curl -I https://lens.137.131.36.226.oci-incubations.com
   ```

**Note:** TLS certificates from Let's Encrypt may take 2-5 minutes to be issued after DNS records are properly configured.

### Option 3: Using Existing cert-manager and Ingress Controller

If your cluster already has cert-manager and an ingress controller installed, you can configure the Helm chart to use these existing components instead of installing new ones.

**Prerequisites - verify your existing components:**
```bash
# Check existing cert-manager installation
kubectl get pods -n <cert-manager-namespace> | grep cert-manager
kubectl get clusterissuer

# Check existing ingress controller
kubectl get ingressclass
kubectl get svc -n <ingress-namespace> | grep ingress-nginx-controller
```

**Required information:**
- **ClusterIssuer name** (e.g., `letsencrypt-prod`)
- **IngressClass name** (e.g., `nginx`)
- **Ingress controller namespace** (e.g., `cluster-tools`)
- **Ingress controller service name** (typically `ingress-nginx-controller`)

**Installation:**
```bash
helm install lens . -n lens --create-namespace \
  --set cert-manager.enabled=false \
  --set ingress.certManager.clusterIssuer="your-clusterIssuer" \
  --set ingress-nginx.enabled=false \
  --set ingress.className="your-nginx-className" \
  --set ingress.external.namespace="your-namespace" \
  --set ingress.external.serviceName="your-ingress-serviceName"
```

---

## Post-Install Verification

After helm installation, verify all components are running:

```bash
# 1. Verify namespace and pods
kubectl get namespace lens
kubectl get pods -n lens

# 2. Check ingress-nginx and cert-manager
# For default installation:
kubectl get pods -n lens | grep -E 'ingress|cert-manager'
# For existing components, verify no duplicates in lens namespace:
kubectl get pods -n lens | grep -E 'cert-manager|ingress-nginx' || echo "✅ Using external components"

# 3. Get LoadBalancer external IP
# For default installation (ingress-nginx in lens namespace):
kubectl get svc -n lens -l app.kubernetes.io/component=controller
# For existing ingress controller:
kubectl get svc -n <ingress-namespace> -l app.kubernetes.io/component=controller

# 4. Check cluster-wide resources
# For default installation:
kubectl get ingressclass lens-nginx
kubectl get clusterissuer letsencrypt-prod
# For existing components:
kubectl get ingressclass <your-ingress-class>
kubectl get clusterissuer <your-cluster-issuer>

# 5. View all ingress endpoints
kubectl get ingress -n lens

# 6. Check TLS certificates (should show READY=True after 2-5 minutes)
kubectl get certificate -n lens
```

**Expected output (default installation):**
- All pods in `Running` state
- LoadBalancer service has an `EXTERNAL-IP`
- Certificates show `READY=True`
- Ingress resources show correct hosts

**Expected output (using existing components):**
- Application pods in `Running` state
- No ingress-nginx or cert-manager pods in `lens` namespace
- Certificates show `READY=True` (managed by existing cert-manager)
- Ingress resources show correct hosts and IngressClass

---

## Troubleshooting

### Certificates Not Getting Issued

```bash
# Check certificate status and challenges
kubectl describe certificate -n lens
kubectl get challenge -n lens

# Check cert-manager logs
# For default installation:
kubectl logs -n lens -l app=cert-manager --tail=50
# For existing cert-manager:
kubectl logs -n <cert-manager-namespace> -l app=cert-manager --tail=50

# Check if ClusterIssuer exists and is ready
kubectl get clusterissuer <your-cluster-issuer>
```

**Common causes:**
- DNS not pointing to LoadBalancer IP
- Firewall blocking port 80/443 from internet
- Let's Encrypt rate limits exceeded

### Ingress Not Routing Traffic

```bash
# Verify ingress controller is running
# For default installation:
kubectl get pods -n lens | grep ingress-nginx
# For existing ingress controller:
kubectl get pods -n <ingress-namespace> | grep ingress-nginx

# Check ingress controller logs
kubectl logs -n <ingress-namespace> -l app.kubernetes.io/component=controller --tail=50

# Verify IngressClass matches
kubectl get ingressclass <ingress-class-name>
kubectl get ingress -n lens -o jsonpath='{.items[*].spec.ingressClassName}'
```

### IngressClass or ClusterIssuer Already Exists

```bash
# Check if from previous lens installation
kubectl get ingressclass lens-nginx -o yaml | grep app.kubernetes.io/instance
kubectl get clusterissuer letsencrypt-prod -o yaml | grep app.kubernetes.io/instance

# Delete if from previous lens install
kubectl delete ingressclass lens-nginx --ignore-not-found
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found
```

### Namespace Stuck in "Terminating"

```bash
# Check what's blocking deletion
kubectl get all -n lens
kubectl get certificate -n lens

# Force remove finalizers (use with caution)
kubectl get namespace lens -o json | jq '.spec.finalizers = []' | kubectl replace --raw /api/v1/namespaces/lens/finalize -f -
```

### Check if Other Apps Use Resources

```bash
# List all ingress and certificates across cluster
kubectl get ingress --all-namespaces
kubectl get certificate --all-namespaces

# If only lens namespace appears, safe to delete cluster-wide resources
```

---

## Uninstall

### Standard Uninstall (Preserves Cluster-Wide Resources)

Removes only the `lens` namespace, preserving cluster-wide resources:

```bash
# Uninstall Helm release
helm uninstall lens -n lens

# Delete namespace (removes all namespace-scoped resources)
kubectl delete namespace lens

# Wait for deletion to complete
kubectl wait --for=delete namespace/lens --timeout=120s 2>/dev/null || echo "Namespace deleted"
```

**Verification:**
```bash
kubectl get namespace lens 2>&1 | grep "NotFound" && echo "✅ Ready for install" || echo "❌ Namespace still exists"
```

### Full Uninstall (Removes Everything)

⚠️ **Only use on dedicated test clusters or if no other applications use cert-manager or ingress-nginx**

```bash
# 1. Uninstall Helm release and namespace
helm uninstall lens -n lens
kubectl delete namespace lens
kubectl wait --for=delete namespace/lens --timeout=120s 2>/dev/null

# 2. Verify no other apps are using these resources
kubectl get certificate --all-namespaces
kubectl get ingress --all-namespaces

# 3. Delete cluster-wide resources (if safe)
kubectl delete clusterissuer letsencrypt-prod --ignore-not-found
kubectl delete ingressclass lens-nginx --ignore-not-found

# 4. Delete cert-manager CRDs (affects entire cluster!)
kubectl get crd | grep cert-manager | awk '{print $1}' | xargs kubectl delete crd --ignore-not-found

# 5. Delete webhook configurations
kubectl delete validatingwebhookconfiguration -l app.kubernetes.io/instance=lens --ignore-not-found
kubectl delete mutatingwebhookconfiguration -l app.kubernetes.io/instance=lens --ignore-not-found
```

**Verification:**
```bash
kubectl get namespace lens 2>&1 | grep "NotFound"
kubectl get ingressclass lens-nginx 2>&1 | grep "NotFound"
kubectl get crd | grep cert-manager || echo "No cert-manager CRDs"
kubectl get all -n lens 2>&1 | grep "NotFound" && echo "✅ Complete uninstall successful"
```

---

## Additional Resources

- **ingress-nginx**: https://kubernetes.github.io/ingress-nginx/
- **cert-manager**: https://cert-manager.io/docs/
- **Let's Encrypt**: https://letsencrypt.org/docs/
- **Report Issues**: https://github.com/oci-ai-incubations/corrino-lens-devops
