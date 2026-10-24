# 1002: Bootstrap

One command to bootstrap Game Plane.

## Bootstrap

The CLI bootstraps Game Plane onto your existing infrastructure:
- Creates a Kind cluster (if none exists)
- Installs Argo CD into the cluster
- Verifies connectivity to your servers

## Git Repository Structure

Your git repo defines everything:

```
game-servers/
└── inventory/
    └── hosts.yml          # Server inventory (Ansible)
```

**Inventory** (`inventory/hosts.yml`):
```yaml
all:
  hosts:
    home-lab-1:
      address: "10.0.0.1"
      username: "tyler"
      ssh_key: "~/.ssh/gameplane"
    home-lab-2:
      address: "10.0.0.2"
      username: "tyler"
      ssh_key: "~/.ssh/gameplane"
```

No game labels. Servers are just servers — generic, addressable, SSH-accessible.

## Bootstrap Flow

```
gameplane bootstrap --repo git@github.com:user/game-servers
```

Under the hood:
1. **Kind** — creates a lightweight Kubernetes cluster
2. **Argo CD** — deploys into Kind, ready to deploy game server charts
3. **Ansible** — verifies connectivity to servers in your inventory (SSH, basic packages)
4. **Status** — surfaces Game Plane status through the CLI

## Debootstrap

```
gameplane debootstrap
```

- Removes the Kind cluster and Argo CD
- Leaves your servers and game worlds untouched

## Expected User Flow

```
gameplane bootstrap --repo git@github.com:user/game-servers
gameplane status
gameplane debootstrap
```

## Acceptance Criteria

- [ ] One command bootstraps Kind + Argo CD + server connectivity verification
- [ ] One command debootstrap removes Game Plane without touching servers or worlds
- [ ] World/save data persists outside the cluster lifecycle
- [ ] CLI reports reconciliation status (healthy, syncing, error)
- [ ] Git repository is configurable; falls back to a sensible default
