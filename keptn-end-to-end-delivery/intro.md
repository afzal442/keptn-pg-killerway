# Goal
The goal of this tutorial is to:

- Deploy a microservice (using [helm](https://helm.sh))
- Generate load on the deployed service (using [locust](https://locust.io))

Keptn is unopinionated about tooling. A key strength of Keptn is it allows you to bring the tooling you already use and with which you are familiar.

That said, we needed to pick some tools and Helm + Locust are two modern and widely used tools.

The tutorial will progress in steps:

1. Automated testing and releases into `qa` and `production` stages
2. An approval step will be added to ensure a human must always click “go” before a production release
3. Add Prometheus to the cluster to monitor the workloads. Add SLO-based quality evaluations to ensure no bad build ever makes it to production.
4. Add a quality evaluation in production, post rollout. If a bad deployment occurs, the evaluation will fail and remediation actions (scaling) will be actioned (using `helm` to `helm upgrade` the application).


## Relax

While you have been reading, we have been busy installing everything. It is still happening but it should only take a few minutes.

Please wait here until you see the text `Installation Completed 🎉. Please proceed now.` in the console.

![keptn-cloud-native](./assets/overview_image.drawio.png)
