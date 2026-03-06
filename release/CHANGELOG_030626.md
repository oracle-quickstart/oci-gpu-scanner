# v0.1.21
## Release Date
March 06, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.9      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.9                                                                                                                                                             |
| Portal        | v0.0.5      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.5                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-1.0.78<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.3<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.12 |
| App          | v 0.1.21 | N/A                                                                                                |
| Quickstart    | v 0.1.21 | N/A                                                                                                                                                    |

----
## Changelog
### Feature
#### Backend
- Revert OCI IAM login for backend ([corrino-lens-cp #66](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/66) , [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Quickstart
- 24hr Time to live for oci gpu scanner jobs ([oci-gpu-scanner #d75673e](https://github.com/oracle-quickstart/oci-gpu-scanner/commit/d75673ed778c259d690de0ebaf1ca10a08388b1d), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Revert OCI IAM integration for helm install ([oci-gpu-scanner #92](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/92), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Updated base image to use Oracle Linux 9 Slim ([oci-gpu-scanner #91](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/91), [@gablyu-oci](https://github.com/gablyu-oci))


### Bugfix
#### Backend
- Resolve node_name server-side at instance creation using K8s Provider ID (OCID) matching with IP fallback [corrino-lens-cp #67](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/67), [@gablyu-oci](https://github.com/gablyu-oci)

### Other
#### Quickstart
- Updated documentation to have only compartment level policies ([oci-gpu-scanner #36fcdf9](https://github.com/oracle-quickstart/oci-gpu-scanner/commit/36fcdf96ebe4406fff13636e735d06122b8ca230), [@gablyu-oci](https://github.com/gablyu-oci))  
- Updated base image for terminate node ([oci-gpu-scanner #467ecd7](https://github.com/oracle-quickstart/oci-gpu-scanner/commit/467ecd75425e9f3c7c672cbb666f7fbb39ad4021), [@gablyu-oci](https://github.com/gablyu-oci))  
