# v0.1.11
## Release Date
Nov 21, 2025

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | N/A      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:latest                                                                                                                                                             |
| Portal        | N/A      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:latest                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:latest |
| Helm          | v 0.1.11 | [lens-0.1.11-20251031-2247.tgz](https://github.com/oci-ai-incubations/corrino-lens-devops/blob/main/docs/lens-0.1.10-20251031-2247.tgz "lens-0.1.11-20251031-2247.tgz")                                                                                                 |
| Quickstart    | v 0.1.11 | [v0.1.11](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.10/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Portal
- Topology UI ([corrino-lens-portal #35](https://github.com/oci-ai-incubations/corrino-lens-portal/pull/35/), [@gablyu-oci](https://github.com/gablyu-oci))

#### Plugin
- Active health check for Mi300x ([oci-lens #15](https://github.com/oci-ai-incubations/oci-gpu-health-checks/pull/15), [@ssraghavan-oci](https://github.com/ssraghavan-oci))

#### Helm
- Support for using existing cert-manager installation ([#29](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/29), [@gablyu-oci](https://github.com/gablyu-oci))

#### Quickstart
- Adding NPD changes and health check ([oci-gpu-scanner #57](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/57), [@rtkgupta](https://github.com/rtkgupta))
