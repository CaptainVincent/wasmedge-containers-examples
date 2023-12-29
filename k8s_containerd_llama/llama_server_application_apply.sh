#!/bin/bash
set -x # Enable verbose for the debug information
export KUBERNETES_PROVIDER=local
export WASM_IMAGE=ghcr.io/second-state/runwasi-demo
export WASM_IMAGE_TAG=llama-simple
export VARIANT=compat-smart
export CLUS_NAME=local
export CRED_NAME=myself
export SERVER=https://localhost:6443
export CERT_AUTH=/var/run/kubernetes/server-ca.crt
export CLIENT_KEY=/var/run/kubernetes/client-admin.key
export CLIENT_CERT=/var/run/kubernetes/client-admin.crt
export CONFIG_FOLDER=$( dirname -- "$0"; )
export CONFIG_NAME=k8s-llama_server.yaml

sudo ./kubernetes/cluster/kubectl.sh config set-cluster "$CLUS_NAME" --server="$SERVER" --certificate-authority="$CERT_AUTH"
sudo ./kubernetes/cluster/kubectl.sh config set-credentials $CRED_NAME --client-key="$CLIENT_KEY" --client-certificate="$CLIENT_CERT"
sudo ./kubernetes/cluster/kubectl.sh config set-context "$CLUS_NAME" --cluster="$CLUS_NAME" --user="$CRED_NAME"
sudo ./kubernetes/cluster/kubectl.sh config use-context "$CLUS_NAME"

sudo ./kubernetes/cluster/kubectl.sh cluster-info

if [ -f "$CONFIG_NAME" ]
then
    rm -rf "$CONFIG_NAME"
fi
cp "$CONFIG_FOLDER"/"$CONFIG_NAME" ./
sudo ./kubernetes/cluster/kubectl.sh apply -f k8s-llama_server.yaml

echo -e "Wait 180s"
sleep 180

sudo ./kubernetes/cluster/kubectl.sh get pod --all-namespaces -o wide
sudo ./kubernetes/cluster/kubectl.sh describe pod testggml
