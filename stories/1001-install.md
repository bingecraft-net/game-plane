# 1001: Install

One command to install Game Plane.

## Install

The CLI installs Game Plane and all required dependencies with a single command:

```
./install.sh
```

## Dependencies

Game Plane CLI requires only the tools needed to **manage** remote clusters:

| Tool | Purpose |
|------|---------|
| Argo CD CLI | Manages Argo CD deployments on remote clusters |
| kubectl | Interacts with Kubernetes clusters on remote servers |
| Ansible | Verifies server connectivity and prepares targets |

Kind and Helm are **not** installed by this script. They are deployed to target inventory servers during `bootstrap`.

## Installation Strategy

The installer follows this priority:

1. **macOS** — Installs Homebrew (if not present), then uses `brew install`
2. **Linux (Debian/Ubuntu)** — Uses APT (`apt`)
3. **Linux (Arch)** — Uses Yay (`yay`) or Pacman (`pacman`)
4. **Linux (RHEL/Fedora)** — Uses DNF (`dnf`) or YUM (`yum`)

On macOS, Homebrew is installed automatically if not already present. This is a one-time cost that enables package management for all subsequent dependencies.

## Expected User Flow

```
./install.sh
./install.sh --dry-run    # Preview what would be installed
./install.sh --force      # Force reinstall all tools
```

## Acceptance Criteria

- [ ] One command installs CLI dependencies (Argo CD CLI, kubectl, Ansible)
- [ ] On macOS, Homebrew is installed automatically if not present
- [ ] Installer detects and uses the host package manager automatically
- [ ] Installer skips tools that are already installed
- [ ] `--dry-run` flag shows what would be installed without making changes
- [ ] `--force` flag reinstalls already installed tools
- [ ] Installer fails gracefully when no supported package manager is detected
- [ ] Installer reports which tools failed to install (if any)