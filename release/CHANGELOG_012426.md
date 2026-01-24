# v0.1.16
## Release Date
January 24, 2026

## Dependency Versions

| Module       | Version  | Resource                                                                                                                                                                                                                                                              |
| ------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Control Plane | v0.0.6      | iad.ocir.io/iduyx1qnmway/corrino-lens-backend:v0.0.6                                                                                                                                                             |
| Portal        | v0.0.4      | iad.ocir.io/iduyx1qnmway/corrino-lens-portal:v0.0.4                                                                                                                                                             |
| Plugin        | N/A      | iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:cuda-latest<br>iduyx1qnmway/lens-metric-collector/oci-dr-hpc-v2:v1.0.50<br>iduyx1qnmway/lens-metric-collector/oci_lens_pod_node_info:v0.0.1<br>iduyx1qnmway/lens-metric-collector/oci_lens_metric_collector:v0.0.11 |
| Helm          | v 0.1.16 | [lens-0.1.16-20260124-0622.tgz](https://oci-ai-incubations.github.io/corrino-lens-devops/lens-0.1.16-20260124-0622.tgz)                                                                                                 |
| Quickstart    | v 0.1.16 | [v0.1.16](https://github.com/oracle-quickstart/oci-gpu-scanner/releases/download/v0.1.16/oci-gpu-scanner-deploy.zip)                                                                                                                                                    |

----
## Changelog
### Feature
#### Backend
- Cluster Network resource pool creation  ([corrino-lens-cp #61](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/61) , [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- 'Prometheus' name filter when selecting prometheus datasource for Grafana templates. To avoid using default prometheus often used for production ([corrino-lens-cp #62](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/62) , [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Making 'Prometheus' name and type case insensitive ([corrino-lens-cp #63](https://github.com/oci-ai-incubations/corrino-lens-cp/pull/63) , [@jolettacheungoracle](https://github.com/jolettacheungoracle))

#### Helm
- Convert Postgres, Backend and Grafana API Token to k8s secrets ([corrino-lens-devops #66](https://github.com/oci-ai-incubations/corrino-lens-devops/pull/66), [@gablyu-oci](https://github.com/gablyu-oci))

#### Quickstart
- Add Prometheus datasource configuration to Grafana dashboards in the variables/filters ([oci-gpu-scanner #73](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/73), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Add Prometheus datasource configuration to Grafana dashboards for K8s namespace variable/filter ([oci-gpu-scanner #74](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/74), [@jolettacheungoracle](https://github.com/jolettacheungoracle))
- Add new template using node name mapping ([oci-gpu-scanner #75](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/75), [@jolettacheungoracle](https://github.com/jolettacheungoracle))

### Bugfix
#### Quickstart
- Updated Active Healthcheck time to check completed time on Grafana Dashboard ([oci-gpu-scanner #71](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/71), [@gablyu-oci](https://github.com/gablyu-oci))
- Fix(pod-node-mapper): correct liveness/readiness probes to check main process ([oci-gpu-scanner #72](https://github.com/oracle-quickstart/oci-gpu-scanner/pull/72), [@gablyu-oci](https://github.com/gablyu-oci))