#!/bin/sh
set -e

# Copilot CLI authenticates automatically via env -- no interactive `copilot login`
# required. Prefer the Copilot-specific variable; fall back to the generic
# GITHUB_TOKEN that Portainer users often set.
: "${COPILOT_GITHUB_TOKEN:=${GITHUB_TOKEN:-}}"
export COPILOT_GITHUB_TOKEN

# MCP server config (injected into the runtime shell for Copilot CLI)
MCP_SERVER="${MCP_SERVER:-AnythingMCP}"
MCP_SERVER_API_KEY="${MCP_SERVER_API_KEY:-}"
export MCP_SERVER MCP_SERVER_API_KEY

# BYOK LLM provider: map user-facing vars to the vars Copilot CLI understands.
# Keep LLM_PROVIDER_API_KEY as a backward-compatible alias for OPENAI_API_KEY.
: "${OPENAI_API_KEY:=${LLM_PROVIDER_API_KEY:-}}"
COPILOT_PROVIDER_BASE_URL="${OPENAI_URL:-}"
COPILOT_PROVIDER_API_KEY="${OPENAI_API_KEY:-}"
COPILOT_MODEL="${COPILOT_MODEL:-}"
export COPILOT_PROVIDER_BASE_URL COPILOT_PROVIDER_API_KEY COPILOT_MODEL

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
