# Deploying OKE Node Problem Detector( NPD) with OCI GPU Scanner Service

OKE NPD is an extension of https://github.com/kubernetes/node-problem-detector that looks for GPU health check failures created by GPU Scanner service and tags/creates conditions on the failed node. This feature will allow you to only schedule GPU workloads on a healthy node and avoid  running into application deployment issues. 

## Deployment

These actions should only be performed after successful OCI GPU scanner service installation of control plane and data plane (plugin) components on individual GPU nodes. 

❗❗**IMPORTANT**: Only deploy the NPD on the OKE cluster that has GPU compute resources added as node pools. NPD will only start processing health check events when OCI GPU Scanner Service data plane plugin is actively running. Both are tightly integrated

```bash
kubectl apply -f https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/existing_cluster_deploy/oke-node-problem-detector.yaml
```
Verify that NPD has been installed successfully and running.

```bash
kubectl get pods -n kube-system
```
Results should show ```oke-node-problem-detector``` in running state. 

## Activation per node 

This step is required to state the NPD to run on these GPU node. Only run this command on the GPU nodes that you would like to run the NPD feature on.

```bash
kubectl label node <nodeIP e.g 10.0.65.72> oci.oraclecloud.com/oke-node-problem-detector-enabled="true
```
This step will activate the NPD on each of these nodes.

## Uninstall

To remove teh NPD for an OKE cluster run the below command

```bash
kubectl delete -f https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/existing_cluster_deploy/oke-node-problem-detector.yaml
```