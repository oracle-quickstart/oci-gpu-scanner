# v0.1.14
## Release Date
December 20, 2025

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.3      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.3                                                                                                                                                             |
| Portal        | v0.0.4      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.4                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.14 | [lens-0.1.14-20251219-1606.tgz](https://github.com/oci-ai-incubations/corrino-lens-devops/blob/main/docs/lens-0.1.14-20251219-1606.tgz)                                                                                                 |
| Quickstart    | v 0.1.14 | [v0.1.14](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.14/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Quickstart
- Resource Manager supports custom Grafana, Ingress and compartment level IAM ([oci-gpu-scanner #64](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/64), [@gablyu-oci](https://github.com/gablyu-oci))

#### Helm
- Security update: Grafana to use kubernetes secrets - ([Update to use grafana password as k8s secret](https://github.com/oci-ai-incubations/corrino-lens-devops/commit/c2edc8cce2f8f237d237a251003af64a96420dcf), ([@rtkgupta](https://github.com/rtkgupta))
- Update CP to be able run k8s jobs ([corrino-lens-devops](https://github.com/oci-ai-incubations/corrino-lens-devops/commit/c2edc8cce2f8f237d237a251003af64a96420dcf), [@rtkgupta](https://github.com/rtkgupta))
- Add auto active health check knobs to helm ([corrino-lens-devops](https://github.com/oci-ai-incubations/corrino-lens-devops/commit/a665745fde3986df8cc029b818d5012984cae004), [@rtkgupta](https://github.com/rtkgupta))

#### Portal
- Updated plugin install instructions ([corrino-lens-portal #36](https://github.com/oci-ai-incubations/corrino-lens-portal/pull/36), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Backend
- Automated health check scheduling ([corrino-lens-cp #59](https://github.com/oci-ai-incubations/corrino-lens-cp/commit/dc99bfc93c05fb91d33dd9b50e20b3b64960b7eb), [@rtkgupta](https://github.com/rtkgupta))
- Support compartment level IAM for list instances, OKE clusters and Cluster Networks ([corrino-lens-cp #60](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/60), [@gablyu-oci](https://github.com/gablyu-oci))

### Bugfix
#### Portal
- Update log and report for first run ([oci-lens-portal #37](https://github.com/oci-ai-incubations/corrino-lens-portal/pull/37), [@rtkgupta](https://github.com/rtkgupta))

