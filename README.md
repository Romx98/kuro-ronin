# Kuro-Rōnin: Autonomous AST Runner

A turn-key, containerized runtime environment for automated security testing and the Penterep toolset.

---

## Quickstart

Operating the runner requires only two standard Docker Compose commands:

### 1. Build and start the container in the background

```bash
docker compose up -d --build
```

### 2. Attach to the interactive shell

```bash
docker compose exec kuro-ronin bash
```

Upon entering the container, an interactive ANSI banner displays live environment diagnostics and a quick command reference. You can re-display these anytime using `ronin-help` or `ronin-status`.

---

## Operating Penterep Tools (Inside Container)

All operations are handled directly through the official `ptmanager` CLI:

### Project & Connection Management

```bash
# Register a new project on Penterep AS (Application Server)
ptmanager --project-new --target <AS_URL> --auth <token>

# List registered projects
ptmanager --project-list

# Start/activate connection for a specific project ID
ptmanager --project-start 1

# End/disconnect a project
ptmanager --project-end 1
```

### Tool Management

```bash
# List available Penterep AST tools
ptmanager --tools-list

# Install specific tools
ptmanager --tools-install ptnmap ptssl ptvulns

# Update tools
ptmanager --tools-update ptnmap
```

---

## Network & System Privileges

The container is configured with low-level networking capabilities required for network scanning and raw socket operations:

- **`network_mode: host`:** Bypasses Docker NAT for native SYN/UDP packet generation.
- **Capabilities (`NET_RAW`, `NET_ADMIN`):** Grants raw packet capture and socket binding capabilities.
- **`ulimits: nofile: 65535`:** Prevents file descriptor exhaustion during parallel operations.
- **Persistent Volume (`penterep_data`):** Preserves `/root/.penterep` configuration across restarts.

---

## Repository Structure

```text
kuro-ronin/
├── Dockerfile          # Debian/Python 3.12 base with Nmap and ptmanager
├── docker-compose.yml  # Host networking, capabilities, ulimits, and persistent volume
├── entrypoint.sh       # Container initialization and interactive banner setup
├── tools.txt           # Manifest of preinstalled Penterep AST tools
└── README.md           # Documentation
```
