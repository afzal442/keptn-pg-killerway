In this step, a second quality evaluation step will be added to validate the health of production **after** deployment.

In a perfect world, a service would act identically in preproduction as production. In reality though, services can and will act differently in production for many different reasons.

Including an automated post-deployment quality evaluation provides an extra security check.

If this evaluation fails, it can be used as the trigger (or at least a strong indication) to rollback (or otherwise fix) the deployment.

## Add and Run a Post Production Release Validation Quality Evaluation

```
~/release_validation.sh
```{{exec}}


In this demo, the same SLI and SLO definitions  will be used for `qa` and `production`. In reality however, most likely different objectives would be used in production.

## Validate Production Version and Quality

Wait until the sequence has completed then check the application version running in each environment:

```
kubectl -n fulltour-qa describe pod -l app=helloservice | grep Image:
kubectl -n fulltour-production describe pod -l app=helloservice | grep Image:
```{{exec}}

Should show `v0.1.1` in both environments.

Navigate to the bridge, select the latest sequence and choose `production`. notice the quality evaluation in production has provided a `pass` signal.

## What Next?

As mentioned, problems will always occur in production, so let's equip Keptn to deal with issues.

Self-healing capabilities will be introduced using a provider (eg. helm) and an action (eg. scaling up pods) in response to a problem report.
