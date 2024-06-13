# Deepgram Self-Hosted Google Cloud Platform Starter

## Overview

The Deepgram Self-Hosted Google Cloud Platform Starter is a Helm chart for running a starter Deepgram application in a self-hosted environment. It provides a simple way to get started with Deepgram's speech recognition capabilities in your own infrastructure. 

Key features:
- Starter web application to be introduced to Deepgram's API
- Deployment via Helm chart
- Customizable via Helm chart values

To learn more about deploying Deepgram in a self-hosted environment within GCP, please contact [Deepgram Support](https://deepgram.com/contact-us/).

## One-time Setup 

1. Install [kubectl](https://kubernetes.io/docs/tasks/tools/) and [Helm](https://helm.sh/docs/intro/install/) on the machine where you will deploy the application.

2. Install the Application CRD so your cluster can manage the Application resource:

```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml
```

## Installation

Set environment variables for your app name and namespace:

```bash
export APP_INSTANCE_NAME=deepgram-starter-1
export NAMESPACE=default
```

Retrieve the Deepgram Self-Hosted Starter image references:

```bash
export IMAGE_REPO=gcr.io/deepgram-public/deepgram-self-hosted-starter
export IMAGE_TAG=1.1.4
```

Install the app with Helm:

```bash
helm upgrade --install ${APP_INSTANCE_NAME} deepgram/deepgram-self-hosted-starter \
  --namespace ${NAMESPACE} \
  --set deepgramSelfHostedStarter.image.repo=${IMAGE_REPO} \
  --set deepgramSelfHostedStarter.image.tag=${IMAGE_TAG}
```

## Basic Usage

The starter application exposes a web UI. Get the external IP of the service:

```bash
kubectl get service ${APP_INSTANCE_NAME}-starter-svc \
  --namespace ${NAMESPACE} \
  --output jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Open the URL `http://<EXTERNAL-IP>` in a web browser with access to the cluster network to access the starter application.

## Backup and Restore

The Deepgram Self-Hosted Starter does not persist any data. Backup and restore procedures are not applicable.

## Image Updates

To update the application with a new image version, set the new tag:

```bash
export NEW_IMAGE_TAG=2.0.0
```

Update the Deployment with the new image:

```bash 
helm upgrade ${APP_INSTANCE_NAME} deepgram/deepgram-self-hosted-starter \
  --namespace ${NAMESPACE} \
  --set deepgramSelfHostedStarter.image.repo=${IMAGE_REPO} \
  --set deepgramSelfHostedStarter.image.tag=${NEW_IMAGE_TAG}
```

## Deletion

To delete the Deepgram Self-Hosted Starter application:

```bash
helm uninstall ${APP_INSTANCE_NAME} --namespace ${NAMESPACE}
```

This will remove all resources associated with the application.
