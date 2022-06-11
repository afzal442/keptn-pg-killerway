# View Keptns Bridge

The Keptns bridge is the web-based interface for Keptn.

Retrieve the username for the Keptn's bridge (defaults to `keptn`):

```
kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_USERNAME}" | base64 --decode ; echo
```{{exec}}

Retrieve the password for the Keptn's bridge (randomly generated during installation):

```
kubectl get secret -n keptn bridge-credentials -o jsonpath="{.data.BASIC_AUTH_PASSWORD}" | base64 --decode ; echo
```{{exec}}

Visit [the Bridge]({{TRAFFIC_HOST1_8080}}/bridge) (opens in a new tab). Login and come back here.

The Bridge and API are available at any time from the Killercoda interface:

1. Navigate to the menu icon (three lines on the top right)
2. Select `Traffic / Ports`
3. Click Port `8080` to access the bridge
4. A link to the API is found under the "little person" icon (top right)
