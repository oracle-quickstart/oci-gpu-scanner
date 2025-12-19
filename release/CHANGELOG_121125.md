# v0.1.13
## Release Date
December 11, 2025

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.2      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.2                                                                                                                                                             |
| Portal        | v0.0.3      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.3                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.13 | [lens-0.1.13-20251211-1840.tgz](https://github.com/oci-ai-incubations/corrino-lens-devops/blob/main/docs/lens-0.1.13-20251211-1840.tgz)                                                                                                 |
| Quickstart    | v 0.1.13 | [v0.1.13](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.13/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Helm
- Autoremediation ([corrino-lens-devops commit#12e1fd6](https://github.com/oci-ai-incubations/corrino-lens-devops/commit/12e1fd6d5de965f9d3f38beeda0fe66d543ff368), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Helm chart updated to enable custom Grafana, cert-manager, Ingress ([corrino-lens-devops #54](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/54), [@gablyu-oci](https://github.com/gablyu-oci))

#### Portal
- Address security vulnerabilities ([corrino-lens-portal commit#629c424](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/50](https://github.com/oci-ai-incubations/corrino-lens-portal/commit/629c424eea92a4dbd1d5e66eb2eec9dde54c87ca)), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Backend
- Active health check trigger via CP ([corrino-lens-cp #50](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/50), [@rtkgupta](https://github.com/rtkgupta))
- Simplify logic to use host ip from Instance model ([corrino-lens-cp #55](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/55), [@rtkgupta](https://github.com/rtkgupta))
- Enhance host_ip handling and logging across API routes and components ([corrino-lens-portal Commit#731bddf](https://github.com/oci-ai-incubations/corrino-lens-portal/commit/731bddf7bd384b592aa3aa98e76abcef02d2a25d), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

### Bugfix
#### Plugins
- Node exporter: serial number not showing in oci_lens_host_metadata ([oci-lens #96](https://github.com/oci-ai-incubations/oci-lens/pull/96), [@gablyu-oci](https://github.com/gablyu-oci))



