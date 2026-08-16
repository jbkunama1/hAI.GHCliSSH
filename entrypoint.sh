#!/bin/sh
set -e

# Copilot CLI authenticates automatically via env. Prefer the Copilot-specific
# variable; fall back to the generic GITHUB_TOKEN that Portainer users often set.
: "${COPILOT_GITHUB_TOKEN:=${GITHUB_TOKEN:-}}"
export COPILOT_GITHUB_TOKEN

# MCP server + LLM provider settings (injected into the runtime shell for Copilot CLI)
MCP_SERVER="${MCP_SERVER:-AnythingMCP}"
LLM_PROVIDER_API_KEY="${LLM_PROVIDER_API_KEY:-}"
export MCP_SERVER LLM_PROVIDER_API_KEY

# ttyd basic auth (empty password disables auth; empty user -> default "admin")
TTYD_USER="${TTYD_USER:-admin}"
TTYD_PASSWORD="${TTYD_PASSWORD:-}"

# Keep the port / command configurable, but require auth when a password is set.
TTYD_PORT="${TTYD_PORT:-8833}"
CMD="${TTYD_CMD:-bash}"

if [ -n "$TTYD_PASSWORD" ]; then
  exec ttyd -W -c "$TTYD_USER:$TTYD_PASSWORD" -p "$TTYD_PORT" "$CMD"
else
  exec ttyd -W -p "$TTYD_PORT" "$CMD"
fi
