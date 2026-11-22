# Nodulz

Visual workflow automation with integrations, Infrastructure as Code and execution history.

This repository contains the deployment kit for **Nodulz 0.29.7**. Application sources remain private; installing Nodulz does not require source access, Bun or a registry login. See [NOTICE.txt](NOTICE.txt) for distribution terms.

- Application image: [`ghcr.io/nodulz/nodulz:0.29.7`](https://github.com/orgs/nodulz/packages/container/package/nodulz), Linux amd64.
- Helm chart: `oci://ghcr.io/nodulz/charts/nodulz`, version `0.29.7`.
- [Versioned downloads and SHA-256 checksums](https://github.com/nodulz/nodulz-self-host/releases/tag/v0.29.7).
- [Installation guide](https://nodulz.com/docs/installation) and [complete environment reference](https://nodulz.com/docs/self-host-configuration), available in French and English.

The image serves the interface and API together on port 3001. The Free edition works without a license key or portal account.

## Docker Compose

With Docker Compose and OpenSSL installed:

```sh
git clone --branch v0.29.7 https://github.com/nodulz/nodulz-self-host.git
cd nodulz-self-host
sh init.sh
docker compose -f docker-compose.postgres.yaml up -d
```

Enter `0.29.7` when the initializer asks for the version. It creates a private `.env` with the administrator password, both instance encryption/authentication secrets and the database passwords. Use the public URL and administrator credentials configured there to sign in. `docker-compose.yaml` uses SQLite. For a new MySQL 8.4 or MariaDB 11.4 installation, use `docker-compose.mysql.yaml` or `docker-compose.mariadb.yaml` with the generated `MYSQL_PASSWORD`. Each database has a private network endpoint and a dedicated volume. Switching the Compose file does not transfer data between engines.

For manual configuration, set `ADMIN_PASSWORD` to a unique password of 8–128 characters. The image rejects blank values and the old example `change-me-123`. If startup reports an invalid password, update `.env` and run `docker compose up -d` again with the same Compose files.

For HTTPS, database choices and copyable configuration, follow the [Docker and Compose guide](https://nodulz.com/docs/self-host-docker).

## Kubernetes and Helm

Prepare the `nodulz-instance` Secret and `values.yaml` using the [Kubernetes guide](https://nodulz.com/docs/self-host-kubernetes), then install the public chart:

```sh
helm install nodulz oci://ghcr.io/nodulz/charts/nodulz \
  --version 0.29.7 -n nodulz --create-namespace -f values.yaml --wait --timeout 5m
```

The chart supports SQLite or an external PostgreSQL database. It requires persistent storage and an existing instance Secret.

## Scripts and Infrastructure as Code

Execution requires an explicitly configured runtime: the Docker overlay shares the Docker socket and application data, while Helm's `scripts.enabled` configures Jobs, RBAC and shared storage. Follow the [runtime guide](https://nodulz.com/docs/self-host-operations) before enabling execution.

### Playwright

Playwright runs wherever scripts run, on Linux x86-64, with no extra setup. The first job pulls the Microsoft Playwright v1.64.1 Noble image pinned by digest and installs the runner's locked npm packages into the data volume. Allow access to MCR and the npm registry for this first run. If you previously set `PLAYWRIGHT_IMAGE` or Helm's `playwright.image` to a Nodulz runner, remove that override or point it to a mirror of the Microsoft image.

Jobs use the script runtime's resource limits with a read-only root filesystem, no capabilities and no privilege escalation. As for script nodes, the container is the isolation boundary and the browser uses the job's network. Chromium's internal sandbox is off because the default seccomp profile does not allow it.

#### Optional filtering gateway

The gateway restricts browser and Git traffic to approved origins and restores Chromium's internal sandbox. It uses the existing Nodulz application image. A preparation job also fetches Bubblewrap and socat from signed Ubuntu repositories, so allow access to Ubuntu for its first run.

The worker needs a kernel that permits unprivileged user namespaces for Bubblewrap and Chromium. Keep the container's non-root user, dropped capabilities, and privilege restrictions. If namespace creation fails, check the host kernel and AppArmor configuration for the worker.

Prepare the seccomp profile on your administration machine using Node.js. Use the profile that matches the Playwright version in the runner.

```sh
curl -fsSLo playwright-upstream.json https://raw.githubusercontent.com/microsoft/playwright/v1.64.1/utils/docker/seccomp_profile.json
node playwright-seccomp.mjs playwright-upstream.json nodulz-playwright.json
```

**Compose.** Add the gateway overlay after the Docker runtime overlay. Set `PLAYWRIGHT_SECCOMP_FILE` to the absolute path of the generated profile in `.env`.

```sh
docker compose -f docker-compose.yaml -f docker-compose.docker.yaml -f docker-compose.playwright.yaml up -d
```

**Kubernetes.** Generate the OCI version with `node playwright-seccomp.mjs playwright-upstream.json nodulz-playwright.json --kubernetes`. Install that profile under the kubelet seccomp root on each eligible worker node. Set these Helm values when upgrading your release.

```yaml
scripts:
  enabled: true
playwright:
  enabled: true
  seccompProfile: nodulz-playwright.json
  allowedOrigins: https://app.example.org,https://github.com,https://registry.npmjs.org
  gitOrigins: https://github.com
  deniedCidrs: 10.96.0.0/12,10.244.0.0/16
```

**Destinations.** Set `PLAYWRIGHT_ALLOWED_ORIGINS`, `PLAYWRIGHT_GIT_ORIGINS` and `PLAYWRIGHT_DENIED_CIDRS` in `.env` for Compose. Allow exact HTTP or HTTPS origins, including redirect, asset, Git, and registry origins that jobs need. For an approved internal IPv4 service, pin its address using `https://app.example.org=192.168.10.20`. Add your actual service, node, database, and control-plane ranges to the denied CIDRs. The gateway checks the origin and connects to a single validated address. HTTPS remains end-to-end encrypted, so approve only endpoints you trust. Configure Git access with HTTPS credentials and reserve the gateway for Nodulz workloads. On Kubernetes, use a CNI that enforces the chart's gateway ingress policy.

**En français.** Playwright fonctionne dès que l’exécution des scripts est activée, sans autre réglage. Le conteneur sert de frontière, comme pour les scripts. La passerelle filtrante est optionnelle : installez le profil seccomp, puis ajoutez l’overlay Compose ou activez `playwright.enabled` dans Helm. Renseignez les origines autorisées et les plages d’infrastructure à bloquer. Le loopback du job reste accessible au serveur de la suite.

IaC uses a public Python image and verified tool downloads cached per owner; no dedicated IaC images need to be built. First use requires network access to the tool distributors. Projects may also download providers and dependencies.

## Image verification

`release.json` records the exact image digest. Each GitHub release includes the deployment archive, Helm chart, release metadata and `SHA256SUMS`. Version tags are immutable; `stable` advances only after publication and anonymous-access checks succeed.

The image is signed with GitHub Actions OIDC. Its signing identity is `https://github.com/Seapalm-pro/nodulz/.github/workflows/release.yaml@refs/heads/main`, with issuer `https://token.actions.githubusercontent.com`. Image metadata links to the public documentation and this deployment repository; its source label identifies the private application repository.
