# 🚀 hAI.GHCliSSH

GitHub Copilot CLI in a browser-based terminal (`ttyd`) — one `docker run` away.
No separate SSH server needed, no local install required.

[![Docker](https://img.shields.io/badge/Docker-2496ed?logo=docker&logoColor=white)](https://hub.docker.com/)
[![ttyd](https://img.shields.io/badge/ttyd-1.7.2-52b56b)](https://github.com/tsl0922/ttyd)
[![Copilot CLI](https://img.shields.io/badge/Copilot%20CLI-1.x-2366d1?logo=githubcopilot)](https://github.com/features/copilot)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

![Space Shooter](game.gif)

---

## 📖 Overview

This project provides a single Docker container that publishes a browser-based
terminal (via [`ttyd`](https://github.com/tsl0922/ttyd)) and has
GitHub Copilot CLI pre-installed.

You start the container, open `http://<host>:8833` in a browser and can then
work directly with `copilot` and other commands — just like an SSH session,
but without needing a separate SSH server.

### 🏗️ Architecture

| Layer | Description |
|-------|-------------|
| Base image | `tsl0922/ttyd:latest` — ships `ttyd` and all terminal-over-HTTP plumbing |
| Copilot CLI | Installed via GitHub's official script: `curl -fsSL https://gh.io/copilot-install | bash` |
| ttyd listener | Port `8833` inside the container, mapped to the host |
| Workspace | `/workspace` — working directory inside the container |

---

## 📚 Table of Contents

- [Install](#install)
- [Run](#run)
- [Docker Compose](#docker-compose)
- [Deploy to Portainer](#deploy-to-portainer)
- [Browser Access](#browser-access)
- [Using Copilot CLI](#using-copilot-cli)
- [Security & Networking](#security--networking)
- [License](#license)

---

## 🛠️ Install

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

## 🚀 Run

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

## 📦 Pre-built GHCR image

A pre-built image is published to GitHub Container Registry for every push to
`main` (via the `docker-publish.yml` workflow):

```
ghcr.io/jbkunama1/hai.ghclissh:main
```

> **Note:** The package is currently **private**. To pull it you must either
> make the package public on GitHub (Packages → *Package settings* →
> *Change visibility*) or authenticate your container runtime (see
> [Deploy to Portainer](#deploy-to-portainer)).

### 📥 Pull the image

```bash
docker pull ghcr.io/jbkunama1/hai.ghclissh:main
```

> For a private package, log in first:
>
> ```bash
> echo $GITHUB_TOKEN | docker login ghcr.io -u jbkunama1 --password-stdin
> ```
>
> where `GITHUB_TOKEN` is a PAT with the `read:packages` scope.

---

## 🐳 Docker Compose

The standard deployment uses [`docker-compose.yml`](docker-compose.yml) from
this repository, which references the GHCR image:

```yaml
services:
  copilot-terminal:
    image: ghcr.io/jbkunama1/hai.ghclissh:main
    container_name: hAI.GHCliSSH
    ports:
      - "8833:8833"
    volumes:
      - copilot-config:/home/copilot/.copilot
    restart: unless-stopped

volumes:
  copilot-config:
```

Run it:

```bash
docker compose up -d
```

The `copilot-config` volume persists your Copilot authentication and
configuration between container restarts.

---

## ⚓ Deploy to Portainer

Du kannst den Stack direkt aus dem Git‑Repository deployen. Beim Erstellen musst du folgende Umgebungsvariablen angeben (im UI von Portainer im **Environment‑Variables**‑Feld):

| Variable | Zweck | Beispielwert |
|----------|-------|--------------|
| `MCP_SERVER` (optional) | MCP‑Server, den Copilot CLI verwenden soll | `AnythingMCP` |
| `MCP_SERVER_API_KEY` (optional) | API‑Key für den MCP‑Server | `mscp_ABC123…` |
| `OPENAI_API_KEY` (optional, BYOK) | API‑Key deines LLM‑Providers (z. B. 9router) – wird an Copilot CLI als `COPILOT_PROVIDER_API_KEY` weitergereicht | `sk-ABC123…` |
| `OPENAI_URL` (optional, BYOK) | Base‑URL deines eigenen OpenAI‑kompatiblen LLM‑Servers – wird an Copilot CLI als `COPILOT_PROVIDER_BASE_URL` weitergereicht | `https://llm.example.com/v1` |
| `COPILOT_MODEL` (optional) | Modell‑Identifikator für den BYOK‑Provider | `gpt-4o-mini` |
| `COPILOT_GITHUB_TOKEN` | Fein‑granularer PAT mit **Copilot Requests**‑Scope – authentifiziert Copilot CLI automatisch | `ghp_ABC123…` |
| `TTYD_USER` (optional) | Benutzername für Basic‑Auth (default `admin`) | `admin` |
| `TTYD_PASSWORD` (optional) | Passwort für Basic‑Auth – leer lässt das Login weg | `geheim123` |

> **Hinweis:** `LLM_PROVIDER_API_KEY` bleibt als veralteter Alias von `OPENAI_API_KEY` erhalten (Read‑only, nur für Bestandssetups).

Der Stack startet den Service auf Port **8833**, bindet das Volume `copilot-config` für die persistente Copilot‑Konfiguration und verbindet den Container mit dem externen Docker-Netzwerk **`highfishNetwork`** (muss in Portainer/Docker bereits angelegt sein). Die Authentifizierung läuft komplett über die Umgebungsvariablen (`COPILOT_GITHUB_TOKEN` bzw. die BYOK‑Provider-Variablen) – ein manuelles `copilot login` im Web‑Terminal ist **nicht** mehr nötig.

---

## 🌐 Browser Access

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

## 🤖 Using Copilot CLI

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

## 🛡️ Security & Networking

- **Do not expose port `8833` to the public internet** without additional
  authentication. A reverse proxy with Basic Auth, OAuth or a VPN is
  strongly recommended — the terminal has full access to the container.
- For classroom or local test setups a LAN-only binding plus firewall rules
  is usually sufficient.

- **Persistence of authentication**: To retain Copilot credentials across container restarts, consider mounting a volume for the Copilot config directory (e.g., `-v copilot-config:/home/copilot/.copilot`). Note that without a system keychain, credentials may be stored in plaintext.

---

## 📄 License

MIT