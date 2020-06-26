# Unofficial Sitecore Helm charts

![Release Charts](https://github.com/sitecoreops/sitecore-helm/workflows/Release%20Charts/badge.svg)

Quick start:

```powershell
# add this repo to helm
helm repo add sitecoreops https://sitecoreops.github.io/sitecore-helm

# refresh all repositories
helm repo update

# search charts
helm search repo sitecore
```

## Changelog

### June 2020

- [Added] Ability to override default environment variables on CM/CD deployments. Example `--set cm.envOverride.SITECORE_CONNECTIONSTRINGS_CORE="XXX"`.
- [Added] Ability to append environment variables on CM/CD deployments. Example `--set cm.env[0].name="XXX" --set cm.env[0].value="YYY"`.

### April 2020

- [Added] Sitecore 9.3 XM chart `sitecore930-xm`.

## Prerequisites

- Kubernetes 1.15+
- Helm 3+
- A Sitecore license file.
- Access to a Docker registry with Sitecore images (both Windows and Linux).

## Examples

### Minimal deployment (no ingress)

```powershell
# create a new namespace for your deployment
$namespace = "awesome-sitecore-project"

kubectl create namespace $namespace

# deploy your Sitecore license file
kubectl create secret generic "license.xml" --from-file "C:\license\license.xml" --namespace $namespace

# install Sitecore XM (reference: https://helm.sh/docs/intro/using_helm/)
$release = "release1"

helm upgrade $release sitecoreops/sitecore930-xm --install --namespace $namespace `
    --set solr.image.tag="<LINUX IMAGE TAG OR DIGEST>" `
    --set sql.image.tag="<LINUX IMAGE TAG OR DIGEST>" `
    --set cd.image.tag="<WINDOWS IMAGE TAG OR DIGEST>" `
    --set cm.image.tag="<WINDOWS IMAGE TAG OR DIGEST>" `
    --set cm.adminPassword="<INSERT SECRET HERE>" `
    --set cm.unicornSharedSecret="<INSERT SECRET HERE>" `
    --set global.sqlSaPassword="<INSERT SECRET HERE>" `
    --set global.telerikEncryptionKey="<INSERT SECRET HERE>" `
    --timeout "30m0s" `
    --wait

# forward port from your host to the CM and then you can browse http://localhost:7777
kubectl port-forward deploy/$release-cm 7777:80 --namespace $namespace
```

> Add `--dry-run` the to Helm upgrade/install command to verify deployment without installing anything.

### Deployment with HTTP ingress

Requirements:

- [https://hub.helm.sh/charts/stable/nginx-ingress](https://hub.helm.sh/charts/stable/nginx-ingress) needs to be installed.

```powershell
--set cd.ingress.enabled=true `
--set cd.ingress.annotations."kubernetes\.io/ingress\.class"="nginx" `
--set cd.ingress.annotations."nginx\.ingress\.kubernetes\.io/affinity"="cookie" `
--set cd.ingress.hosts[0].host="<HOST NAME FOR THE CD>" `
--set cd.ingress.hosts[0].paths[0]="/" `
--set cm.ingress.enabled=true `
--set cm.ingress.annotations."kubernetes\.io/ingress\.class"="nginx" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-connect-timeout"="60s" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-send-timeout"="60s" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-read-timeout"="60s" `
--set cm.ingress.hosts[0].host="<HOST NAME FOR THE CM>" `
--set cm.ingress.hosts[0].paths[0]="/" `
```

### Deployment with HTTPS ingress and auto generated Let's Encrypt certificates

Requirements:

- [https://hub.helm.sh/charts/stable/nginx-ingress](https://hub.helm.sh/charts/stable/nginx-ingress) needs to be installed.
- [https://hub.helm.sh/charts/jetstack/cert-manager](https://hub.helm.sh/charts/jetstack/cert-manager) needs to be installed and a Let's Encrypt [issuer](https://cert-manager.io/docs/configuration/acme/http01/).

```powershell
--set cd.ingress.enabled=true `
--set cd.ingress.annotations."kubernetes\.io/ingress\.class"="nginx" `
--set cd.ingress.annotations."nginx\.ingress\.kubernetes\.io/affinity"="cookie" `
--set cd.ingress.annotations."cert-manager\.io/issuer"="<NAME OF ISSUER>" `
--set cd.ingress.tls[0].hosts[0]="<HOST NAME FOR THE CD>" `
--set cd.ingress.tls[0].secretName="letsencrypt-tls-cd" `
--set cd.ingress.hosts[0].host="<HOST NAME FOR THE CD>" `
--set cd.ingress.hosts[0].paths[0]="/" `
--set cm.ingress.enabled=true `
--set cm.ingress.annotations."kubernetes\.io/ingress\.class"="nginx" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-connect-timeout"="60s" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-send-timeout"="60s" `
--set cm.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-read-timeout"="60s" `
--set cm.ingress.annotations."cert-manager\.io/issuer"="<NAME OF ISSUER>" `
--set cm.ingress.tls[0].hosts[0]="<HOST NAME FOR THE CM>" `
--set cm.ingress.tls[0].secretName="letsencrypt-tls-cm" `
--set cm.ingress.hosts[0].host="<HOST NAME FOR THE CM>" `
--set cm.ingress.hosts[0].paths[0]="/" `
```

## TODO's

- Unicorn shared secret / admin password should be optional.
- Document values: [https://helm.sh/docs/chart_best_practices/values/#document-valuesyaml](https://helm.sh/docs/chart_best_practices/values/#document-valuesyaml)
- Set `required` on required values.
