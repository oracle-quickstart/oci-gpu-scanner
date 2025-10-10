# Installing OKE Node Problem Detector (NPD) DaemonSet with OCI GPU Scanner Service

OKE NPD is an extension of https://github.com/kubernetes/node-problem-detector that processes GPU health check failures reported by GPU Scanner service and sets conditions on the affected nodes. This feature enables proactive monitoring of GPU node health and early detection of issues. 

## Install

These actions should only be performed after a successful OCI GPU scanner service installation of control plane and data plane (plugin) components on individual GPU nodes. 

❗❗**IMPORTANT**: NPD will only start processing GPU health check events when OCI GPU Scanner Service data plane plugin is actively running.

Label the target GPU nodes so they can host the NPD DaemonSet. 
  
Only run this command on the GPU nodes that you would like to run the NPD feature on.

```bash
kubectl label node <nodeIP e.g 10.0.65.72> oci.oraclecloud.com/oke-node-problem-detector-enabled="true"
```

Install the NPD DaemonSet.

```bash
kubectl apply -f https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/existing_cluster_deploy/oke-node-problem-detector.yaml
```

Verify that NPD DaemonSet has been installed successfully and running.

```bash
kubectl get pods -l app=oke-node-problem-detector -o wide -n kube-system
```

Results should show ```oke-node-problem-detector``` in running state for all targeted GPU nodes.

## Uninstall

To remove the NPD from an OKE cluster, run the below command

```bash
kubectl delete -f https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/existing_cluster_deploy/oke-node-problem-detector.yaml
```