# 1002: Bootstrap

One command to bootstrap Game Plane onto your infrastructure.

## Bootstrap

The CLI bootstraps Game Plane onto your existing infrastructure:
- Creates a Kind cluster (if none exists)
- Installs Argo CD into the cluster
- Verifies connectivity to **all servers** in your inventory via Ansible

## Local Inventory Directory

A local directory on your machine defines server inventory:

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

## Bootstrap Flow

```
gameplane bootstrap --inventory /path/to/local/inventory
```

Under the hood:
1. **Kind** — creates a lightweight Kubernetes cluster
2. **Argo CD** — deploys into Kind, ready to reconcile game server charts
3. **Ansible** — reads `inventory/hosts.yml` and `inventory/known_hosts` from the local directory, then verifies connectivity to **all servers** listed (SSH, basic packages)
4. **ApplicationSet controller** — installs the Argo CD ApplicationSet controller so it is ready to receive ApplicationSet resources
5. **Status** — surfaces Game Plane status through the CLI

> **Note:** Bootstrap takes a **local directory** containing server inventory — it does not touch game server manifests. That is the responsibility of `gameplane run` (story 1003).

## Debootstrap

```
gameplane debootstrap
```

- Removes the Kind cluster and Argo CD
- Leaves your servers and game worlds untouched

## Expected User Flow

```
gameplane bootstrap --inventory /path/to/local/inventory
gameplane status
gameplane debootstrap
```

## Acceptance Criteria

- [ ] One command bootstraps Kind + Argo CD + server connectivity verification across **all inventory hosts**
- [ ] ApplicationSet controller is installed and ready to receive ApplicationSet resources
- [ ] One command debootstrap removes Game Plane without touching servers or worlds
- [ ] CLI reports reconciliation status (healthy, syncing, error)
