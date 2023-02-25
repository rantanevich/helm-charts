# Helm Charts

Helm charts repository

## Usage

[Helm](https://helm.sh/) must be installed to use charts.
Once Helm is set up properly, add the repo:

```sh
helm repo add rantanevich https://rantanevich.github.io/helm-charts
helm repo update
```

To show available charts:

```sh
helm search repo rantanevich
```

To install a chart:

```sh
helm install <release-name> rantanevich/<chart-name>
```
