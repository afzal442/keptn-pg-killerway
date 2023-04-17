# Port Forward the Bridge
Open up the Keptn's Bridge by port forwarding the UI. This will expose the UI on port `8080`{{}}:

```
./portforward.sh
```{{exec}}

The port-forwarding runs in the background so it should never stop, but if does, just re-run the above command.

# Authenticate Keptn CLI

Much like `kubectl`, the `keptn` CLI can be used to interact with the control plane.

```
keptn auth --endpoint={{TRAFFIC_HOST1_8080}}/api --api-token=$(kubectl get secret keptn-api-token -n keptn -ojsonpath='{.data.keptn-api-token}' | base64 -d)
```{{exec}}

# Keptn Bridge

The bridge is the web-based interface for Keptn.

Retrieve the login details for the bridge:

```
~/print_bridge_login_details.sh
```{{exec}}

Visit [the bridge]({{TRAFFIC_HOST1_8080}}/bridge) (opens in a new tab). Login and come back here.

The bridge and API are available at any time from the Killercoda interface:

1. Navigate to the menu icon (three lines on the top right)
2. Select `Traffic / Ports`
3. Click Port `8080` to access the bridge
4. A link to the API is found under the "little person" icon (top right)
