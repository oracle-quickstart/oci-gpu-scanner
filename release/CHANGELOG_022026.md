# v0.1.19
## Release Date
February 20, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.7      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.7                                                                                                                                                             |
| Portal        | v0.0.4      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.4                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-1.0.52.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.19 | [lens-0.1.19-20260221-0039.tgz](https://github.com/oracle-quickstart/oci-gpu-scanner/blob/main/lens_charts/lens-0.1.19-20260221-0039.tgz)                                                                                                |
| Quickstart    | v 0.1.19 | [v0.1.19](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.19/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Quickstart
- Remove Active Health Check run upon initial oci-gpu-scanner-plugin install ([oci-gpu-scanner #85](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/85), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Backend
- Added node name to instance and fallback for passive healthcheck query ([corrino-lens-cp #64](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/64), [@gablyu-oci](https://github.com/gablyu-oci))
- Update gpu utilisation check ([corrino-lens-cp #ccfbd3a](https://github.com/oci-ai-incubations/corrino-lens-cp/commit/ccfbd3a7dbdad9c2d76830bc776cdd8b4f1c2657), [@rtkgupta](https://github.com/rtkgupta))
