# v0.1.20
## Release Date
February 27, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.8      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.8                                                                                                                                                             |
| Portal        | v0.0.5      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.5                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-1.0.52.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| App          | v 0.1.20 | N/A                                                                                                |
| Quickstart    | v 0.1.20 | N/A                                                                                                                                                    |

----
## Changelog
### Breaking Changes
1. ** App helm that originally leaves in `corrino-lens-devops` repo has been migrated to this repo in `helm/oci-gpu-scanner`, and original `oci-scanner-plugin-helm` has been migrated to `helm/oci-gpu-scanner-plugin-helm`. For future installations and upgrades, no more `.tgz` or `.zip` files of helm will be created.  **
- Added app helm to repo and improved documentation #88 ([oci-gpu-scanner #88](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/88), [@gablyu-oci](https://github.com/gablyu-oci))

2. ** Auto-remediation, termination and reboot features from frontend have been temporarily removed for security purpose. **  
- Removed auto-remediation, reboot and terminate #38 ([corrino-lens-portal #38](https://github.com/oci-ai-incubations/corrino-lens-portal/pull/38/), [@gablyu-oci](https://github.com/gablyu-oci))

### Feature
#### Backend
- OCI IAM login for backend ([corrino-lens-cp #61](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/61) , [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Quickstart

### Other
#### Devops
- Improve helm values and hooks #69 ([corrino-lens-devops #69](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/69), [@gablyu-oci](https://github.com/gablyu-oci))