# 1002: Single Entrypoint

One command to get the Game Plane running after installation.

Running the Game Plane makes it begin to watch some git repository.

## Bootstrap

The CLI bootstraps Game Plane onto your existing infrastructure:
- Deploys Argo CD into a lightweight Kubernetes cluster (Kind or similar)
- Configures Argo CD to watch a git repository containing Helm + Terraform manifests
- Discovers and registers your existing servers (by SSH, hostname, or config)
- Exposes a local endpoint for health checks and status

## Debootstrap

The same CLI can tear down Game Plane cleanly:
- Removes the cluster and Argo CD
- Leaves your servers and game worlds untouched

## Reconciliation Loop

Once running, Game Plane watches the configured git repository and reconciles:
- **Helm charts** → deploys and configures game server software (Valheim, Monifactory, etc.)
- **Terraform manifests** → (optional, for future infra provisioning)
- Detects drift and applies changes automatically
- Reports status back through the CLI

## Expected User Flow

```
gameplane bootstrap --repo git@github.com:user/game-servers --servers 10.0.0.1,10.0.0.2
gameplane status
gameplane debootstrap
```

## Acceptance Criteria

- [ ] One command bootstraps Game Plane onto 2+ existing servers
- [ ] One command debootstrap removes Game Plane without touching servers or worlds
- [ ] World/save data persists outside the cluster lifecycle
- [ ] CLI reports reconciliation status (healthy, syncing, error)
- [ ] Git repository is configurable; falls back to a sensible default
