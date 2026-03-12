#!/bin/bash

# Script to help set up IAM policy for OCI GPU Scanner backend workload identity
# This script provides the policy statements that need to be created in OCI Console.
# See GETTING_STARTED_HELM_DEPLOY.md for full prerequisites.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}OCI GPU Scanner - Workload Identity Setup${NC}"
echo "=========================================="
echo ""

# Check if values.yaml exists (optional - we can use env vars or placeholders)
CLUSTER_ID=""
COMPARTMENT_OCID=""
if [ -f "values.yaml" ]; then
    # Extract OKE cluster OCID from values.yaml if present (e.g. okeClusterId or workloadIdentity.okeClusterId)
    CLUSTER_ID=$(grep "okeClusterId:" values.yaml | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/; s/.*: *\([^ ]]*\).*/\1/')
    # Optional: use first authorized compartment if set
    COMPARTMENT_OCID=$(grep "authorizedCompartments:" values.yaml | sed 's/.*: *"\([^"]*\)".*/\1/; s/.*: *\([^ ]]*\).*/\1/' | head -1)
fi

# Allow environment overrides
[ -n "$OKE_CLUSTER_OCID" ] && CLUSTER_ID="$OKE_CLUSTER_OCID"
[ -n "$OCI_COMPARTMENT_OCID" ] && COMPARTMENT_OCID="$OCI_COMPARTMENT_OCID"

# Use placeholders if not set
[ -z "$CLUSTER_ID" ] && CLUSTER_ID="YOUR_OKE_CLUSTER_OCID"
[ -z "$COMPARTMENT_OCID" ] && COMPARTMENT_OCID="YOUR_COMPARTMENT_OCID"

NAMESPACE="lens"
SERVICE_ACCOUNT="corrino-lens-backend-sa"

# Validate cluster ID if not placeholder
if [ "$CLUSTER_ID" = "YOUR_OKE_CLUSTER_OCID" ]; then
    echo -e "${YELLOW}Note: Replace YOUR_OKE_CLUSTER_OCID with your OKE cluster OCID (e.g. ocid1.cluster.oc1.iad.aaaaaaaaa...)${NC}"
    echo ""
else
    if [[ ! "$CLUSTER_ID" =~ ^ocid1\.cluster\. ]]; then
        echo -e "${YELLOW}Warning: Cluster ID doesn't look like a valid OCID format${NC}"
        echo "Extracted value: $CLUSTER_ID"
    fi
fi

if [ "$COMPARTMENT_OCID" = "YOUR_COMPARTMENT_OCID" ]; then
    echo -e "${YELLOW}Note: Replace YOUR_COMPARTMENT_OCID with the compartment OCID where your OKE cluster resides (or root compartment).${NC}"
    echo ""
fi

echo -e "${YELLOW}Required Information:${NC}"
echo "  request.principal.cluster_id:  $CLUSTER_ID"
echo "  request.principal.namespace:   $NAMESPACE"
echo "  request.principal.service_account: $SERVICE_ACCOUNT"
echo "  compartment id:                $COMPARTMENT_OCID"
echo ""

echo -e "${YELLOW}Create Policy in OCI Console:${NC}"
echo "  1. Navigate to Identity & Security > Policies"
echo "  2. Click Create Policy"
echo "  3. Name: oci-gpu-scanner-backend-access"
echo "  4. Description: Enable OCI GPU Scanner backend workload identity access"
echo "  5. Compartment: Root compartment (or compartment where OKE cluster resides)"
echo "  6. Policy Builder: Switch to Manual Editor"
echo ""

echo -e "${YELLOW}Add the following policy statements:${NC}"
echo "================================================"
echo ""
echo -e "${GREEN}Allow any-user to read instance-family in compartment id '$COMPARTMENT_OCID' where all {${NC}"
echo -e "${GREEN}  request.principal.type = 'workload',${NC}"
echo -e "${GREEN}  request.principal.namespace = '$NAMESPACE',${NC}"
echo -e "${GREEN}  request.principal.service_account = '$SERVICE_ACCOUNT',${NC}"
echo -e "${GREEN}  request.principal.cluster_id = '$CLUSTER_ID'${NC}"
echo -e "${GREEN}}${NC}"
echo ""
echo -e "${GREEN}Allow any-user to read compute-management-family in compartment id '$COMPARTMENT_OCID' where all {${NC}"
echo -e "${GREEN}  request.principal.type = 'workload',${NC}"
echo -e "${GREEN}  request.principal.namespace = '$NAMESPACE',${NC}"
echo -e "${GREEN}  request.principal.service_account = '$SERVICE_ACCOUNT',${NC}"
echo -e "${GREEN}  request.principal.cluster_id = '$CLUSTER_ID'${NC}"
echo -e "${GREEN}}${NC}"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Replace YOUR_OKE_CLUSTER_OCID and YOUR_COMPARTMENT_OCID with your actual values (if not already set)."
echo "2. Create the IAM policy in OCI Console using the statements above."
echo "3. Create Kubernetes secrets and deploy: see GETTING_STARTED_HELM_DEPLOY.md"
echo "   helm install lens . -n lens --create-namespace \\"
echo "     --set global.tenancyId=\"YOUR_OCI_TENANCY_OCID\" \\"
echo "     --set global.regionName=\"YOUR_OKE_REGION\""
echo ""
echo -e "${GREEN}Reference:${NC}"
echo "https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm"
