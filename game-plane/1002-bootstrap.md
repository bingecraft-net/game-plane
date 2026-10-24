# 1002: Bootstrap

One command to bootstrap Game Plane.

## Bootstrap

The CLI bootstraps Game Plane onto your existing infrastructure:
- Creates a Kind cluster (if none exists)
- Installs Argo CD into the cluster
- Verifies connectivity to your servers

## Git Repository Structure

Your git repo defines server inventory:

```
inventory/
├── hosts.yml          # Server inventory (Ansible)
└── known_hosts        # SSH host keys (pre-populated)
```

**Inventory** (`inventory/hosts.yml`):
```yaml
all:
  hosts:
    home-lab-1:
      ansible_host: "10.0.0.1"
      ansible_user: "game-plane"
      ansible_ssh_private_key_file: "~/.ssh/gameplane/id_ed25519"
      ansible_ssh_common_args: '-o UserKnownHostsFile="{{ inventory_dir }}/known_hosts"'
    home-lab-2:
      ansible_host: "10.0.0.2"
      ansible_user: "game-plane"
      ansible_ssh_private_key_file: "~/.ssh/gameplane/id_ed25519"
      ansible_ssh_common_args: '-o UserKnownHostsFile="{{ inventory_dir }}/known_hosts"'
```

No game labels. Servers are just servers — generic, addressable, SSH-accessible.

**Inventory fields:**

| Field | Description |
|---|---|
| `ansible_host` | Resolvable hostname or IP address (e.g., `10.0.0.1` and `10.0.0.2`) |
| `ansible_user` | Login username on the remote host |
| `ansible_ssh_private_key_file` | Path to the SSH private key for authentication |
| `ansible_ssh_common_args` | Extra SSH arguments (e.g., pointing to the known_hosts file) |

**Known hosts** (`inventory/known_hosts`): version-controlled SSH host keys so Ansible can verify servers without interactive prompts. Each host entry in the inventory references it via `ansible_ssh_common_args`.

## Game Server Manifests

Every subdirectory under `game-server-manifests/` is a [Helm](https://helm.sh) chart that will be reconciled by [Argo CD ApplicationSet](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/).

```
game-server-manifests/
├── README.md
└── <server-name>/
    ├── Chart.yaml          # Helm chart metadata
    ├── values.yaml         # Chart values (optional)
    └── templates/
        └── *.yaml          # Kubernetes manifests
```

Argo CD ApplicationSet watches this repository and generates an `Application` for each subdirectory automatically. The ApplicationSet uses the [Git generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators-Git/) to discover new subdirectories as they are added. Each generated Application points to the Helm chart in the corresponding subdirectory and reconciles it against the target cluster.

## Bootstrap Flow

```
gameplane bootstrap --repo git@github.com:user/game-server-manifests
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
