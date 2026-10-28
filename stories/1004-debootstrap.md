# 1004: Debootstrap

One command to remove Game Plane from your infrastructure.

## Debootstrap

```
gameplane debootstrap
```

- Removes the Kind clusters and Argo CD from remote servers
- Leaves your servers and game worlds untouched

## Expected User Flow

```
gameplane bootstrap --inventory /path/to/local/inventory
gameplane status
gameplane debootstrap
```

## Acceptance Criteria

- [ ] One command debootstrap removes Kind clusters and Argo CD without touching servers or worlds
- [ ] Debootstrap prints a warning if there is no tracked game-plane to debootstrap
