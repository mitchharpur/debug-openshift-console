#!/bin/bash

set -e
set -u #-u treat unset variable and parameter as error
set -o pipefail

echo "Retrieving the OAuth secret from the cluster..."
oc process -f examples/console-oauth-client.yaml | oc apply -f -
oc get oauthclient console-oauth-client -o jsonpath='{.secret}' > examples/console-client-secret