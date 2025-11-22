# v0.1.10
## Release Date
Oct 31, 2025

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | N/A      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:latest                                                                                                                                                             |
| Portal        | N/A      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:latest                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:rocm-latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:latest<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:latest |
| Helm          | v 0.1.10 | [lens-0.1.10-20251031-2247.tgz](https://github.com/oci-ai-incubations/corrino-lens-devops/blob/main/docs/lens-0.1.10-20251031-2247.tgz "lens-0.1.10-20251031-2247.tgz")                                                                                                 |
| Quickstart    | v 0.1.10 | [v0.1.10](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.10/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Portal
- Add autoremediation functionality to UpdateMonitoringRing component ([corrino-lens-portal #30](https://github.com/oci-ai-incubations/corrino-lens-portal/pull/30), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Plugin
- Push pod metadata to Prometheus ([oci-lens #88](https://github.com/oci-ai-incubations/oci-lens/pull/88), [@gablyu-oci](https://github.com/gablyu-oci))
- Adding support to scrape and push networking data ([oci-lens #90](https://github.com/oci-ai-incubations/oci-lens/pull/90/files), [@rtkgupta](https://github.com/rtkgupta))

#### Helm
- Introduced a new section for rebootGPUErrorTag with options to enable the feature, specify the image, and set the namespace for the reboot condition checker ([ecc9567](https://github.com/oci-ai-incubations/corrino-lens-devops/commit/ecc95675644276afa382eba7fbddb59ba749c50f), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Terminate GPU based on label ([corrino-lens-devops #15](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/15), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Updated CI/CD pipeline to use GitHub Pages and ArtifactHub ([#21](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/21), [@gablyu-oci](https://github.com/gablyu-oci))

#### Quickstart
- Unifying helm to work on AMD and NVIDIA GPUs for monitoring ([oci-gpu-scanner #31](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/31), [@rtkgupta](https://github.com/rtkgupta))
----
### Bugfix
#### Helm
- Leverage the values.yaml variables and remove hardcoded nip.io from jobs ([corrino-lens-devops #16](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/16), [@rtkgupta](https://github.com/rtkgupta))

----
### Others

#### Helm
- Getting rid of stale devops code, moved to new GitHub Actions and Helm pipeline ([corrino-lens-devops #22](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/22), [@rtkgupta](https://github.com/rtkgupta))
