# v0.1.10
## Release Date
Oct 31, 2025

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.1      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.1                                                                                                                                                             |
| Portal        | v0.0.2      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.2                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:latest |
| Helm          | v 0.1.12 | [lens-0.1.12-20251205-2232.tgz](https://oci-ai-incubations.github.io/corrino-lens-devops/lens-0.1.12-20251205-2232.tgz)                                                                                                 |
| Quickstart    | v 0.1.12 | [v0.1.12](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.12/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Bugfix
#### Quickstart
- Fixed Prometheus and Grafana for AMD metrics ([corrino-lens-devops #16](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/61), [@gablyu-oci](https://github.com/gablyu-oci))

#### DRHPC
- Resolved false negative on PCIE Width Missing Lanes Check ([@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Backend
- Convert region shorthand to regional codes ([@jolettacheungoracle](https://github.com/jolettacheungoracle))

----
### Others

#### Quickstart
- Updated default values in `Values.yaml` for oci-gpu-scanner-plugin to enable nodeProblemDetector, healthCheck and nodeExporter by default ([corrino-lens-devops #16](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/61), [@gablyu-oci](https://github.com/gablyu-oci))


