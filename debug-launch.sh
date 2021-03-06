#!/usr/bin/env bash

# see https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
#set -e #-e exit immediately if pipeline return non zero status
#set -x #-x print trace of commands
set -u #-u treat unset variable and parameter as error
#-o set option pipefail If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status
set -o pipefail


# Use deps from vendor dir.
export GOFLAGS="-mod=vendor"
GIT_TAG=${SOURCE_GIT_TAG:-$(git describe --always --tags HEAD)}
LD_FLAGS=" -X github.com/openshift/console/pkg/version.Version=${GIT_TAG}"

#set up the debug environment and variables
source ./debug-environment.sh

consoleHost=$CONSOLE_HOST_NAME
consoleApiPort=$CONSOLE_API_PORT
debuggerApiPort=$CONSOLE_DEBUGGER_API_PORT
consoleClusterUrl=$CONSOLE_CLUSTER_URL
consoleAlertManagerUrl=$CONSOLE_ALERTMANAGER_URL
consoleThanosUrl=$CONSOLE_THANOS_URL

#--build-flags="-gcflags='all=-N -l' -ldflags='${LD_FLAGS}' "  \

set -x
dlv debug \
./cmd/bridge/main.go \
--output=./bin/bridge \
--api-version=2 \
--listen=${consoleHost}:${debuggerApiPort} \
--headless \
--accept-multiclient \
--log \
--wd=. \
--continue \
-- \
--base-address=http://${consoleHost}:${consoleApiPort} \
--ca-file=examples/ca.crt \
--k8s-auth=openshift \
--k8s-mode=off-cluster \
--k8s-mode-off-cluster-endpoint=${consoleClusterUrl} \
--k8s-mode-off-cluster-skip-verify-tls=true \
--listen=http://${consoleHost}:${consoleApiPort} \
--public-dir=./frontend/public/dist \
--user-auth=openshift \
--user-auth-oidc-client-id=console-oauth-client \
--user-auth-oidc-client-secret-file=examples/console-client-secret \
--user-auth-oidc-ca-file=examples/ca.crt \
--k8s-mode-off-cluster-alertmanager=$consoleAlertManagerUrl \
--k8s-mode-off-cluster-thanos=$consoleThanosUrl


