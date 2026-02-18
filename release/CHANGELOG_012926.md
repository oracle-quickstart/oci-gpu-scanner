# v0.1.17
## Release Date
January 29, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.6      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.6                                                                                                                                                             |
| Portal        | v0.0.4      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.4                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-1.0.52.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.17 | [lens-0.1.17-20260129-1637.tgz](https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/lens_charts/lens-0.1.17-20260129-1637.tgz)                                                                                                 |
| Quickstart    | v 0.1.17 | [v0.1.17](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.17/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Quickstart
- Updated DRHPC and parse script to version to 1.0.52.1 ([oci-gpu-scanner Commit 9a2c046](https://github.com/oracle-quickstart/oci-gpu-scanner/commit/9a2c046573f676050f33209a8f696382f56de375), [@gablyu-oci](https://github.com/gablyu-oci))

### Bugfix
#### Quickstart
- Fixed Grafana metrics thresholds ([oci-gpu-scanner #79](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/79), [@gablyu-oci](https://github.com/gablyu-oci))