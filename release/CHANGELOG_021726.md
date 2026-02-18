# v0.1.18
## Release Date
February 17, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.6      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.6                                                                                                                                                             |
| Portal        | v0.0.4      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.4                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-1.0.52.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.18 | [lens-0.1.18-20260217-1755.tgz](https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/lens_charts/lens-0.1.18-20260217-1755.tgz)                                                                                                 |
| Quickstart    | v 0.1.18 | [v0.1.18](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.18/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Quickstart
- Reduce Pushgateway usage to for scalability ([oci-gpu-scanner #81](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/81), [@gablyu-oci](https://github.com/gablyu-oci))

#### Helm
- Custom prometheus and pushgateway ([corrino-lens-devops #68](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/68), [@gablyu-oci](https://github.com/gablyu-oci))
