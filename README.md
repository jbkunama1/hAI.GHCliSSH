# hAI.GHCliSSH

GitHub Copilot CLI in a browser-based terminal (`ttyd`) — one `docker run` away.
No separate SSH server needed, no local install required.

[![Docker](https://img.shields.io/badge/Docker-2496ed?logo=docker&logoColor=white)](https://hub.docker.com/)
[![ttyd](https://img.shields.io/badge/ttyd-1.7.2-52b56b)](https://github.com/tsl0922/ttyd)
[![Copilot CLI](https://img.shields.io/badge/Copilot%20CLI-1.x-2366d1?logo=githubcopilot)](https://github.com/features/copilot)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Overview

This project provides a single Docker container that publishes a browser-based
terminal (via [`ttyd`](https://github.com/tsl0922/ttyd)) and has
GitHub Copilot CLI pre-installed.

You start the container, open `http://<host>:8833` in a browser and can then
work directly with `copilot` and other commands — just like an SSH session,
but without needing a separate SSH server.

### Architecture

| Layer | Description |
|-------|-------------|
| Base image | `tsl0922/ttyd:latest` — ships `ttyd` and all terminal-over-HTTP plumbing |
| Copilot CLI | Installed via GitHub's official script: `curl -fsSL https://gh.io/copilot-install | bash` |
| ttyd listener | Port `8833` inside the container, mapped to the host |
| Workspace | `/workspace` — working directory inside the container |

---

## Table of Contents

- [Install](#install)
- [Run](#run)
- [Browser Access](#browser-access)
- [Using Copilot CLI](#using-copilot-cli)
- [Security & Networking](#security--networking)
- [License](#license)

---

## Install

### 1. Clone the repository

```bash
git clone https://github.com/jbkunama1/hAI.GHCliSSH.git
cd hAI.GHCliSSH
```

### 2. Build the Docker image

```bash
docker build -t copilot-ttyd .
```

- `copilot-ttyd` is the name of the image you are creating.
- The dot `.` is the build context (current directory).

After a successful build you have an image that combines `ttyd` and the
GitHub Copilot CLI.

---

## Run

```bash
docker run --rm -it \
  -p 8833:8833 \
  --name copilot-ttyd \
  copilot-ttyd
```

| Flag | Effect |
|------|--------|
| `-p 8833:8833` | Maps container port `8833` → host port `8833` |
| `--rm` | Removes the container automatically when it stops |
| `--name copilot-ttyd` | Friendly name for the running container |

> **Tip:** To persist your work, add `-v copilot-workspace:/workspace` to keep
> files between container restarts.

---

## Browser Access

Open in your browser:

```text
http://localhost:8833
```

…or from another machine on the network:

```text
http://<host-ip>:8833
```

You see a full TTY running inside the container, served over HTTP by `ttyd`.

---

## Using Copilot CLI

Inside the browser terminal, simply run:

```bash
copilot
```

On first launch Copilot CLI will:

1. Ask whether you trust the current directory.
2. Prompt you to authenticate (use the GitHub login flow, typically
   `/login` or the auth command shown).

Examples:

```bash
# Interactive mode
copilot

# One-shot prompt
copilot -p "create a bash script that cleans up my git repo"
```

Copilot can then suggest commands, generate scripts and work with files
inside `/workspace`.

---

## Security & Networking

- **Do not expose port `8833` to the public internet** without additional
  authentication. A reverse proxy with Basic Auth, OAuth or a VPN is
  strongly recommended — the terminal has full access to the container.
- For classroom or local test setups a LAN-only binding plus firewall rules
  is usually sufficient.

- **Persistence of authentication**: To retain Copilot credentials across container restarts, consider mounting a volume for the Copilot config directory (e.g., `-v copilot-config:/root/.copilot`). Note that without a system keychain, credentials may be stored in plaintext.

---

## License

MIT