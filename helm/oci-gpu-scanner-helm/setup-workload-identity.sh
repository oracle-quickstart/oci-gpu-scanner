#!/bin/bash

# Script to help set up IAM policy for Corrino Lens workload identity
# This script provides the policy statement that needs to be created in OCI Console

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Corrino Lens Workload Identity Setup${NC}"
echo "=========================================="
echo ""

# Check if values.yaml exists
if [ ! -f "values.yaml" ]; then
    echo -e "${RED}Error: values.yaml not found. Please run this script from the helm directory.${NC}"
    exit 1
fi

# Extract values from values.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD sed)
    CLUSTER_ID=$(grep "okeClusterId:" values.yaml | sed 's/.*okeClusterId: *"\([^"]*\)".*/\1/')
else
    # Linux (GNU sed)
    CLUSTER_ID=$(grep "okeClusterId:" values.yaml | sed 's/.*okeClusterId: *"\([^"]*\)".*/\1/')
fi
NAMESPACE="lens"  # Default namespace
SERVICE_ACCOUNT="corrino-lens-backend-sa"

# Validate extracted values
if [ -z "$CLUSTER_ID" ] || [ "$CLUSTER_ID" = "okeClusterId:" ]; then
    echo -e "${RED}Error: Failed to extract cluster ID from values.yaml${NC}"
    echo "Please check that okeClusterId is properly set in values.yaml"
    exit 1
fi

# Check if cluster ID looks like a valid OCID
if [[ ! "$CLUSTER_ID" =~ ^ocid1\.cluster\. ]]; then
    echo -e "${YELLOW}Warning: Cluster ID doesn't look like a valid OCID format${NC}"
    echo "Extracted value: $CLUSTER_ID"
fi

echo -e "${YELLOW}Required Information:${NC}"
echo "Cluster OCID: $CLUSTER_ID"
echo "Namespace: $NAMESPACE"
echo "Service Account: $SERVICE_ACCOUNT"
echo ""

echo -e "${YELLOW}IAM Policy Statement for OCI Console:${NC}"
echo "================================================"
echo ""
echo "Navigate to OCI Console > Identity & Security > Policies"
echo "Create a new policy with the following statement:"
echo ""
echo -e "${GREEN}Allow any-user to manage objects in tenancy where all {${NC}"
echo -e "${GREEN}  request.principal.type = 'workload',${NC}"
echo -e "${GREEN}  request.principal.namespace = '$NAMESPACE',${NC}"
echo -e "${GREEN}  request.principal.service_account = '$SERVICE_ACCOUNT',${NC}"
echo -e "${GREEN}  request.principal.cluster_id = '$CLUSTER_ID'${NC}"
echo -e "${GREEN}}${NC}"
echo ""

echo -e "${YELLOW}For specific compartment access, use:${NC}"
echo "================================================"
echo ""
echo -e "${GREEN}Allow any-user to manage objects in compartment <compartment-id> where all {${NC}"
echo -e "${GREEN}  request.principal.type = 'workload',${NC}"
echo -e "${GREEN}  request.principal.namespace = '$NAMESPACE',${NC}"
echo -e "${GREEN}  request.principal.service_account = '$SERVICE_ACCOUNT',${NC}"
echo -e "${GREEN}  request.principal.cluster_id = '$CLUSTER_ID'${NC}"
echo -e "${GREEN}}${NC}"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Create the IAM policy in OCI Console using the statement above"
echo "2. Deploy the Helm chart: helm install lens ./helm -n lens"
echo "3. The backend will automatically use workload identity for OCI authentication"
echo ""
echo -e "${GREEN}For more information, see:${NC}"
echo "https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm" 