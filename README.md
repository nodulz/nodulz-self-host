# Nodulz

Visual workflow automation with integrations, Infrastructure as Code and execution history.

This repository contains the deployment kit for **Nodulz 0.29.3**. Application sources remain private; installing Nodulz does not require source access, Bun or a registry login. See [NOTICE.txt](NOTICE.txt) for distribution terms.

- Application image: [`ghcr.io/nodulz/nodulz:0.29.3`](https://github.com/orgs/nodulz/packages/container/package/nodulz), Linux amd64.
- Helm chart: `oci://ghcr.io/nodulz/charts/nodulz`, version `0.29.3`.
- [Versioned downloads and SHA-256 checksums](https://github.com/nodulz/nodulz-self-host/releases/tag/v0.29.3).
- [Installation guide](https://nodulz.com/docs/installation) and [complete environment reference](https://nodulz.com/docs/self-host-configuration), available in French and English.

The image serves the interface and API together on port 3001. The Free edition works without a license key or portal account.

## Docker Compose

With Docker Compose and OpenSSL installed:

```sh
git clone --branch v0.29.3 https://github.com/nodulz/nodulz-self-host.git
cd nodulz-self-host
sh init.sh
docker compose -f docker-compose.postgres.yaml up -d
```

Enter `0.29.3` when the initializer asks for the version. It creates a private `.env` with the administrator password, both instance encryption/authentication secrets and the PostgreSQL password. Use the public URL and administrator credentials configured there to sign in. `docker-compose.yaml` provides the SQLite alternative.

For HTTPS, database choices and copyable configuration, follow the [Docker and Compose guide](https://nodulz.com/docs/self-host-docker).

## Kubernetes and Helm

Prepare the `nodulz-instance` Secret and `values.yaml` using the [Kubernetes guide](https://nodulz.com/docs/self-host-kubernetes), then install the public chart:

```sh
helm install nodulz oci://ghcr.io/nodulz/charts/nodulz \
  --version 0.29.3 -n nodulz --create-namespace -f values.yaml --wait --timeout 5m
```

The chart supports SQLite or an external PostgreSQL database. It requires persistent storage and an existing instance Secret.

## Scripts and Infrastructure as Code

Execution requires an explicitly configured runtime: the Docker overlay shares the Docker socket and application data, while Helm's `scripts.enabled` configures Jobs, RBAC and shared storage. Follow the [runtime guide](https://nodulz.com/docs/self-host-operations) before enabling execution.

IaC uses a public Python image and verified tool downloads cached per owner; no dedicated IaC images need to be built. First use requires network access to the tool distributors. Projects may also download providers and dependencies.

## Image verification

`release.json` records the exact image digest. Each GitHub release includes the deployment archive, Helm chart, release metadata and `SHA256SUMS`. Version tags are immutable; `stable` advances only after publication and anonymous-access checks succeed.

The image is signed with GitHub Actions OIDC. Its signing identity is `https://github.com/Seapalm-pro/nodulz/.github/workflows/release.yaml@refs/heads/main`, with issuer `https://token.actions.githubusercontent.com`. Image metadata links to the public documentation and this deployment repository; its source label identifies the private application repository.
